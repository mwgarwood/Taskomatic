//
//  DurationPickerController.m
//  TaskoMatic
//
//  Created by Mike Garwood on 5/21/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "DurationPickerController.h"

@interface DurationPickerController ()

@end

@implementation DurationPickerController

- (id)initWithDuration:(int)duration useActionSheet:(BOOL)useAS title:(NSString *)title delegate:(id)delegate callback:(void (^)(int)) callbackBlock
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _callbackBlock = callbackBlock;
        _initDuration = duration;
        if (useAS)
        {
            _delegate = delegate;
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            [actionSheet addSubview:[self view]];
            [[self fieldName] setText:title];
            //[actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
            [actionSheet showInView:[delegate view]];
        }

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_durationPicker setDatePickerMode:UIDatePickerModeCountDownTimer];
    [_durationPicker setCountDownDuration:_initDuration * 60.];
    if (!actionSheet)
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
    if (actionSheet)
    {
        [actionSheet setBounds:CGRectMake(0, 0, 320, 475)];
    }
}

- (IBAction)clearDuration:(id)sender
{
    _callbackBlock(0);
}

- (IBAction)durationChanged:(id)sender
{
    _callbackBlock(([_durationPicker countDownDuration] / 60.) + .5);
}

- (IBAction)dismissPicker:(id)sender
{
    if (actionSheet)
    {
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_delegate)
    {
        [_delegate didDismissActionSheet];
    }
}

- (void)viewDidUnload {
    [self setTitle:nil];
    [self setTitle:nil];
    [self setFieldName:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}
@end
