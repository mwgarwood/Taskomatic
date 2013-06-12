//
//  ToMDetailItemViewController.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/17/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateTimePickerController.h"
#import "DurationPickerController.h"
#import "HTAutocompleteTextField.h"

@class ToMItem;

@interface ToMDetailItemViewController : UIViewController <UITextFieldDelegate, UIPopoverControllerDelegate, DateTimePickerControllerDelegate, DurationPickerControllerDelegate, HTAutocompleteDataSource>
{
    __weak IBOutlet HTAutocompleteTextField *nameField;
    __weak IBOutlet UIButton *startButton;
    __weak IBOutlet UIButton *endButton;
    __weak IBOutlet UIButton *durationButton;
    __weak IBOutlet UISwitch *schedSoonSwitch;
    __weak IBOutlet UISwitch *schedNotifSwitch;
    __weak IBOutlet UISwitch *completedSwitch;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIControl *controlView;
    UIPopoverController *popOver;
    id picker;
    NSArray *allCacheEntries;
    BOOL wasCancelled;
}

- (id)initForNewItem:(BOOL)isNew;

@property (nonatomic, strong) ToMItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (IBAction)backgroundTapped:(id)sender;
- (IBAction)showDateTimePicker:(id)sender;
- (IBAction)showDurationPicker:(id)sender;
- (void)updateDateDisplay;
- (void)updateDurationDisplay;

@end
