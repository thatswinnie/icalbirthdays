//
//  iCalBirthdays.h
//  iCalBirthdays
//
//  Created by thatswinnie on 1/25/10.
//  Copyright (c) 2010 thatswinnie, All Rights Reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>
#import <AddressBook/AddressBook.h>
#import <BirthdayPerson.h>
#import <BirthdayEvent.h>

@interface iCalBirthdays : AMBundleAction 
{
}

- (id) runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;
- (NSInteger) getEventTime;
- (NSInteger) getAlertTime;
- (NSDictionary *) getPeopleWithBirthday;
- (NSArray *) allEventUIDsForCalendar: (CalCalendar *)calendarObject;
- (void) removeExistingCalendarEventsFromCalendar: (CalCalendar *)calendarObject calendarStore: (CalCalendarStore *) calendarStore;

@end
