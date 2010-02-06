//
//  BirthdayPerson.h
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface BirthdayPerson : NSObject {
	ABPerson *birthdayPerson;
	NSString *eventTitle;
	NSString *reminderTitle;
	NSString *fullName;
	NSInteger currentAge;
	NSInteger nextAge;
	NSURL *addressbookUrl;
}

@property (nonatomic, retain) ABPerson *birthdayPerson;
@property (nonatomic, retain) NSString *eventTitle;
@property (nonatomic, retain) NSString *reminderTitle;
@property (nonatomic, retain) NSString *fullName;
@property NSInteger currentAge;
@property NSInteger nextAge;
@property (nonatomic, retain) NSURL *addressbookUrl;


- (id) initWithABPerson: (ABPerson *) birthdayPerson;
- (NSString *) constructEventTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate;
- (NSString *) constructReminderTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate;
- (NSString *) constructAlertTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate;
- (NSString *) constructFullName;
- (NSInteger) calculateCurrentAge;
- (NSInteger) calculateNextAge;
- (NSDate *) nextBirthday;
- (NSURL *) createAddressbookUrl;

@end
