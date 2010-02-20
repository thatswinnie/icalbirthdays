//
//  BirthdayEvent.h
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CalendarStore/CalendarStore.h>

//extern NSString * const MyFirstConstant;
#define ALARM_SOUND 0
#define ALARM_MESSAGE 1
#define ALARM_EMAIL 2


@interface BirthdayEvent : CalEvent {	

}

- (BOOL) isAllDayEvent: (NSInteger) eventTypeIndex;
- (NSDate *) constructEventStartDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime;
- (NSDate *) constructEventEndDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime;
- (NSInteger) constructRelativeAlertTime: (NSInteger) alertTime;
- (NSInteger) constructRelativeReminderTime: (NSInteger) reminderTime withAlarmTime: (NSInteger) alertTime;
- (CalAlarm *) createAlarm:(NSInteger)alertTime alarmType:(NSInteger)type fromEmailAddress:(NSString *)email;
- (CalAlarm *) createReminderAlarm:(NSInteger)reminderTime withAlarmTime:(NSInteger)alertTime alarmType:(NSInteger)type fromEmailAddress:(NSString *)email;

@end
