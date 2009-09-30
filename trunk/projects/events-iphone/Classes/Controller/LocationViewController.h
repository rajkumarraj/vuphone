//
//  LocationViewController.h
//  VandyUpon
//
//  Created by Aaron Thompson on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"

@interface LocationViewController : UIViewController <MKMapViewDelegate> {
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *latitudeField;
	IBOutlet UITextField *longitudeField;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet MKMapView *mapView;
	
	NSManagedObjectContext *editingContext;
	Location *location;
	BOOL isEditing;
}

- (IBAction)save:(id)sender;
- (IBAction)edit:(id)sender;
- (void)applyIsEditing;

@property (nonatomic, retain) NSManagedObjectContext *editingContext;
@property (nonatomic, retain) Location *location;
@property (assign) BOOL isEditing;

@end
