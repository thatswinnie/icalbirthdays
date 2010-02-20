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
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	
	// find 'me' card in address book
	ABPerson *meCard = [[ABAddressBook sharedAddressBook] me];
	if (meCard == nil) {
		NSString *errorString = [thisBundle localizedStringForKey:@"no own card" value:@"ERROR: You have no own card in Address Book." table:nil];
		*errorInfo = [NSDictionary dictionaryWithObjectsAndKeys: [errorString autorelease], NSAppleScriptErrorMessage, nil];		
		return nil;
	}
	
	// check if email exists
	// TODO
	if ([[[self parameters] objectForKey:@"ddn_alarm"] integerValue] == 2 && [self findEmailFromMyCard] == nil) {		
		NSString *errorString = [thisBundle localizedStringForKey:@"no primary email on own card" value:@"ERROR: Your own card has no primary email address." table:nil];
		*errorInfo = [NSDictionary dictionaryWithObjectsAndKeys: [errorString autorelease], NSAppleScriptErrorMessage, nil];		
		return nil;
	}
	
	
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
			BirthdayEvent *event = [self createBirthdayEventForPerson:person inCalendar:bdayCalendar showAddressBookUrl:showUrl calendarStore:calendarStore];
			
			if ([[[self parameters] objectForKey:@"ddn_alertType"] integerValue] != 0 && [self getReminderTime] > 0) {
				if ([[person eventTitle] isEqual:[person reminderTitle]]) {
					[self addReminderToEvent:event forPerson:person calendarStore:calendarStore];
				} else {
					// create seperate event
					[self createReminderEventForPerson:person inCalendar:bdayCalendar showAddressBookUrl:showUrl calendarStore:calendarStore];
				}
			}
		}
	}
	
	return input;
}


- (void)updateParameters
{
	
}


- (void)parametersUpdated
{
//	if ([[[self parameters] objectForKey:@"ddn_alertType"] integerValue] == 0) {
//		// deactivate reminder
//		[[self parameters] setObject:[NSNumber numberWithInt:[_interactiveType selectedRow]] forKey:@"spr_reminder"];
//	} else {
//		// activate reminder
//	}
}


- (NSInteger) getEventTime 
{
	// remove half a day of time because birthday is always 12 pm = noon
	return [self getAlertTime] - (12 * 60 * 60);
}


- (NSInteger) getAlertTime 
{
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
	
	return ((alertTimeHourIndex + 1) * 60 * 60) 
				+ (alertTimeMinuteIndex * 15 * 60)
				+ (alertTimePartIndex * 12 * 60 * 60);
}


- (NSInteger) getReminderTime 
{
	NSInteger reminderQuantity = [[[self parameters] objectForKey:@"spr_reminder"] integerValue];
	NSInteger reminderIntervalIndex = [[[self parameters] objectForKey:@"ddn_reminder_interval"] integerValue];
	
	if (reminderIntervalIndex == 0) {
		// days
		return (reminderQuantity * 24 * 60 * 60);
	} else {
		// weeks
		return (reminderQuantity * 7 * 24 * 60 * 60);
	}
}


- (NSDate *) getReminderDateForPerson: (id) person
{
	NSDate *birthdayDate = [person valueForProperty:kABBirthdayProperty];	
	return [birthdayDate dateByAddingTimeInterval: -[self getReminderTime]];
}


- (NSDictionary *)getPeopleWithBirthday 
{	
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



#pragma mark Event creation

- (BirthdayEvent *)createBirthdayEventForPerson: (id) person inCalendar: (CalCalendar *) calendar showAddressBookUrl: (BOOL) showUrl  calendarStore: (CalCalendarStore *) calendarStore
{
	NSError *error;	
	BirthdayEvent *event = [[[BirthdayEvent alloc] init] autorelease];
	event.calendar = calendar;
	event.title = [person eventTitle];
	
	event.isAllDay = [event isAllDayEvent: [[[self parameters] objectForKey:@"ddn_eventType"] boolValue]];
	event.startDate = [event constructEventStartDate: [person valueForProperty:kABBirthdayProperty] alertTime: [self getEventTime]];
	event.endDate = [event constructEventEndDate: [person valueForProperty:kABBirthdayProperty] alertTime: [self getEventTime]];
	
	if (showUrl) {
		event.url = [person addressbookUrl];
	}
	
	// recurring event
	event.recurrenceRule = [[[CalRecurrenceRule alloc] initYearlyRecurrenceWithInterval:1 end:nil] autorelease];
	
	// alarm for event
	[event addAlarm: [event createAlarm: [self getAlertTime] alarmType: [[[self parameters] objectForKey:@"ddn_alarm"] integerValue]fromEmailAddress: [self findEmailFromMyCard]]];
	
	// Save changes to an event
	if ([calendarStore saveEvent:event span:CalSpanAllEvents error:&error] == NO){
		NSAlert *alertPanel = [NSAlert alertWithError:error];
		(void) [alertPanel runModal];
	}
	return event;
}


- (BirthdayEvent *)addReminderToEvent: (BirthdayEvent *) event forPerson: (id) person calendarStore: (CalCalendarStore *) calendarStore
{
	NSError *error;
	
	[event addAlarm: [event createReminderAlarm: [self getReminderTime] withAlarmTime: [self getAlertTime] alarmType: [[[self parameters] objectForKey:@"ddn_alarm"] integerValue] fromEmailAddress: [self findEmailFromMyCard]]];
	
	// Save changes to an event
	if ([calendarStore saveEvent:event span:CalSpanAllEvents error:&error] == NO){
		NSAlert *alertPanel = [NSAlert alertWithError:error];
		(void) [alertPanel runModal];
	}
	
	return event;	
}


- (BirthdayEvent *)createReminderEventForPerson: (id) person inCalendar: (CalCalendar *) calendar showAddressBookUrl: (BOOL) showUrl  calendarStore: (CalCalendarStore *) calendarStore
{
	NSError *error;	
	BirthdayEvent *event = [[[BirthdayEvent alloc] init] autorelease];
	event.calendar = calendar;
	event.title = [person reminderTitle];
	
	event.isAllDay = [event isAllDayEvent: [[[self parameters] objectForKey:@"ddn_eventType"] boolValue]];
	event.startDate = [event constructEventStartDate: [self getReminderDateForPerson:person] alertTime: [self getEventTime]];
	event.endDate = [event constructEventEndDate: [self getReminderDateForPerson:person] alertTime: [self getEventTime]];
	
	if (showUrl) {
		event.url = [person addressbookUrl];
	}
	
	// recurring event
	event.recurrenceRule = [[[CalRecurrenceRule alloc] initYearlyRecurrenceWithInterval:1 end:nil] autorelease];
	
	// alarm for event
	[event addAlarm: [event createAlarm: [self getAlertTime] alarmType: [[[self parameters] objectForKey:@"ddn_alarm"] integerValue] fromEmailAddress: [self findEmailFromMyCard]]];
	
	// Save changes to an event
	if ([calendarStore saveEvent:event span:CalSpanAllEvents error:&error] == NO){
		NSAlert *alertPanel = [NSAlert alertWithError:error];
		(void) [alertPanel runModal];
	}
	return event;
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

-(NSString *)findEmailFromMyCard {	
	// find 'me' card in address book
	ABPerson *meCard = [[ABAddressBook sharedAddressBook] me];
	NSString *anEmail = nil;
	
    // Find primary email address
    ABMutableMultiValue *anEmailList = [[meCard valueForProperty:kABEmailProperty] mutableCopy];
	if ([anEmailList count] > 0) {
		int primaryIndex = [anEmailList indexForIdentifier:[anEmailList primaryIdentifier]];
		anEmail = [[anEmailList valueAtIndex:primaryIndex] mutableCopy];
	}
	[anEmailList release];
	return anEmail;
}

@end
