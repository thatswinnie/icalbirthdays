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


- (NSDate *) constructAlertStartDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime {
	if (self.isAllDay) {
		return birthdayDate;
	} else {
		NSDate *alertDate = [birthdayDate copy];
		return [alertDate dateByAddingTimeInterval: alertTime];
	}
	return birthdayDate;
}


- (NSDate *) constructAlertEndDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime {
	if (self.isAllDay) {
		return birthdayDate;
	} else {
		NSDate *alertDate = [birthdayDate copy];
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


- (CalAlarm *) createAlarm: (NSInteger) alertTime {
	CalAlarm *alarm = [CalAlarm alarm];
	alarm.action = CalAlarmActionSound;
	alarm.sound = @"Basso";
	alarm.relativeTrigger = [self constructRelativeAlertTime: alertTime];
	return alarm;
}

@end
