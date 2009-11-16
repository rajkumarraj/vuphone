//
//  EventListViewController.m
//  Events
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

//	[[self locationManager] startUpdatingLocation];
	NSArray *sources = [Event allSources];

	// Hard-coding the list of chosen sources for now
	NSMutableArray *tempChosenSources = [[NSMutableArray alloc] init];
	[tempChosenSources addObject:[sources objectAtIndex:0]];
	[tempChosenSources addObject:[sources objectAtIndex:1]];
	[tempChosenSources addObject:[sources objectAtIndex:4]];
	chosenSources = tempChosenSources;
}

- (void)viewWillAppear:(BOOL)animated
{	
	if (!fetchedResultsC)
	{
		// Set up the initial fetch request
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:VUEntityNameEvent inManagedObjectContext:context];
		[request setEntity:entity];
		
		// Set the starting sources predicate
		[self setSourcesPredicate:[NSPredicate predicateWithFormat:@"source IN %@", chosenSources]];
		
		// Set the filter predicate to true
		[self setFilterPredicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"]];
		
		[request setPredicate:[self predicate]];
		
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

	// If an event was modified, update it
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
	event.source = VUEventSourceUser;
	
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
	sourcesVC.sources = [Event allSources];
	sourcesVC.chosenSources = [[NSSet setWithArray:chosenSources] mutableCopy];
	[self presentModalViewController:sourcesVC animated:YES];

	[sourcesVC release];
}

- (void)sourcesViewController:(SourcesViewController *)sourcesVC
		didDismissWithChoices:(NSArray *)choices
{
	// Adjust the query to include these choices
	NSLog(@"DidDismissWithChoices: %@", choices);
	[self setChosenSources:choices];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
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
		[dateFormatter setDateFormat:@"h:mm"];
	}
	
	// Add a shorter name label
	UILabel *shorterTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 3.0, 236.0, 40.0)];
	shorterTextLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+4.0];
	shorterTextLabel.text = [event name];
	[cell addSubview:shorterTextLabel];
	[shorterTextLabel release];
	
	// Add a shorter time label
	shorterTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(256.0, 3.0, 54.0, 40.0)];
	shorterTextLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]+4.0];
	shorterTextLabel.text = [dateFormatter stringFromDate:[event startTime]];
	shorterTextLabel.textColor = [UIColor colorWithRed:56.0/255.0
												 green:84.0/255.0
												  blue:135.0/255.0
												 alpha:1.0];
	[cell addSubview:shorterTextLabel];
	[shorterTextLabel release];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (!sectionIndexTitles) {
		NSMutableArray *titles = [NSMutableArray new];
		
		for (id<NSFetchedResultsSectionInfo> title in [fetchedResultsC sections]) {
			// Let the index title be the day number
			if ([title.name length] != 0) {
				[titles addObject:[title.name substringFromIndex:[title.name length] - 2]];
			}
		}
		sectionIndexTitles = titles;
	}

	return sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"didChangeContent");
	[self.tableView reloadData];
	// Reload the section index titles
	[sectionIndexTitles release];
	sectionIndexTitles = nil;
	[self.tableView reloadSectionIndexTitles];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	NSLog(@"didChangeObject");

	[self.tableView reloadData];
	// Reload the section index titles
	[sectionIndexTitles release];
	sectionIndexTitles = nil;
	[self.tableView reloadSectionIndexTitles];
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

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
	[self filterContentForSearchText:@"" scope:@""];
}

#pragma mark Filtration

// Takes an array of the currently chosen sources, then updates the results controller predicate and refetches
- (void)setChosenSources:(NSArray *)sources
{
	// Release the current filter predicate if it exists
	if (chosenSources != sources)
	{
		[chosenSources release];
		chosenSources = [sources retain];
		
		if ([sources count]) {
			[self setSourcesPredicate:[NSPredicate predicateWithFormat:@"source IN %@", chosenSources]];
		} else {
			[self setSourcesPredicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"]];
		}
	}
	
	[self refetch];
}

// Takes a string of the chosen filter text, then sets the results controller predicate and refetches
 - (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	if ([searchText length] > 0) {
		[self setFilterPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText]];
	} else {
		[self setFilterPredicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"]];
	}
	
	[self refetch];
}

- (void)setSourcesPredicate:(NSPredicate *)pred {
	// Release the current filter predicate if it exists
	if (sourcesPredicate != pred) {
		[sourcesPredicate release];
		sourcesPredicate = [pred retain];
	}
}

- (void)setFilterPredicate:(NSPredicate *)pred {
	// Release the current filter predicate if it exists
	if (filterPredicate != pred) {
		[filterPredicate release];
		filterPredicate = [pred retain];
	}
}

- (NSPredicate *)predicate {
	return [NSCompoundPredicate andPredicateWithSubpredicates:
			[NSArray arrayWithObjects:sourcesPredicate, filterPredicate, nil]];
}

- (void)refetch
{	
	[self.fetchedResultsC.fetchRequest setPredicate:[self predicate]];
	
	// Refetch
	NSError *err;
	[self.fetchedResultsC performFetch:&err];
	[self.tableView reloadData];

	[sectionIndexTitles release];
	sectionIndexTitles = nil;
	[self.tableView reloadSectionIndexTitles];
}

- (void)dealloc
{
	[fetchedResultsC release];
	[locationManager release];
	[context release];
	[sectionIndexTitles release];
	[chosenSources release];
	
	[super dealloc];
}

@synthesize context;
@synthesize fetchedResultsC;
@synthesize locationManager;

@end