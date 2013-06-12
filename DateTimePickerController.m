//
//  DateTimePickerController.m
//  TaskoMatic
//
//  Created by Mike Garwood on 5/20/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "DateTimePickerController.h"

@interface DateTimePickerController ()

@end

@implementation DateTimePickerController

- (id)initWithDate:(NSDate *)date useActionSheet:(BOOL)useActionSheet title:(NSString *)title delegate:(id)delegate callback:(void (^)(NSDate *))callbackBlock
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _callbackBlock = callbackBlock;
        _initDate = date;
        if (useActionSheet)
        {
            _delegate = delegate;
            _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            [_actionSheet addSubview:[self view]];
            [[self fieldName] setText:title];
            //[actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
            [_actionSheet showInView:[delegate view]];
        }
    }
    return self;
}

- (IBAction)dateChanged:(id)sender
{
    _callbackBlock([_dateTimePicker date]);
}

- (IBAction)dismissPicker:(id)sender
{
    if (_actionSheet)
    {
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        [self removeFromParentViewController];
        _actionSheet = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_initDate)
    {
        [_dateTimePicker setDate:_initDate];
        [self setInitDate:nil];
    }
    if (!_actionSheet)
    {           // make done button disappear
        for (NSObject *object in [[self view] subviews])
        {
            if ([object isKindOfClass:[UIToolbar class]])
            {
                UIToolbar *toolbar = (UIToolbar *)object;
                NSMutableArray *items = [[toolbar items] mutableCopy];
                [items removeObject:[self doneButton]];
                [toolbar setItems:items];
                [self setDoneButton:nil];
                break;
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_actionSheet)
    {
        [_actionSheet setBounds:CGRectMake(0, 0, 320, 475)];
    }
}

- (IBAction)clearDate:(id)sender
{
    _callbackBlock(nil);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_delegate)
    {
        [_delegate didDismissActionSheet];
    }
    [actionSheet setDelegate:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!_actionSheet)
    {
        [self setFieldName:nil];
        [self setDoneButton:nil];
        [self setDateTimePicker:nil];
        [self removeFromParentViewController];
        [self setInitDate:nil];
    }
    [super viewWillDisappear:animated];
}
@end
