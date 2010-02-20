//
//  BirthdayEvent.m
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BirthdayEvent.h"


@implementation BirthdayEvent

- (BOOL) isAllDayEvent: (NSInteger) eventTypeIndex {
	if (eventTypeIndex == 0) {
		return TRUE;
	} else {
		return FALSE;
	}
}


- (NSDate *) constructEventStartDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime {
	if (self.isAllDay) {
		return birthdayDate;
	} else {
		NSDate *alertDate = [[birthdayDate copy] autorelease];
		return [alertDate dateByAddingTimeInterval: alertTime];
	}
	return birthdayDate;
}


- (NSDate *) constructEventEndDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime {
	if (self.isAllDay) {
		return birthdayDate;
	} else {
		NSDate *alertDate = [[birthdayDate copy] autorelease];
		return [alertDate dateByAddingTimeInterval: alertTime + 60 * 60];
	}
}


- (NSInteger) constructRelativeAlertTime: (NSInteger) alertTime {	
	if (self.isAllDay) {
		return alertTime;
	} else {
		return 0;
	}
}


- (NSInteger) constructRelativeReminderTime: (NSInteger) reminderTime withAlarmTime: (NSInteger) alertTime {
	if (self.isAllDay) {
		return alertTime - reminderTime;
	} else {
		return -reminderTime;
	}
}


- (CalAlarm *) createAlarm:(NSInteger)alertTime alarmType:(NSInteger)type fromEmailAddress:(NSString *)email {
	CalAlarm *alarm = [CalAlarm alarm];
	
	if (ALARM_SOUND == type) {
		alarm.action = CalAlarmActionSound;
		alarm.sound = @"Basso";	
	}
	else if (ALARM_MESSAGE == type) {
		alarm.action = CalAlarmActionDisplay;
	} 
	else {
		alarm.action = CalAlarmActionEmail;
		alarm.emailAddress = email;
	}

	alarm.relativeTrigger = [self constructRelativeAlertTime: alertTime];
	return alarm;
}


- (CalAlarm *) createReminderAlarm:(NSInteger)reminderTime withAlarmTime:(NSInteger)alertTime alarmType:(NSInteger)type fromEmailAddress:(NSString *)email {
	CalAlarm *alarm = [CalAlarm alarm];
	
	if (ALARM_SOUND == type) {
		alarm.action = CalAlarmActionSound;
		alarm.sound = @"Basso";	
	}
	else if (ALARM_MESSAGE == type) {
		alarm.action = CalAlarmActionDisplay;
	} 
	else {
		alarm.action = CalAlarmActionEmail;
		alarm.emailAddress = email;
	}
	
	alarm.relativeTrigger = [self constructRelativeReminderTime: reminderTime withAlarmTime: alertTime];
	return alarm;
}

@end
