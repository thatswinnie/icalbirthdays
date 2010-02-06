//
//  BirthdayPerson.m
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BirthdayPerson.h"


@implementation BirthdayPerson

@synthesize birthdayPerson;
@synthesize eventTitle;
@synthesize reminderTitle;
@synthesize fullName;
@synthesize currentAge;
@synthesize nextAge;
@synthesize addressbookUrl;


- (id) initWithABPerson: (ABPerson *) person {
	self = [super init];
	if (self) {
		birthdayPerson = [person retain];
		[self setFullName: [self constructFullName]];
		[self setCurrentAge: [self calculateCurrentAge]];
		[self setNextAge: [self calculateNextAge]];
		self.addressbookUrl = [self createAddressbookUrl];
	}
	return self;
}

-(void) dealloc {
	[birthdayPerson release];
	[super dealloc];
}

- (NSString *) constructEventTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate {
	return [self constructAlertTitle:formatIndex customTitleText:customTemplate];
}

- (NSString *) constructReminderTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate {
	return [self constructAlertTitle:formatIndex customTitleText:customTemplate];		 
}
		 
- (NSString *) constructAlertTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate {
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	
	NSDateFormatter *yearFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[yearFormatter setDateFormat:@"Y"];
	
	if (formatIndex == 0) {
		// Firstname Lastname
		return [self fullName];
	}
	else if (formatIndex == 1) {
		// Firstname Lastname's birthday
		return [NSString stringWithFormat:@"%@%@", [self fullName], [thisBundle localizedStringForKey:@"'s birthday" value:@"'s birthday" table:nil]];
	}
	else if (formatIndex == 2) {
		// Firstname Lastname (year of birth)
		return [NSString stringWithFormat:@"%@ (%@)", [self fullName], [yearFormatter stringFromDate:[birthdayPerson valueForProperty:kABBirthdayProperty]]];		
	}
	else if (formatIndex == 3) {		
		// Firstname Lastname (age in year year of next birthday)
		return [NSString stringWithFormat:@"%@ (%i %@ %@)", [self fullName], [self nextAge], [thisBundle localizedStringForKey:@"in year" value:@"in year" table:nil], [yearFormatter stringFromDate:[self nextBirthday]]];	
	}
	else if (formatIndex == 4) {
		// Firstname Lastname (age)
		return [NSString stringWithFormat:@"%@ (%i)", [self fullName], [self currentAge]];
	}
	else if (formatIndex == 5) {
		// Firstname
		return [birthdayPerson valueForProperty:kABFirstNameProperty];
	}
	else if (formatIndex == 6) {
		// Firstname's birthday
		return [NSString stringWithFormat:@"%@%@", [birthdayPerson valueForProperty:kABFirstNameProperty], [thisBundle localizedStringForKey:@"'s birthday" value:@"'s birthday" table:nil]];
	}
	else if (formatIndex == 7) {
		// Firstname (year of birth)
		return [NSString stringWithFormat:@"%@ (%@)", [birthdayPerson valueForProperty:kABFirstNameProperty], [[birthdayPerson valueForProperty:kABBirthdayProperty] descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:[NSLocale currentLocale]]];		
	}
	else if (formatIndex == 8) {
		// Firstname (age in year year of next birthday)
		return [NSString stringWithFormat:@"%@ (%i %@ %@)", [birthdayPerson valueForProperty:kABFirstNameProperty], [self nextAge], [thisBundle localizedStringForKey:@"in year" value:@"in year" table:nil], [yearFormatter stringFromDate:[self nextBirthday]]];
	}
	else if (formatIndex == 9) {
		// Firstname (age)
		return [NSString stringWithFormat:@"%@ (%i)", [birthdayPerson valueForProperty:kABFirstNameProperty], [self currentAge]];
	}
	else if (formatIndex == 11) {
		// custom alert
		// %lastname%, %firstname%, %age%, %yearofbirth%		
		NSString *customAlert = customTemplate;
		
		if ([birthdayPerson valueForProperty:kABLastNameProperty] != nil)
			customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%lastname%" withString: [birthdayPerson valueForProperty:kABLastNameProperty]];
		
		if ([birthdayPerson valueForProperty:kABFirstNameProperty] != nil)
			customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%firstname%" withString: [birthdayPerson valueForProperty:kABFirstNameProperty]];
		
		customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%yearofbirth%" withString: [yearFormatter stringFromDate:[birthdayPerson valueForProperty:kABBirthdayProperty]]];
		customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%age%" withString: [NSString stringWithFormat:@"%i", [self nextAge]]];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setLocale:[NSLocale currentLocale]];
		
		NSString *stringFromDate = [dateFormatter stringFromDate:[birthdayPerson valueForProperty:kABBirthdayProperty]];
		customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%birthday%" withString: stringFromDate];
		[dateFormatter release];
		return customAlert;
	}
	else {
		// Firstname Lastname's birthday
		return [NSString stringWithFormat:@"%@%@", [self fullName], [thisBundle localizedStringForKey:@"'s birthday" value:@"'s birthday" table:nil]];
	}

	return @"";
}

- (NSString *) constructFullName {
	NSString *fullNameConstruct = @"";
	
	if ([birthdayPerson valueForProperty:kABTitleProperty] != nil)
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[birthdayPerson valueForProperty:kABTitleProperty]];
	
	if ([birthdayPerson valueForProperty:kABFirstNameProperty] != nil) {
		if ([fullNameConstruct length] > 0)
			fullNameConstruct = [fullNameConstruct stringByAppendingString:@" "];
		
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[birthdayPerson valueForProperty:kABFirstNameProperty]];
	}
	
	if ([birthdayPerson valueForProperty:kABMiddleNameProperty] != nil) {
		if ([fullNameConstruct length] > 0)
			fullNameConstruct = [fullNameConstruct stringByAppendingString:@" "];
		
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[birthdayPerson valueForProperty:kABMiddleNameProperty]];
	}
	
	if ([birthdayPerson valueForProperty:kABLastNameProperty] != nil) {
		if ([fullNameConstruct length] > 0)
			fullNameConstruct = [fullNameConstruct stringByAppendingString:@" "];
		
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[birthdayPerson valueForProperty:kABLastNameProperty]];
	}
	
	return fullNameConstruct;
}

- (NSInteger) calculateCurrentAge {
	NSDate *dateOfBirth = [birthdayPerson valueForProperty:kABBirthdayProperty];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
	NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
	
	if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
		(([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
		// hasn't had birthday this year yet
		return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
	} else {
		return [dateComponentsNow year] - [dateComponentsBirth year];
	}
}

- (NSInteger) calculateNextAge {
	return [self calculateCurrentAge] + 1;
}

- (NSDate *) nextBirthday {
	NSDate *dateOfBirth = [birthdayPerson valueForProperty:kABBirthdayProperty];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
	NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
	
	[dateComponentsBirth setYear:[dateComponentsNow year]];
	NSDate *thisYearsBirthday = [calendar dateFromComponents:dateComponentsBirth];
	
	
	if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
		(([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
		// hasn't had birthday this year yet
		return thisYearsBirthday;
	} else {
		// next birthday in next year
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.year = 1;
		NSDate *nextYearsBirthday = [calendar dateByAddingComponents:components toDate:thisYearsBirthday options:0];
		[components release];
		return nextYearsBirthday;
	}	
}

- (NSURL *) createAddressbookUrl {
	return [NSURL URLWithString: [NSString stringWithFormat:@"addressbook://%@", [birthdayPerson uniqueId]]];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if( birthdayPerson && [birthdayPerson respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:birthdayPerson];
    else
        [super forwardInvocation:anInvocation];
}


- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if( !signature && birthdayPerson) {
		signature = [birthdayPerson methodSignatureForSelector:selector];
    }
    return signature;
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ( [super respondsToSelector:aSelector] )
    {
		return YES;
	}
    
	if( birthdayPerson && [birthdayPerson respondsToSelector:aSelector] )
	{
		return YES;
	}
    return NO;
}

@end
