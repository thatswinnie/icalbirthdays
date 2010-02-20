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
- (NSInteger) getReminderTime;
- (NSDictionary *) getPeopleWithBirthday;
- (NSDate *) getReminderDateForPerson: (id) person;

- (BirthdayEvent *)createBirthdayEventForPerson:(id)person inCalendar:(CalCalendar *)calendar showAddressBookUrl:(BOOL)showUrl  calendarStore:(CalCalendarStore *)calendarStore;
- (BirthdayEvent *)addReminderToEvent:(BirthdayEvent *)event forPerson:(id)person calendarStore:(CalCalendarStore *)calendarStore;
- (BirthdayEvent *)createReminderEventForPerson: (id) person inCalendar: (CalCalendar *) calendar showAddressBookUrl: (BOOL) showUrl  calendarStore: (CalCalendarStore *) calendarStore;

- (NSArray *)allEventUIDsForCalendar:(CalCalendar *)calendarObject;
- (void) removeExistingCalendarEventsFromCalendar:(CalCalendar *)calendarObject calendarStore:(CalCalendarStore *)calendarStore;

-(NSString *)findEmailFromMyCard;

@end
