//
//  BirthdayPerson.m
//  cocoaTest
//
//  Created by thatswinnie on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BirthdayPerson.h"


@implementation BirthdayPerson


@synthesize eventTitle;
@synthesize reminderTitle;
@synthesize fullName;
@synthesize age;


- (id) initWith: (ABPerson *) person {
	self = [super initWithVCardRepresentation: [person vCardRepresentation]];
	if (self) {
		[self setFullName: [self constructFullName]];
		[self setAge: [self calculateAge]];
	}
	return self;
}

- (NSString *) constructEventTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate {
	return [self constructAlertTitle:formatIndex customTitleText:customTemplate];
}

- (NSString *) constructReminderTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate {
	return [self constructAlertTitle:formatIndex customTitleText:customTemplate];		 
}
		 
- (NSString *) constructAlertTitle: (NSInteger) formatIndex customTitleText: (NSString *) customTemplate {
	if (formatIndex == 0) {
		return [self fullName];
	}
	else if (formatIndex == 1) {
		NSString *format = NSLocalizedString(@"%@'s birthday", @"");
		return [NSString stringWithFormat:format, [self fullName]];
	}
	else if (formatIndex == 2) {
		return [NSString stringWithFormat:@"%@ (%i)", [self fullName], [[self valueForProperty:kABBirthdayProperty] descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:[NSLocale currentLocale]]];		
	}
	else if (formatIndex == 3) {		
		//set alert_text to (fullname & " (" & age & " " & my localized_string("in year") & " " & year of nextBirthday & ")")
	}
	else if (formatIndex == 4) {
		return [NSString stringWithFormat:@"%@ (%i)", [self fullName], [self age]];
	}
	else if (formatIndex == 5) {
		return [self valueForProperty:kABFirstNameProperty];
	}
	else if (formatIndex == 6) {
		NSString *format = NSLocalizedString(@"%@'s birthday", @"");
		return [NSString stringWithFormat:format, [self valueForProperty:kABFirstNameProperty]];
	}
	else if (formatIndex == 7) {
		return [NSString stringWithFormat:@"%@ (%i)", [self valueForProperty:kABFirstNameProperty], [[self valueForProperty:kABBirthdayProperty] descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:[NSLocale currentLocale]]];		
	}
	else if (formatIndex == 8) {
		//set alert_text to (firstname & " (" & age & " " & my localized_string("in year") & " " & year of nextBirthday & ")")
	}
	else if (formatIndex == 9) {
		return [NSString stringWithFormat:@"%@ (%i)", [self valueForProperty:kABFirstNameProperty], [self age]];
	}
	else if (formatIndex == 11) {
		// %lastname%, %firstname%, %age%, %yearofbirth%		
		NSString *customAlert = @"";
		
		if ([self valueForProperty:kABLastNameProperty] != nil)
			customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%lastname%" withString: [self valueForProperty:kABLastNameProperty]];
		
		if ([self valueForProperty:kABFirstNameProperty] != nil)
			customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%firstname%" withString: [self valueForProperty:kABFirstNameProperty]];
		
		customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%yearofbirth%" withString: [[self valueForProperty:kABBirthdayProperty] descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:[NSLocale currentLocale]]];
		customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%age%" withString: [NSString stringWithFormat:@"%i", [self age]]];
		
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setLocale:[NSLocale currentLocale]];
		
		NSString *stringFromDate = [dateFormatter stringFromDate:[self valueForProperty:kABBirthdayProperty]];
		customAlert = [customAlert stringByReplacingOccurrencesOfString:@"%birthday%" withString: stringFromDate];
	}
	else {
		NSString *format = NSLocalizedString(@"%@'s birthday", @"");
		return [NSString stringWithFormat:format, [self fullName]];		
	}

	return @"";
}

- (NSString *) constructFullName {
	NSString *fullNameConstruct = @"";
	
	if ([self valueForProperty:kABTitleProperty] != nil)
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[self valueForProperty:kABTitleProperty]];
	
	if ([self valueForProperty:kABFirstNameProperty] != nil) {
		if ([fullNameConstruct length] > 0)
			fullNameConstruct = [fullNameConstruct stringByAppendingString:@" "];
		
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[self valueForProperty:kABFirstNameProperty]];
	}
	
	if ([self valueForProperty:kABMiddleNameProperty] != nil) {
		if ([fullNameConstruct length] > 0)
			fullNameConstruct = [fullNameConstruct stringByAppendingString:@" "];
		
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[self valueForProperty:kABMiddleNameProperty]];
	}
	
	if ([self valueForProperty:kABLastNameProperty] != nil) {
		if ([fullNameConstruct length] > 0)
			fullNameConstruct = [fullNameConstruct stringByAppendingString:@" "];
		
		fullNameConstruct = [fullNameConstruct stringByAppendingString:[self valueForProperty:kABLastNameProperty]];
	}
	
	return fullNameConstruct;
}

- (NSInteger) calculateAge {
	NSDate *dateOfBirth = [self valueForProperty:kABBirthdayProperty];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
	NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
	
	if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
		(([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
		return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
	} else {
		return [dateComponentsNow year] - [dateComponentsBirth year];
	}
}

//- (NSDate *) nextBirthday {
//	
//}

@end
