-- main.applescript
-- iCalBirthdays

--  Created by Winnie on 20.10.07.
--  Copyright 2007 thatswinnie. All rights reserved.

on getiCalPath(nodesPlist, calendarUID)
	tell application "System Events"
		set calendarList to property list items of property list item "List" of contents of property list file nodesPlist
		set myCalendarName to ""
		repeat with i from 1 to count of calendarList
			set this_name to value of property list item "Key" of item i of calendarList
			if (this_name is calendarUID) then
				set myCalendarName to value of property list item "SourceKey" of item i of calendarList
			end if
		end repeat
	end tell
	return myCalendarName
end getiCalPath

-- export the birthday calendar for Leopard
on exportLeopardCalendar(uCalendarName, uSourceFile)
	set icsData to ""
	try
		tell application "iCal"
			activate
			set this_calendar to (the first calendar whose title is the uCalendarName)
			set numCalendarItems to count events of this_calendar
			repeat with n from 1 to numCalendarItems
				set thisEvent to event n of this_calendar
				set myEventUID to uid of thisEvent
				set sourceEventFile to uSourceFile & ":Events:" & myEventUID & ".ics"
				
				-- try
				repeat with y from 1 to 5
					try
						alias sourceEventFile
					on error
						delay 3
					end try
					exit repeat
				end repeat
				
				set fileObj to open for access file sourceEventFile
				set myFileContent to read fileObj using delimiter return
				set x to count of items in myFileContent
				set isInICS to false
				repeat with z from 1 to x
					if n is 1 and (item z of myFileContent does not contain "END:VCALENDAR") then
						set icsData to icsData & item z of myFileContent
					else
						if isInICS is true then
							set icsData to icsData & item z of myFileContent
							if n is not numCalendarItems and item z of myFileContent contains "END:VEVENT" then
								set isInICS to false
							end if
						else
							if (z + 1) < x or (z + 1) is x then
								if item (z + 1) of myFileContent contains "BEGIN:VEVENT" then
									set isInICS to true
								end if
							end if
						end if
					end if
				end repeat
				close access fileObj
			end repeat
		end tell
		-- display error
	on error error_message number error_number
		if the error_number is not -128 then
			display dialog error_message buttons {"OK"} default button 1
		end if
	end try
	return icsData
end exportLeopardCalendar

on run {input, parameters}
	global these_people, people_IDs
	
	set calendar_name to |iCalCalendarName| of parameters
	set alert_time_hour_index to |alertTime_hour| of parameters
	set alert_time_minute_index to |alertTime_minute| of parameters
	set alert_time_part_index to |alertTime_part| of parameters
	set additionalAlert to |additionalAlert| of parameters
	set additionalAlert_type_index to |additionalAlert_type| of parameters
	set additionalAlert_text to |additionalAlert_text| of parameters
	set error_01 to "There are no entries with birthday data entered in the Address Book."
	set calendar_entry to "'s birthday"
	set calendar_additional_entry to "'s birthday, " & additionalAlert_text
	set today to date (date string of (current date) & " 12:00:00 AM")
	set sourceFile to ""
	set output to ""
	
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
					
					-- adding alarm to the event
					tell this_event
						make new sound alarm at end of sound alarms with properties {trigger interval:alert_time}
					end tell
					
					-- additional alert
					if additionalAlert > 0 then
						if additionalAlert_type_index is 0 then
							set next_additional_birthday to (next_birthday - additionalAlert * days)
						else if additionalAlert_type_index is 1 then
							set next_additional_birthday to (next_birthday - additionalAlert * weeks)
						else
							set next_additional_birthday to next_birthday
						end if
						set this_additional_event to (make new event at end of events with properties {start date:next_additional_birthday, end date:next_additional_birthday, summary:(this_name & calendar_additional_entry), recurrence:repeat_string, allday event:true, url:this_URL, status:confirmed})
						
						-- adding alarm to the event
						tell this_additional_event
							make new sound alarm at end of sound alarms with properties {trigger interval:alert_time}
						end tell
						
					end if
				end tell
			end repeat
			set my_uid to uid of this_calendar
		end tell
		
		-- is Tiger?
		if (my_version < "10.5") then
			set my_calendarPath to my getiCalPath(nodesPlist, my_uid)
			set sourceFile to icalSupportFolder & "Sources:" & my_calendarPath & ".calendar:corestorage.ics"
			set output to sourceFile as alias
		else
			set sourceEventFile to icalSupportFolder & my_uid & ".calendar"
			set icsData to my exportLeopardCalendar(calendar_name, sourceEventFile)
			set sourceWriteFile to (path to documents folder as string) & "birthdays.ics"
			
			-- create ics file
			set writeFileHandler to open for access file sourceWriteFile with write permission
			try
				set eof of writeFileHandler to 0
				write icsData to writeFileHandler
				close access writeFileHandler
			on error
				close access writeFileHandler
			end try
			set output to sourceWriteFile as alias
		end if
		
		-- tell application "iCal" to save this_calendar in output
		
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