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


on run {input, parameters}
	global these_people, people_IDs
	
	set calendar_name to |iCalCalendarName| of parameters
	set alert_time_hour_index to |alertTime_hour| of parameters
	set alert_time_minute_index to |alertTime_minute| of parameters
	set alert_time_part_index to |alertTime_part| of parameters
	set error_01 to "There are no entries with birthday data entered in the Address Book."
	set calendar_entry to "'s birthday"
	set this_year to (the year of (current date)) as string
	set icalSupportFolder to (path to home folder as string) & "Library:Application Support:iCal:"
	set nodesPlist to icalSupportFolder & "nodes.plist"
	set sourceFile to ""
	set output to ""
	
	set alert_time to (alert_time_hour_index + 1) * 60 + alert_time_minute_index * 15 + alert_time_part_index * 720
	
	try
		tell application "Address Book"
			set these_people to {}
			set the people_IDs to {}
			
			-- get all people with birthday from address book
			set the birthday_people to every person whose birth date is not missing value
			if the birthday_people is {} then error error_01
		end tell
		
		tell application "iCal"
			activate
			
			-- set calendar name
			set this_calendar to (the first calendar whose title is the calendar_name)
			
			if (exists calendar the calendar_name) then
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
					set relative_birthday to real_birthday
				end tell
				
				-- create calendar event
				tell this_calendar
					set this_event to make new event at end of events with properties {start date:relative_birthday, summary:(this_name & calendar_entry), recurrence:repeat_string, allday event:true, url:this_URL, status:confirmed}
					
					-- adding alarm to the event
					tell this_event
						make new sound alarm at end of sound alarms with properties {trigger interval:alert_time}
					end tell
					
				end tell
			end repeat
			
			set my_uid to uid of this_calendar
		end tell
		
		tell application "iCal" to quit
		tell application "Address Book" to quit
		set my_calendarPath to my getiCalPath(nodesPlist, my_uid)
		set sourceFile to icalSupportFolder & "Sources:" & my_calendarPath & ".calendar:corestorage.ics"
		set output to sourceFile as alias
		
		-- display error
	on error error_message number error_number
		if the error_number is not -128 then
			display dialog error_message buttons {"OK"} default button 1
		end if
	end try
	
	return output
end run