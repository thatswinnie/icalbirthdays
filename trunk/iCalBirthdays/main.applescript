-- main.applescript
-- iCalBirthdays

--  Created by Winnie on 20.10.07.
--  Copyright 2007 thatswinnie. All rights reserved.


on localized_string(key_string)
	return localized string of key_string in bundle with identifier "com.thatswinnie.Automator.iCalBirthdays"
end localized_string


on replaceText(find, replace, subject)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject
	
	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs
	
	return subject
end replaceText


on createiCalEvent(this_calendar, eventProperties, event_type_index, alert_type_index, alert_time, alarm)
	tell application "iCal"
		tell this_calendar
			set this_event to (make new event at end of events with properties eventProperties)
			
			-- adding alarm to the event
			if alert_type_index is not 1 then
				tell this_event
					if event_type_index is 0 then
						my createAlarm(alarm, this_calendar, this_event, alert_time)
						--make new sound alarm at end of sound alarms with properties {trigger interval:alert_time}
					else
						-- set the alarm of non-all-event to same time as event
						my createAlarm(alarm, this_calendar, this_event, 0)
						--make new sound alarm at end of sound alarms with properties {trigger interval:0}
					end if
				end tell
			end if
		end tell
	end tell
	return this_event
end createiCalEvent


on createiCalEventReminder(this_calendar, this_event, reminderAlert, alert_type_index, reminderAlert_interval_index, alert_time, this_alert_reminder_text, this_alert_text, eventProperties, event_type_index, alarm)
	tell application "iCal"
		tell this_calendar
			--set this_event to event whose uid is eventUid
			
			-- reminder alert
			if reminderAlert > 0 and alert_type_index > 0 then
				if reminderAlert_interval_index is 0 then
					set next_additional_birthday to (reminderAlert * 60 * 24)
				else if reminderAlert_interval_index is 1 then
					set next_additional_birthday to (reminderAlert * 60 * 24 * 7)
				end if
				
				if this_alert_reminder_text is equal to this_alert_text then
					-- adding alarm to the event
					set next_additional_birthday to alert_time - next_additional_birthday
					my createAlarm(alarm, this_calendar, this_event, next_additional_birthday)
				else
					-- make an additional event
					set summary of eventProperties to this_alert_reminder_text
					set start date of eventProperties to (start date of eventProperties) - next_additional_birthday * 60
					set reminderEvent to my createiCalEvent(this_calendar, eventProperties, event_type_index, 0, alert_time, alarm)
				end if
			end if -- if reminderAlert > 0 and alert_type_index > 0 then
		end tell
	end tell
end createiCalEventReminder


on createAlarm(alarmIndex, thisCalendar, thisEvent, trigger)
	tell application "iCal"
		tell thisCalendar
			tell thisEvent
				if alarmIndex is 0 then
					-- message
					make new display alarm at end of display alarms with properties {trigger interval:trigger}
				else
					-- message with sound
					make new sound alarm at end of sound alarms with properties {trigger interval:trigger}
				end if
			end tell
		end tell
	end tell
end createAlarm


on getAlertText(fieldName, alertFormatTxt, fullname, firstname, lastname, age, realBirthday, nextBirthday)
	if fieldName is 0 then
		set alert_text to (fullname)
	else if fieldName is 1 then
		set alert_text to (fullname & my localized_string("'s birthday"))
	else if fieldName is 2 then
		set alert_text to (fullname & " (" & year of realBirthday & ")")
	else if fieldName is 3 then
		set alert_text to (fullname & " (" & age & " " & my localized_string("in year") & " " & year of nextBirthday & ")")
	else if fieldName is 4 then
		set alert_text to (fullname & " (" & age & ")")
	else if fieldName is 5 then
		set alert_text to (firstname)
	else if fieldName is 6 then
		set alert_text to (firstname & my localized_string("'s birthday"))
	else if fieldName is 7 then
		set alert_text to (firstname & " (" & year of realBirthday & ")")
	else if fieldName is 8 then
		set alert_text to (firstname & " (" & age & " " & my localized_string("in year") & " " & year of nextBirthday & ")")
	else if fieldName is 9 then
		set alert_text to (firstname & " (" & age & ")")
	else if fieldName is 11 then
		--%lastname%, %firstname%, %age%, %yearofbirth%
		--tell me to log "year of realBirthday: " & year of realBirthday		
		set alert_text to alertFormatTxt
		set alert_text to my replaceText("%lastname%", lastname, alert_text)
		set alert_text to my replaceText("%firstname%", firstname, alert_text)
		set alert_text to my replaceText("%yearofbirth%", year of realBirthday as string, alert_text)
		set alert_text to my replaceText("%age%", age as string, alert_text)
		set alert_text to my replaceText("%birthday%", short date string of realBirthday, alert_text)
	else
		set alert_text to (fullname & my localized_string("'s birthday"))
	end if
	return alert_text
end getAlertText


on run {input, parameters}
	global my_version, nodesPlist, my_uid, icalSupportFolder, newCal
	
	-- parameter from nib
	set calendar_name to |ipt_iCalCalendarName| of parameters
	set event_type_index to |ddn_eventType| of parameters as integer
	set alert_type_index to |ddn_alertType| of parameters as integer
	set alert_time_hour_index to |ddn_alertTime_hour| of parameters as integer
	set alert_time_minute_index to |ddn_alertTime_minute| of parameters as integer
	set alert_time_part_index to |ddn_alertTime_part| of parameters as integer
	set alert_alarm_index to ddn_alarm of parameters as integer
	set alert_showFormat_index to ddn_alert_format of parameters as integer
	set alert_showFormat_txt to ipt_alert_format of parameters
	set reminderAlert to spr_reminder of parameters as integer
	set reminderAlert_interval_index to ddn_reminder_interval of parameters as integer
	set reminder_showFormat_index to ddn_reminder_format of parameters as integer
	set reminder_showFormat_txt to ipt_reminder_format of parameters
	set showURL to cbx_url of parameters
	set exportCal to cbx_export of parameters
	
	set error_01 to "There are no entries with birthday data entered in the Address Book."
	set today to current date
	set sourceFile to ""
	set output to ""
	set newCal to false
	
	-- switch the alertTime-Part-Index for fixing the AM/PM 12 o'clock-bug
	if ((alert_time_hour_index + 1) is 12 and alert_time_part_index is 0) then
		set alert_time_part_index to 1
	else if ((alert_time_hour_index + 1) is 12 and alert_time_part_index is 1) then
		set alert_time_part_index to 0
	end if
	set alert_time to (alert_time_hour_index + 1) * 60 + alert_time_minute_index * 15 + alert_time_part_index * 720
	
	try
		tell application "Finder"
			set my_version to (get version) as string
		end tell
		
		-- is Tiger?
		if (my_version < "10.5") then
			set icalSupportFolder to (path to home folder as string) & "Library:Application Support:iCal:"
			set nodesPlist to icalSupportFolder & "nodes.plist"
		else
			set icalSupportFolder to (path to home folder as string) & "Library:Calendars:"
			set nodesPlist to icalSupportFolder & "nodes.plist"
		end if
		
		tell application "Address Book"
			-- get all people with birthday from address book
			set the birthday_people to every person whose birth date is not missing value
			if the birthday_people is {} then error error_01
		end tell
		
		tell application "iCal"
			activate
			
			if (exists calendar the calendar_name) then
				-- set calendar name
				set this_calendar to (the first calendar whose title is the calendar_name)
				
				-- delete old entries from calendar
				delete every event of this_calendar
			else
				make new calendar with properties {name:calendar_name}
				
				-- set calendar name
				set this_calendar to (the first calendar whose title is the calendar_name)
				set newCal to true
			end if
			
			set the people_count to the count of birthday_people
			
			-- run through all people
			repeat with i from 1 to the people_count
				set this_increment to (i / the people_count) as small real
				set progression to this_increment
				
				tell application "Address Book"
					-- get all information about person, birthday, etc.
					set this_person to item i of birthday_people
					set real_birthday to the birth date of this_person
					set this_name to the name of this_person
					set this_firstname to the first name of this_person as string
					set this_lastname to the last name of this_person as string
					
					if this_firstname = "missing value" then
						set this_firstname to this_name
					end if
					
					if this_lastname = "missing value" then
						set this_lastname to this_name
					end if
					
					set this_ID to the id of this_person
					set this_URL to ("addressbook://" & this_ID)
					set the numeric_month to the month of the real_birthday as integer
					set the repeat_string to "FREQ=YEARLY;INTERVAL=1;BYMONTH=" & (numeric_month as string)
					set this_day to the day of the real_birthday as string
					
					-- calculate date of next birthday
					copy real_birthday to next_birthday
					tell next_birthday to set its year to (year of today)
					tell next_birthday to set its time to alert_time * 60 -- set event time
					if next_birthday < today then tell next_birthday to set its year to ((year of today) + 1)
					
					-- calculate age
					set age to ((year of next_birthday) - (year of real_birthday))
					
					-- set alert text
					set this_alert_text to my getAlertText(alert_showFormat_index, alert_showFormat_txt, this_name, this_firstname, this_lastname, age, real_birthday, next_birthday)
				end tell
				
				-- create calendar event
				tell this_calendar
					set eventProperties to {start date:next_birthday, summary:(this_alert_text), recurrence:repeat_string, status:confirmed}
					
					if showURL is true then
						set eventProperties to (eventProperties & {url:this_URL})
					end if
					
					-- set eventType (allday or at event)
					if event_type_index is 0 then
						set eventProperties to (eventProperties & {allday event:true})
					else
						set eventProperties to (eventProperties & {allday event:false})
					end if
					
					-- create event
					set this_event to my createiCalEvent(this_calendar, eventProperties, event_type_index, alert_type_index, alert_time, alert_alarm_index)
					
					-- create reminder
					if reminderAlert > 0 and alert_type_index > 0 then
						set this_alert_reminder_text to my getAlertText(reminder_showFormat_index, reminder_showFormat_txt, this_name, this_firstname, this_lastname, age, real_birthday, next_birthday)
					else
						set this_alert_reminder_text to ""
					end if
					my createiCalEventReminder(this_calendar, this_event, reminderAlert, alert_type_index, reminderAlert_interval_index, alert_time, this_alert_reminder_text, this_alert_text, eventProperties, event_type_index, alert_alarm_index)
				end tell
			end repeat
			set my_uid to uid of this_calendar
		end tell
		
		-- export calender
		if exportCal is true then
			tell application "Finder"
				set theFolder to (container of item (path to me)) as string
			end tell
			
			set exportScriptFile to load script file (theFolder & "export.scpt")
			set output to exportScriptFile's export(calendar_name)
		end if
		
		tell application "iCal" to quit
		tell application "Address Book" to quit
		
		-- display error
	on error error_message number error_number
		if the error_number is not -128 then
			display dialog error_message buttons {"OK"} default button 1
		end if
	end try
	
	return output
end run