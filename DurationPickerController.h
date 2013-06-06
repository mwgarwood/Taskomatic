//
//  DurationPickerController.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/21/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DurationPickerControllerDelegate <NSObject>

- (void)didDismissActionSheet;

@end

@interface DurationPickerController : UIViewController <UIActionSheetDelegate>
{
    UIActionSheet *actionSheet;
}

- (id)initWithDuration:(int)duration useActionSheet:(BOOL)useAS title:(NSString *)title delegate:(id)delegate callback:(void (^)(int)) callbackBlock;
                                                           
@property (copy, nonatomic) void (^callbackBlock)(int);
@property (nonatomic) int initDuration;
@property (weak, nonatomic) IBOutlet UIDatePicker *durationPicker;
@property (weak, nonatomic) IBOutlet UILabel *fieldName;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) id <DurationPickerControllerDelegate> delegate;

- (IBAction)clearDuration:(id)sender;                                                           
- (IBAction)durationChanged:(id)sender;
- (IBAction)dismissPicker:(id)sender;
@end

