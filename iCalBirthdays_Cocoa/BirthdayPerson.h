//
//  BirthdayPerson.h
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface BirthdayPerson : ABPerson {
	NSString *eventTitle;
	NSString *reminderTitle;
	NSString *fullName;
	NSInteger age;
}

@property (nonatomic, retain) NSString *eventTitle;
@property (nonatomic, retain) NSString *reminderTitle;
@property (nonatomic, retain) NSString *fullName;
@property NSInteger age;


- (id) initWith: (ABPerson *) person;
- (NSString *) constructEventTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate;
- (NSString *) constructReminderTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate;
- (NSString *) constructAlertTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate;
- (NSString *) constructFullName;
- (NSInteger) calculateAge;
//- (NSDate *) nextBirthday;

@end
