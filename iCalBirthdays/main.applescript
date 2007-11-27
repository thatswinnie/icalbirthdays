-- main.applescript
-- iCalBirthdays

--  Created by Winnie on 20.10.07.
--  Copyright 2007 thatswinnie. All rights reserved.

on getiCalPath(nodesPlist, calendarUID, icalSupportFolder, newCal)
	tell application "Finder"
		--display dialog newCal
		set lastPListDate to modification date of file nodesPlist
		if newCal is true then
			repeat with y from 1 to 20
				set nodesPlistDate to modification date of file nodesPlist
				set iCalFolderDate to modification date of folder icalSupportFolder
				
				if nodesPlistDate > iCalFolderDate and nodesPlistDate > lastPListDate then
					exit repeat
				else
					delay 5
				end if
			end repeat
		end if
	end tell
	
	tell application "System Events"
		set calendarList to property list items of property list item "List" of contents of property list file nodesPlist
		set myCalendarName to ""
		repeat with i from 1 to number of items in calendarList
			set this_name to value of property list item "Key" of item i of calendarList
			if (this_name is calendarUID) then
				set myCalendarName to value of property list item "SourceKey" of item i of calendarList
			end if
		end repeat
	end tell
	return myCalendarName
end getiCalPath


-- get duration
on getiCalDuration(uAlarmTriggerInterval)
	set absoluteAlarmTrigger to uAlarmTriggerInterval
	if absoluteAlarmTrigger < 0 then set absoluteAlarmTrigger to -absoluteAlarmTrigger
	
	-- positive or negative AlarmTrigger
	if uAlarmTriggerInterval > 0 then
		set myAlert to "P"
	else
		set myAlert to "-P"
	end if
	
	set myAlertDay to absoluteAlarmTrigger div (24 * 60)
	set myAlertHour to absoluteAlarmTrigger div 60
	set myAlarmMinute to absoluteAlarmTrigger mod 60
	
	-- days exist
	if myAlertDay > 0 then
		set myAlert to myAlert & myAlertDay & "D"
		
		set myAlertHour to (absoluteAlarmTrigger - myAlertDay * 24 * 60) div 60
		set myAlarmMinute to (absoluteAlarmTrigger - myAlertDay * 24 * 60 - myAlertHour * 60) mod 60
	end if
	
	-- hours exist
	if myAlertHour > 0 then
		set myAlert to myAlert & "T" & myAlertHour & "H"
	end if
	
	-- hours exist
	if myAlarmMinute > 0 then
		set myAlert to myAlert & myAlarmMinute & "M"
	end if
	
	return myAlert
end getiCalDuration


-- export the birthday calendar for Leopard
on exportLeopardCalendar(uCalendarName, uSourceWriteFile)
	try
		
		tell application "iCal"
			activate
			
			-- create ics file
			set fRef to (open for access file uSourceWriteFile with write permission)
			set eof fRef to 0
			write "BEGIN:VCALENDAR
" to fRef
			write "VERSION:2.0

" to fRef
			
			repeat with aEvent in events of calendar uCalendarName
				set mySummary to summary of aEvent as string
				set myUID to uid of aEvent as string
				set mySequence to sequence of aEvent as string
				set myRecurrence to recurrence of aEvent as string
				set myURL to url of aEvent as string
				set myStatus to status of aEvent as string
				set myCreated to stamp date of aEvent as string
				
				-- set start date
				set theDate to start date of aEvent
				set {year:y, month:m, day:d} to result
				y * 10000
				result + m * 100
				result + d
				set startDate to result as string
				
				-- set end date
				set theDate to end date of aEvent
				set {year:y, month:m, day:d} to result
				y * 10000
				result + m * 100
				result + d
				set endDate to result as string
				
				-- write the event
				write "BEGIN:VEVENT
" to fRef
				write "SUMMARY:" & mySummary & "
" to fRef as «class utf8»
				write "TRANSP:TRANSPARENT" & "
" to fRef
				write "UID:" & myUID & "
" to fRef
				write "SEQUENCE:" & mySequence & "
" to fRef
				write "DTSTART;VALUE=DATE:" & startDate & "
" to fRef
				write "DTEND;VALUE=DATE:" & endDate & "
" to fRef
				write "RRULE:" & myRecurrence & "
" to fRef
				write "URL:" & myURL & "
				
" to fRef
				
				-- get the alarms
				set itemCount to the count of items of sound alarm of aEvent
				repeat with i from 1 to the itemCount
					set myAlarm to item i of sound alarm of aEvent
					set myAlarmTriggerInterval to trigger interval of myAlarm
					set myAlarmSoundName to sound name of myAlarm
					set myAlarmTime to my getiCalDuration(myAlarmTriggerInterval)
					
					write "BEGIN:VALARM
" to fRef
					write "ACTION:AUDIO" & "
" to fRef
					write "TRIGGER:" & myAlarmTime & "
" to fRef
					write "ATTACH;VALUE=URI:" & myAlarmSoundName & "
" to fRef
					write "END:VALARM

" to fRef
				end repeat
				
				write "END:VEVENT


" to fRef
			end repeat
			
			write "END:VCALENDAR" to fRef
			close access fRef
		end tell
		
		-- display error
	on error error_message number error_number
		if the error_number is not -128 then
			display dialog error_message buttons {"OK"} default button 1
		end if
	end try
end exportLeopardCalendar



on run {input, parameters}
	global these_people, people_IDs
	
	set calendar_name to |iCalCalendarName| of parameters
	set alert_time_hour_index to |alertTime_hour| of parameters
	set alert_time_minute_index to |alertTime_minute| of parameters
	set alert_time_part_index to |alertTime_part| of parameters
	set additionalAlert to |additionalAlert| of parameters
	set additionalAlert_interval_index to |additionalAlert_interval| of parameters
	set alert_type_index to |alertType| of parameters
	set error_01 to "There are no entries with birthday data entered in the Address Book."
	set calendar_entry to "'s birthday"
	set today to date (date string of (current date) & " 12:00:00 AM")
	set sourceFile to ""
	set output to ""
	set newCal to false
	
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
			set these_people to {}
			set the people_IDs to {}
			
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
					set this_ID to the id of this_person
					set this_URL to ("addressbook://" & this_ID)
					set the numeric_month to the month of the real_birthday as integer
					set the repeat_string to "FREQ=YEARLY;INTERVAL=1;BYMONTH=" & (numeric_month as string)
					set this_day to the day of the real_birthday as string
					
					-- calculate date of next birthday
					copy real_birthday to next_birthday
					tell next_birthday to set its year to (year of today)
					if next_birthday < today then tell next_birthday to set its year to ((year of today) + 1)
				end tell
				
				-- create calendar event
				tell this_calendar
					set this_event to (make new event at end of events with properties {start date:next_birthday, summary:(this_name & calendar_entry), recurrence:repeat_string, allday event:true, url:this_URL, status:confirmed})
					
					if alert_type_index is not 1 then
						-- adding alarm to the event
						tell this_event
							make new sound alarm at end of sound alarms with properties {trigger interval:alert_time}
						end tell
					end if
					
					-- additional alert
					if additionalAlert > 0 and alert_type_index > 0 then
						if additionalAlert_interval_index is 0 then
							set next_additional_birthday to (alert_time - additionalAlert * 60 * 24)
						else if additionalAlert_interval_index is 1 then
							set next_additional_birthday to (alert_time - additionalAlert * 60 * 24 * 7)
						else
							set next_additional_birthday to alert_time
						end if
						
						-- adding alarm to the event
						tell this_event
							make new sound alarm at end of sound alarms with properties {trigger interval:next_additional_birthday}
						end tell
						
					end if
				end tell
			end repeat
			set my_uid to uid of this_calendar
		end tell
		
		-- is Tiger?
		if (my_version < "10.5") then
			set my_calendarPath to my getiCalPath(nodesPlist, my_uid, icalSupportFolder & "Sources", newCal)
			set sourceFile to icalSupportFolder & "Sources:" & my_calendarPath & ".calendar:corestorage.ics"
			set output to sourceFile as alias
		else
			set sourceEventFile to icalSupportFolder & my_uid & ".calendar"
			set sourceWriteFile to (path to documents folder as string) & "birthdays.ics"
			my exportLeopardCalendar(calendar_name, sourceWriteFile)
			set output to sourceWriteFile as alias
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