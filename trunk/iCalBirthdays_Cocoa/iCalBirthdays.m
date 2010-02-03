//
//  iCalBirthdays.m
//  iCalBirthdays
//
//  Created by thatswinnie on 1/25/10.
//  Copyright (c) 2010 __MyCompanyName__, All Rights Reserved.
//

#import "iCalBirthdays.h"


@implementation iCalBirthdays

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	NSError *error;	
	CalCalendar *bdayCalendar = nil;
	CalCalendarStore *calendarStore = [CalCalendarStore defaultCalendarStore];
	NSArray *calendars = [calendarStore calendars];
	NSString *calendarName = [[self parameters] objectForKey:@"ipt_iCalCalendarName"];
	
	// look for calendar
	for (CalCalendar *aCalendar in calendars) {
		if ([calendarName isEqual:[aCalendar title]]) {
			bdayCalendar = [aCalendar retain];
			break;
		}
	}
	
	if (bdayCalendar == nil) {		
		// Create an iCal calendar
		bdayCalendar = [CalCalendar calendar];
		bdayCalendar.title = calendarName;
		[calendarStore saveCalendar:bdayCalendar error:&error];
		
		// Save calendar
		if ([calendarStore saveCalendar:bdayCalendar error:&error] == NO){
			NSAlert *alertPanel = [NSAlert alertWithError:error];
			(void) [alertPanel runModal];
		}
	} else {
		// remove all events				
		//NSPredicate *eventPredicate = [NSPredicate predicateWithFormat: @"calendar IN %@", [NSArray arrayWithObject: [NSArray arrayWithObject:bdayCalendar]]];
		
		//NSPredicate *eventPredicate = [NSPredicate predicateWithFormat:@"calendar IN (%@)" argumentArray:[NSArray arrayWithObject: [NSArray arrayWithObject:bdayCalendar]]];
		
		//NSPredicate *eventPredicate = [CalCalendarStore eventPredicateWithStartDate: nil endDate: nil calendars: bdayCalendar];
		//NSPredicate *eventPredicate = [CalCalendarStore eventPredicateWithStartDate:[NSDate distantPast] endDate:[NSDate distantFuture] calendars:[NSArray arrayWithObject:bdayCalendar]];
//		NSPredicate *eventPredicate = [CalCalendarStore eventPredicateWithStartDate:[NSDate distantPast] endDate:[NSDate distantFuture] calendars:calendars];
//		NSLog(@"predicate: %@", [eventPredicate predicateFormat]);
//		
//		NSArray *calEvents = [calendarStore eventsWithPredicate: eventPredicate];
//		NSLog(@"events: %@", [calEvents count]);
		
		// remove calendar
		if ([calendarStore removeCalendar:bdayCalendar error:&error] == NO){
			NSAlert *alertPanel = [NSAlert alertWithError:error];
			(void) [alertPanel runModal];
		} else {
			bdayCalendar = nil;
		}
	}
	
	if (bdayCalendar != nil) {		
		NSArray *peopleWithBirthdays = [self getPeopleWithBirthday];
		
		for (BirthdayPerson *person in peopleWithBirthdays) {
			BirthdayEvent *event = [[BirthdayEvent alloc] init];
			event.calendar = bdayCalendar;
			event.title = person.eventTitle;
			
			event.isAllDay = [event isAllDayEvent: [[[self parameters] objectForKey:@"ddn_eventType"] integerValue]];
			event.startDate = [event constructAlertStartDate: [person valueForProperty:kABBirthdayProperty] alertTime: [self getAlertTime]];
			event.endDate = [event constructAlertEndDate: [person valueForProperty:kABBirthdayProperty] alertTime: [self getAlertTime]];
			
			// recurring event
			event.recurrenceRule = [[[CalRecurrenceRule alloc] initYearlyRecurrenceWithInterval:1 end:nil] autorelease];
			
			// alarm for event
			[event addAlarm: [event createAlarm: [self getAlertTime]]];
			
			// Save changes to an event
			if ([calendarStore saveEvent:event span:CalSpanThisEvent error:&error] == NO){
				NSAlert *alertPanel = [NSAlert alertWithError:error];
				(void) [alertPanel runModal];
			}
			[person release];	
			[event release];	
		}
		[peopleWithBirthdays release];	
	}
	
	return input;
}

- (NSInteger) getAlertTime {
	NSInteger alertTimeHourIndex = [[[self parameters] objectForKey:@"ddn_alertTime_hour"] integerValue];
	NSInteger alertTimeMinuteIndex = [[[self parameters] objectForKey:@"ddn_alertTime_minute"] integerValue];
	NSInteger alertTimePartIndex = [[[self parameters] objectForKey:@"ddn_alertTime_part"] integerValue];
		
	// switch the alertTime-Part-Index for fixing the AM/PM 12 o'clock-bug
	if ((alertTimeHourIndex + 1) == 12 && alertTimePartIndex == 0) 
	{
		// 12 am = 0:00 (midnight)
		alertTimePartIndex = 0;
		alertTimeHourIndex = -1;
	} 
	else if ((alertTimeHourIndex + 1) == 12 && alertTimePartIndex == 1)
	{
		// 12 pm = 12:00 (noon)
		alertTimePartIndex = 0;
	}
	
	// birthday is always 12 pm = noon
	alertTimePartIndex = alertTimePartIndex - 1;
	
	return ((alertTimeHourIndex + 1) * 60 *60) 
				+ (alertTimeMinuteIndex * 15 * 60)
				+ (alertTimePartIndex * 12 * 60 * 60);
}


- (NSArray *)getPeopleWithBirthday {	
	ABSearchElement *withBirthday = [ABPerson searchElementForProperty:kABBirthdayProperty
																 label:nil
																   key:nil
																 value:nil
															comparison:kABNotEqual];	
	NSArray *peopleFound = [[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:withBirthday];
	NSMutableArray *birthdayPeople = [[NSMutableArray alloc] init];
	
	for (ABPerson *person in peopleFound) {
		BirthdayPerson *bdayPerson = [[BirthdayPerson alloc] initWith: person];
		
		bdayPerson.eventTitle = [bdayPerson constructEventTitle:[[[self parameters] objectForKey:@"ddn_alert_format"] integerValue] customTitleText:[[self parameters] objectForKey:@"ipt_alert_format"]];
		bdayPerson.reminderTitle = [bdayPerson constructReminderTitle:[[[self parameters] objectForKey:@"ddn_reminder_format"] integerValue] customTitleText:[[self parameters] objectForKey:@"ipt_reminder_format"]];
		
		[birthdayPeople addObject:bdayPerson];		
	}
	
	return birthdayPeople;
}

@end
