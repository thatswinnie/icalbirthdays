//
//  iCalBirthdays.m
//  iCalBirthdays
//
//  Created by thatswinnie on 1/25/10.
//  Copyright (c) 2010 thatswinnie, All Rights Reserved.
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
	BOOL showUrl = [[[self parameters] objectForKey:@"cbx_url"] boolValue];
	
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
		[self removeExistingCalendarEventsFromCalendar: bdayCalendar calendarStore: calendarStore];
	}
	
	if (bdayCalendar != nil) {		
		NSDictionary *peopleWithBirthdays = [self getPeopleWithBirthday];
		NSEnumerator *enumerator = [peopleWithBirthdays objectEnumerator];
		id person;
		
		while ((person = [enumerator nextObject])) {		
		//for (BirthdayPerson *person in peopleWithBirthdays) {
			BirthdayEvent *event = [[BirthdayEvent alloc] init];
			event.calendar = bdayCalendar;
			event.title = [person eventTitle];
			
			event.isAllDay = [event isAllDayEvent: [[[self parameters] objectForKey:@"ddn_eventType"] integerValue]];
			event.startDate = [event constructEventStartDate: [person valueForProperty:kABBirthdayProperty] alertTime: [self getEventTime]];
			event.endDate = [event constructEventEndDate: [person valueForProperty:kABBirthdayProperty] alertTime: [self getEventTime]];
			
			if (showUrl) {
				event.url = [person addressbookUrl];
			}
			
			// recurring event
			event.recurrenceRule = [[[CalRecurrenceRule alloc] initYearlyRecurrenceWithInterval:1 end:nil] autorelease];
			
			// alarm for event
			[event addAlarm: [event createAlarm: [self getAlertTime]]];
			
			// Save changes to an event
			if ([calendarStore saveEvent:event span:CalSpanThisEvent error:&error] == NO){
				NSAlert *alertPanel = [NSAlert alertWithError:error];
				(void) [alertPanel runModal];
			}
			[event release];	
		}
	}
	
	return input;
}


- (NSInteger) getEventTime {
	// remove half a day of time because birthday is always 12 pm = noon
	return [self getAlertTime] - (12 * 60 * 60);
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
	
	return ((alertTimeHourIndex + 1) * 60 *60) 
				+ (alertTimeMinuteIndex * 15 * 60)
				+ (alertTimePartIndex * 12 * 60 * 60);
}


- (NSDictionary *)getPeopleWithBirthday {	
	ABSearchElement *withBirthday = [ABPerson searchElementForProperty:kABBirthdayProperty
																 label:nil
																   key:nil
																 value:nil
															comparison:kABNotEqual];	
	NSArray *peopleFound = [[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:withBirthday];
	NSMutableDictionary *birthdayPeopleDict = [NSMutableDictionary dictionary];
	
	for (ABPerson *person in peopleFound) {
		NSString *dictKey = [person uniqueId];
		
		if ([birthdayPeopleDict valueForKey: dictKey] == nil) {
			BirthdayPerson *bdayPerson = [[BirthdayPerson alloc] initWithABPerson: person];
			
			bdayPerson.eventTitle = [bdayPerson constructEventTitle:[[[self parameters] objectForKey:@"ddn_alert_format"] integerValue] customTitleText:[[self parameters] objectForKey:@"ipt_alert_format"]];
			bdayPerson.reminderTitle = [bdayPerson constructReminderTitle:[[[self parameters] objectForKey:@"ddn_reminder_format"] integerValue] customTitleText:[[self parameters] objectForKey:@"ipt_reminder_format"]];
			
			[birthdayPeopleDict setValue: bdayPerson forKey: dictKey];
			[bdayPerson release];
		}
	}
	
	return birthdayPeopleDict;
}


#pragma mark remove Events

- (NSArray *)allEventUIDsForCalendar:(CalCalendar *)calendarObject
{
	NSString *libraryDirectory = [NSHomeDirectory() stringByAppendingPathComponent: @"Library"];
	NSString *calendarPathString = [[[[libraryDirectory stringByAppendingPathComponent: @"Calendars"] stringByAppendingPathComponent:calendarObject.uid] stringByAppendingPathExtension:@"calendar"] stringByAppendingPathComponent:@"Events"];
	NSString *calendarEntryExtension = @"ics";
	
	NSMutableArray *allEventArray = [NSMutableArray array];
	NSDirectoryEnumerator *calendarDirectoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:calendarPathString];
	NSString *intermediateEventFilename;
	
	while (intermediateEventFilename = [calendarDirectoryEnumerator nextObject])
	{
		if ([[intermediateEventFilename pathExtension] isEqualToString:calendarEntryExtension])
		{
			NSString *uidString = [intermediateEventFilename stringByDeletingPathExtension];
			uuid_t converteduuid;
			
			if ((36==[uidString length]) && (0==uuid_parse([uidString UTF8String], converteduuid)))
			{
				[allEventArray addObject:uidString];
			}
		}
	}
	return allEventArray;
}


- (void) removeExistingCalendarEventsFromCalendar: (CalCalendar *)calendarObject calendarStore: (CalCalendarStore *) calendarStore {
	NSError *error;	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.year = -4;
	NSDate *todayBefore4Years = [calendar dateByAddingComponents: components toDate: [NSDate date] options:0];
	[components release];		
	
	NSArray *calEventUIDs = [self allEventUIDsForCalendar: calendarObject];
	NSMutableArray *removedCalEventUIDs = [NSMutableArray array];
	NSLog(@"events: %i", [calEventUIDs count]);
	
	for (NSString *eventUID in calEventUIDs) {			
		NSPredicate *eventPredicate = [CalCalendarStore eventPredicateWithStartDate: todayBefore4Years endDate: [NSDate date] UID: eventUID calendars: [NSArray arrayWithObject: calendarObject]];
		NSArray *calEvents = [calendarStore eventsWithPredicate: eventPredicate];
		
		if ([calEvents count] > 0) {
			// only remove first event because it's reoccuring
			CalEvent *aEvent = [calEvents objectAtIndex: 0];
			if ([calendarStore removeEvent: aEvent span: CalSpanAllEvents error: &error] == NO){
				NSAlert *alertPanel = [NSAlert alertWithError:error];
				(void) [alertPanel runModal];
			} else {
				// add CalEvent UID to removed array
				[removedCalEventUIDs addObject: eventUID];
			}
		}
	}
	NSLog(@"events removed: %i", [removedCalEventUIDs count]);
	
	if ([calEventUIDs count] > [removedCalEventUIDs count]) {
		// remove all events from the last 4 years
		NSPredicate *eventPredicate = [CalCalendarStore eventPredicateWithStartDate: todayBefore4Years endDate: [NSDate date] calendars: [NSArray arrayWithObject: calendarObject]];
		NSArray *calEvents = [calendarStore eventsWithPredicate: eventPredicate];
		
		if ([calEvents count] > 0) {
			for (CalEvent *aEvent in calEvents) {	
				if ([calendarStore removeEvent: aEvent span: CalSpanAllEvents error: &error] == NO){
					NSAlert *alertPanel = [NSAlert alertWithError:error];
					(void) [alertPanel runModal];
				}
			}
		}
	}
}

@end
