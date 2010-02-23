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

- (NSDate *) constructEventDate:(NSDate *)birthdayDate inTimePeriod:(NSInteger)period {
	NSDate *date = [[birthdayDate copy] autorelease];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	if (TIMEPERIOD_CURRENT_YEAR == period || TIMEPERIOD_NEXT_YEAR == period) {
		NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
		NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:date];	
		[dateComponentsBirth setYear:[dateComponentsNow year]];
		date = [calendar dateFromComponents:dateComponentsBirth];
	}
	
	if (TIMEPERIOD_NEXT_YEAR == period) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.year = 1;
		date = [calendar dateByAddingComponents:components toDate:date options:0];
		[components release];
	}
	
	return date;
}


- (NSDate *) constructEventStartDate:(NSDate *)birthdayDate alertTime:(NSInteger)alertTime inTimePeriod:(NSInteger)period {
	NSDate *date = [self constructEventDate:birthdayDate inTimePeriod:period];
	
	if (self.isAllDay) {
		return date;
	} else {
		NSDate *alertDate = [[date copy] autorelease];
		return [alertDate dateByAddingTimeInterval: alertTime];
	}
	
	return date;
}


- (NSDate *) constructEventEndDate:(NSDate *)birthdayDate alertTime:(NSInteger)alertTime inTimePeriod:(NSInteger)period {
	NSDate *date = [self constructEventDate:birthdayDate inTimePeriod:period];
	
	if (self.isAllDay) {
		return date;
	} else {
		NSDate *alertDate = [[date copy] autorelease];
		return [alertDate dateByAddingTimeInterval: alertTime + 60 * 60];
	}
	
	return date;
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
		alarm.sound = @"Ping";	
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
		alarm.sound = @"Ping";	
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
