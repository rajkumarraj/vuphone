// 
//  Event.m
//  VandyUpon
//
//  Created by Aaron Thompson on 9/9/09.
//  Copyright 2009 Iostudio, LLC. All rights reserved.
//

#import "Event.h"
#import "Location.h"

@implementation Event 

@dynamic ownerAndroidId;
@dynamic url;
@dynamic name;
@dynamic startTime;
@dynamic details;
@dynamic endTime;
@dynamic location;

- (NSString *)startDateString {
	if (!dateFormatter) {
		 dateFormatter = [[NSDateFormatter alloc] init];
		 [dateFormatter setDateFormat:@"eeee, MMMM d"];
	 }
	 return [dateFormatter stringFromDate:self.startTime];
}

#pragma mark MKAnnotation methods

- (NSString *)title {
	return self.name;
}

- (NSString *)subtitle {
	return self.location.name;
}

- (CLLocationCoordinate2D)coordinate {
	return [self.location coordinate];
}
	
- (void)dealloc
{
	if (dateFormatter) {
		[dateFormatter release];
	}
	[super dealloc];
}


@synthesize startDateString;

@end