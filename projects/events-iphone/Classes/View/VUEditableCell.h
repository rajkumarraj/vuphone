//
//  VUEditableTableViewCell.h
//  Events
//
//  Created by Aaron Thompson on 9/9/09.
//  Copyright 2009 Iostudio, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VUEditableCell : UITableViewCell {

	IBOutlet UILabel *textLabel;
	IBOutlet UITextField *textField;
}

- (void)setEditable:(BOOL)editable;

@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UITextField *textField;

@end
