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
	CalCalendar *bdayCalendar;
	CalCalendarStore *calendarStore = [CalCalendarStore defaultCalendarStore];
	NSArray *calendars = [calendarStore calendars];
	NSString *calendarName = [[self parameters] objectForKey:@"ipt_iCalCalendarName"];
	
	// look for calendar
	for (CalCalendar *calendar in calendars) {
		if ([calendarName isEqual:[calendar title]]) {
			bdayCalendar = calendar;
			break;
		}
	}
	
	if (bdayCalendar == nil) {		
		// Create an iCal calendar
		bdayCalendar = [CalCalendar calendar];
		bdayCalendar.title = @"iCalBirthdaysTest";
		[calendarStore saveCalendar:bdayCalendar error:&error];
		
		// Save calendar
		if ([calendarStore saveCalendar:bdayCalendar error:&error] == NO){
			NSAlert *alertPanel = [NSAlert alertWithError:error];
			(void) [alertPanel runModal];
		}
	} else {
		// remove all events	
		// remove calendar
//		if ([calendarStore removeCalendar:bdayCalendar error:&error] == NO){
//			NSAlert *alertPanel = [NSAlert alertWithError:error];
//			(void) [alertPanel runModal];
//		} else {
//			bdayCalendar = nil;
//		}
	}
	
	if (bdayCalendar != nil) {		
		NSArray *peopleWithBirthdays = [self getPeopleWithBirthday];
		
		for (BirthdayPerson *person in peopleWithBirthdays) {
			BirthdayEvent *event = [BirthdayEvent event];		
			event.calendar = bdayCalendar;
			event.title = [person eventTitle];
		}
	}
	
	return input;
}

- (NSInteger)getAlertTime {
	NSInteger alertTimeHourIndex = [[[self parameters] objectForKey:@"ddn_alertTime_hour"] integerValue];
	NSInteger alertTimeMinuteIndex = [[[self parameters] objectForKey:@"ddn_alertTime_minute"] integerValue];
	NSInteger alertTimePartIndex = [[[self parameters] objectForKey:@"ddn_alertTime_part"] integerValue];
		
	// switch the alertTime-Part-Index for fixing the AM/PM 12 o'clock-bug
	if ((alertTimeHourIndex + 1) == 12 && alertTimePartIndex == 0) 
	{
		// 12 am = 0:00 (midnight)
		alertTimePartIndex = 0;
		alertTimeHourIndex = -1;
	} else if ((alertTimeHourIndex + 1) == 12 && alertTimePartIndex == 1)
	{
		// 12 pm = 12:00 (noon)
		alertTimePartIndex = 0;
	}
	
	return (alertTimeHourIndex + 1) * 60 + alertTimeMinuteIndex * 15 + alertTimePartIndex * 720;
}

- (NSArray *)getPeopleWithBirthday {	
	ABAddressBook *AB = [ABAddressBook sharedAddressBook];	
	ABSearchElement *withBirthday = [ABPerson searchElementForProperty:kABBirthdayProperty
																 label:nil
																   key:nil
																 value:nil
															comparison:kABNotEqual];	
	NSArray *peopleFound = [AB recordsMatchingSearchElement:withBirthday];
	NSMutableArray *birthdayPeople = [[NSMutableArray alloc] init];
	
	for (ABPerson *person in peopleFound) {
		BirthdayPerson *bdayPerson = [[BirthdayPerson alloc] initWith: person];
		[bdayPerson constructEventTitle:[[[self parameters] objectForKey:@"ddn_alert_format"] integerValue] customTitleText:[[self parameters] objectForKey:@"ipt_alert_format"]];
		[bdayPerson constructEventTitle:[[[self parameters] objectForKey:@"ddn_reminder_format"] integerValue] customTitleText:[[self parameters] objectForKey:@"ipt_reminder_format"]];
		
//		NSLog(@"person: %@ %@ %@ %@", 
//			  [person valueForProperty:kABTitleProperty], 
//			  [person valueForProperty:kABFirstNameProperty], 
//			  [person valueForProperty:kABMiddleNameProperty], 
//			  [person valueForProperty:kABLastNameProperty], 
//			  [person valueForProperty:kABBirthdayProperty]);
		
		NSLog(@"fullname: %@", [bdayPerson fullName]);
		NSLog(@"age: %i", [bdayPerson age]);
		
		[birthdayPeople addObject:bdayPerson];		
	}
	return peopleFound;
}

@end
