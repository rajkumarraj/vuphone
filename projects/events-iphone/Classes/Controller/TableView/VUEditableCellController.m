//
//  VUEditableTableViewCellController.m
//  Events
//
//  Created by Aaron Thompson on 9/9/09.
//  Copyright 2009 Iostudio, LLC. All rights reserved.
//

#import "VUEditableCellController.h"

@implementation VUEditableCellController

- (id)initWithLabel:(NSString *)aLabel
{
	self = [super init];
	if (self != nil) {
		label = [aLabel retain];
	}
	return self;
}

//
// tableView:cellForRowAtIndexPath:
//
// Returns the cell for a given indexPath.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Set up the cell
	static NSString *identifier = @"editable";
	
	VUEditableCell *cell;
	
	cell = (VUEditableCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"VUEditableTableViewCell" owner:self options:nil];
		cell = editableTVC;
	}
	cell.textLabel.text = label;
	cell.textField.text = value;
	
	return cell;
}

//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[editableTVC setEditing:isEditable];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)setEditingField:(BOOL)isEditing
{
	isEditable = isEditing;
	[editableTVC setEditable:isEditing];
	
	editableTVC.textField.placeholder = (isEditable) ? @"(tap to edit)" : nil;
}

- (void)dealloc {
	[label release];
	[value release];
	self.delegate = nil;
    [super dealloc];
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// Nothing to do
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.value = textField.text;
	NSLog(@"text field ended editing with value: %@", textField.text);
	if (delegate && [delegate respondsToSelector:@selector(cellControllerValueChanged:)]) {
		[delegate cellControllerValueChanged:textField.text];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@synthesize label;
@synthesize value;
@synthesize delegate;

@end
