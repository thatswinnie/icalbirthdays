//
//  BirthdayEvent.h
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CalendarStore/CalendarStore.h>


@interface BirthdayEvent : CalEvent {	

}

- (BOOL) isAllDayEvent: (NSInteger) eventTypeIndex;
- (NSDate *) constructAlertStartDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime;
- (NSDate *) constructAlertEndDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime;
- (NSInteger) constructRelativeAlertTime: (NSInteger) alertTime;
- (CalAlarm *) createAlarm: (NSInteger) alertTime;

@end
