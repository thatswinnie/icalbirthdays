//
//  BirthdayEvent.h
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CalendarStore/CalendarStore.h>

#define ALARM_SOUND 0
#define ALARM_MESSAGE 1
#define ALARM_EMAIL 2

#define TIMEPERIOD_SINCE_BIRTH 0
#define TIMEPERIOD_CURRENT_YEAR 1
#define TIMEPERIOD_NEXT_YEAR 2


@interface BirthdayEvent : CalEvent {	

}

- (BOOL) isAllDayEvent: (NSInteger) eventTypeIndex;
- (NSDate *) constructEventDate:(NSDate *)birthdayDate inTimePeriod:(NSInteger)period;
- (NSDate *) constructEventStartDate:(NSDate *)birthdayDate alertTime:(NSInteger)alertTime inTimePeriod:(NSInteger)period;
- (NSDate *) constructEventEndDate:(NSDate *)birthdayDate alertTime:(NSInteger)alertTime inTimePeriod:(NSInteger)period;
- (NSInteger) constructRelativeAlertTime: (NSInteger) alertTime;
- (NSInteger) constructRelativeReminderTime: (NSInteger) reminderTime withAlarmTime: (NSInteger) alertTime;
- (CalAlarm *) createAlarm:(NSInteger)alertTime alarmType:(NSInteger)type fromEmailAddress:(NSString *)email;
- (CalAlarm *) createReminderAlarm:(NSInteger)reminderTime withAlarmTime:(NSInteger)alertTime alarmType:(NSInteger)type fromEmailAddress:(NSString *)email;

@end
