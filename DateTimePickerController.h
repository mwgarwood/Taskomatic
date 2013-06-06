//
//  DateTimePickerController.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/20/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateTimePickerControllerDelegate <NSObject>

- (void)didDismissActionSheet;

@end

@interface DateTimePickerController : UIViewController <UIActionSheetDelegate>
{
    UIActionSheet *_actionSheet;
}

- (id)initWithDate:(NSDate *)date useActionSheet:(BOOL)useActionSheet title:(NSString *)title delegate:(id)delegate callback:(void (^)(NSDate *))callbackBlock;

@property (copy, nonatomic) void (^callbackBlock)(NSDate *);
@property (nonatomic, strong) NSDate *initDate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property (weak, nonatomic) IBOutlet UILabel *fieldName;
@property (weak, nonatomic) id <DateTimePickerControllerDelegate> delegate;

- (IBAction)dateChanged:(id)sender;
- (IBAction)clearDate:(id)sender;
- (IBAction)dismissPicker:(id)sender;

@end
