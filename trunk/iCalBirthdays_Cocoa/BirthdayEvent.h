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
- (NSDate *) constructEventStartDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime;
- (NSDate *) constructEventEndDate: (NSDate *) birthdayDate alertTime: (NSInteger) alertTime;
- (NSInteger) constructRelativeAlertTime: (NSInteger) alertTime;
- (CalAlarm *) createAlarm: (NSInteger) alertTime;

@end
