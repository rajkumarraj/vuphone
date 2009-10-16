//
//  EventListViewController.m
//  VandyUpon
//
//  Created by Aaron Thompson on 9/7/09.
//  Copyright 2009 Iostudio, LLC. All rights reserved.
//

#import "EventListViewController.h"
#import "SourcesViewController.h"
#import "EntityConstants.h"
#import "EventStore.h"

@implementation EventListViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	[[self locationManager] startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!fetchedResultsC)
	{
		// Set up the fetch request
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:VUEntityNameEvent inManagedObjectContext:context];
		[request setEntity:entity];
		
		// Sort the request
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:VUEntityPropertyNameStartTime ascending:NO];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];
		
		// Set up the fetched results controller
		fetchedResultsC = [[[NSFetchedResultsController alloc]
							initWithFetchRequest:request
							managedObjectContext:context
							sectionNameKeyPath:@"startDateString"
						   	cacheName:@"eventListCache"] retain];
		[request release];
		// Set self as the delegate
		fetchedResultsC.delegate = self;
		
		// Execute the request
		NSError *error;
		BOOL success = [fetchedResultsC performFetch:&error];
		if (!success) {
			NSLog(@"No events found");
		}
	}
	if ([self.tableView indexPathForSelectedRow]) {
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForSelectedRow]]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.fetchedResultsC = nil;
	self.locationManager = nil;
	[eventViewController release];
}

- (IBAction)addEvent:(id)sender
{
	Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:VUEntityNameEvent
														  inManagedObjectContext:context];
	
	EventViewController *eventViewC = [self eventViewController];
	eventViewC.event = event;
	eventViewC.navigationItem.title = @"Add Event";
	[eventViewC beginEditingFields];
	[self.navigationController pushViewController:eventViewC animated:YES];
}

- (EventViewController *)eventViewController
{
	if (eventViewController == nil) {
		EventViewController *eventViewC = [[EventViewController alloc] initWithNibName:@"EventView" bundle:nil];
		eventViewC.context = context;
		eventViewController = eventViewC;
	}
	return eventViewController;
}

#pragma mark Sources

- (IBAction)showSourcesSheet:(id)sender
{
	SourcesViewController *sourcesVC = [[SourcesViewController alloc] initWithNibName:@"SourcesView" bundle:nil];
	sourcesVC.delegate = self;

	NSArray *sources = [NSArray arrayWithObjects:@"Official Calendar", @"Commons", @"Athletics", @"Facebook", nil];
	sourcesVC.sources = sources;
	NSMutableSet *set = [NSMutableSet setWithCapacity:[sources count]];
	[set addObject:[sources objectAtIndex:0]];
	[set addObject:[sources objectAtIndex:2]];
	[set addObject:[sources objectAtIndex:3]];
	
	sourcesVC.chosenSources = set;
	[self presentModalViewController:sourcesVC animated:YES];

	[sourcesVC release];
}

- (void)sourcesViewController:(SourcesViewController *)sourcesVC
		didDismissWithChoices:(NSSet *)choices
{
	// Adjust the query to include these choices
	NSLog(@"DidDismissWithChoices: %@", choices);
}

#pragma mark CLLocation methods

- (CLLocationManager *)locationManager
{
	if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	locationManager.delegate = self;
	
	return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	addButton.enabled = NO;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	/* Important: On iPhone OS 3.0, if you have a single section table view, there is an incompatibility
	 between the values returned by NSFetchedResultsController and the values expected by UITableView.
	 You can work around this incompatibility as follows:
	 */
	NSUInteger count = [[fetchedResultsC sections] count];
	if (count == 0) {
		count = 1;
	}
	NSLog(@"EventList numberOfSectionsInTableView: %i", count);
	
	return count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/* Important: On iPhone OS 3.0, if you have a single section table view, there is an incompatibility
	 between the values returned by NSFetchedResultsController and the values expected by UITableView.
	 You can work around this incompatibility as follows:
	 */
	NSArray *sections = [fetchedResultsC sections];
	NSUInteger count = 0;
	if ([sections count]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		count = [sectionInfo numberOfObjects];
	}

	return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Set up the cell
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	[self configureCell:cell atIndexPath:indexPath];

	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	// Get the event from the fetched results controller
	Event *event = (Event *)[fetchedResultsC objectAtIndexPath:indexPath];

	// Set up the date formatter
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil)
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	// Set up the latitude/longitude formatter
	static NSNumberFormatter *numberFormatter = nil;
	if (numberFormatter == nil)
	{
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	
	// Set the cell labels
	cell.textLabel.text = [event name];
	cell.detailTextLabel.text = [dateFormatter stringFromDate:[event startTime]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (!sectionIndexTitles) {
		NSMutableArray *titles = [NSMutableArray new];
		
		for (id<NSFetchedResultsSectionInfo> title in [fetchedResultsC sections]) {
			// Let the index title be the day number
			[titles addObject:[title.name substringFromIndex:[title.name length] - 2]];
		}
		sectionIndexTitles = titles;
	}

	NSLog(@"sectionIndexTitlesForTableView: %@", sectionIndexTitles);
	return sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSLog(@"sectionForSectionIndexTitle: %@ atIndex: %i", title, index);
	return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section >= [[fetchedResultsC sections] count] || [[fetchedResultsC sections] count] == 0) {
		return nil;
	}

	id<NSFetchedResultsSectionInfo> info = [[fetchedResultsC sections] objectAtIndex:section];
	return [info name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	EventViewController *eventViewC = [self eventViewController];
	Event *event = (Event *)[fetchedResultsC objectAtIndexPath:indexPath];
	
	eventViewC.event = event;
	eventViewC.title = [event name];
	[eventViewC endEditingFields];
	[self.navigationController pushViewController:eventViewC animated:YES];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"willChangeContent");
	
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	NSLog(@"didChangeSection");
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
			 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
			 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	NSLog(@"didChangeObject");

	// Invalidate the sectionIndexTitles
//	[sectionIndexTitles release];
//	sectionIndexTitles = nil;
	
	UITableView *tableView = self.tableView;
	
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]
					 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"didChangeContent");
	
	[self.tableView endUpdates];
}


#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[self filterContentForSearchText:searchString scope:nil];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
	[controller setSearchResultsDelegate:self];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	NSPredicate *predicate;
	if ([searchText length] > 0) {
		predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
	}
	[self.fetchedResultsC.fetchRequest setPredicate:predicate];
	NSError *err;
	[self.fetchedResultsC performFetch:&err];
}

- (void)dealloc
{
	[fetchedResultsC release];
	[locationManager release];
	[context release];
	[sectionIndexTitles release];
	
	[super dealloc];
}

@synthesize context;
@synthesize fetchedResultsC;
@synthesize locationManager;

@end