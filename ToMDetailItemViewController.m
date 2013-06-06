//
//  ToMDetailItemViewController.m
//  TaskoMatic
//
//  Created by Mike Garwood on 5/17/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "ToMDetailItemViewController.h"
#import "ToMItem.h"
#import "ToMCacheEntry.h"
#import "ToMItemStore.h"
#import "DateTimePickerController.h"
#import "DurationPickerController.h"

@interface ToMDetailItemViewController ()

@end

@implementation ToMDetailItemViewController

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        if (isNew)
        {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
            wasCancelled = NO;
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initForNewItem" userInfo:nil];
}

- (void)setItem:(ToMItem *)item
{
    _item = item;
    [[self navigationItem] setTitle:[item name]];
}

- (void)didAcceptAutocompletion:(NSString *)autoString
{
    if ([_item duration] > 0 && [_item startTime] == 0)
    {
        return;
    }
    for (ToMCacheEntry *cacheEntry in allCacheEntries)
    {
        if ([[cacheEntry name] caseInsensitiveCompare:autoString] == NSOrderedSame)
        {
            [_item setDuration:[cacheEntry duration]];
            [self updateDurationDisplay];
        }
    }
}

- (NSString *)textField:(HTAutocompleteTextField *)textField completionForPrefix:(NSString *)prefix ignoreCase:(BOOL)ignoreCase
{
    if ([prefix length] == 0)
    {
        return @"";
    }
    NSString *stringToLookFor;
    if (ignoreCase)
    {
        stringToLookFor = [prefix lowercaseString];
    }
    else
    {
        stringToLookFor = prefix;
    }
    
    for (ToMCacheEntry *cacheEntry in allCacheEntries)
    {
        NSString *stringFromReference = [cacheEntry name];
        NSString *stringToCompare;
        if (ignoreCase)
        {
            stringToCompare = [stringFromReference lowercaseString];
        }
        else
        {
            stringToCompare = stringFromReference;
        }
        
        if ([stringToCompare hasPrefix:stringToLookFor])
        {
            return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
        }
        
    }
    return @"";

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [nameField setAutocompleteDataSource:self];
    //[nameField setShowAutocompleteButton:YES];
    allCacheEntries = [[ToMItemStore sharedStore] allCacheEntries];
    [nameField setText:[_item name]];
    [self updateDurationDisplay];
    [self updateDateDisplay];
    [schedSoonSwitch setOn: ![_item schedLate] && [_item startTime] == 0];
    [schedSoonSwitch setEnabled: [_item startTime] == 0];
}

- (void)updateDurationDisplay
{
    int hours = [_item duration] / 60;
    int mins = [_item duration] - hours * 60;
    NSMutableString *value = [[NSMutableString alloc] init];
    if (hours)
    {
        [value setString:[NSString stringWithFormat:@"%d hour", hours]];
        if (hours != 1)
        {
            [value appendString:@"s"];
        }
        if (mins)
        {
            [value appendFormat:@", %d minute", mins];
            if (mins != 1)
            {
                [value appendString:@"s"];
            }
        }
    }
    else
    {
        if (mins)
        {
            [value setString:[NSString stringWithFormat:@"%d minute", mins]];
            if (mins != 1)
            {
                [value appendString:@"s"];
            }
        }
    }
    [durationButton setTitle:value forState:UIControlStateNormal];
}

- (void)updateDateDisplay
{
    if ([_item startTime] > 0)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[_item startTime]];
        [startButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
        date = [NSDate dateWithTimeIntervalSinceReferenceDate:[_item endTime]];
        [endButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
        [schedSoonSwitch setEnabled:NO];
    }
    else
    {
        [startButton setTitle:nil forState:UIControlStateNormal];
        [endButton setTitle:nil forState:UIControlStateNormal];
        [schedSoonSwitch setEnabled:YES];
        [schedSoonSwitch setOn: ![_item schedLate]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self view] endEditing:YES];
    [_item setName:[[nameField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [_item setSchedLate:![schedSoonSwitch isOn]];
    if (!wasCancelled)
    {
        [[ToMItemStore sharedStore] insertCacheEntry:_item];
    }
}

- (void)save: (id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
}

- (void)cancel: (id)sender
{
    wasCancelled = YES;
    [[ToMItemStore sharedStore] removeItem:_item cache:NO];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];
}

- (IBAction)showDateTimePicker:(id)sender
{
    void (^cbBlock)(NSDate *) = ^(NSDate *date) {
       
        if (!date)
        {
            [_item setStartTime:0];
            [_item setEndTime:0];
        }
        else if ([sender isEqual:startButton])
        {
            [_item setStartTime:[date timeIntervalSinceReferenceDate]];
            [_item setEndTime:[_item startTime] + [_item duration] * 60];
        }
        else
        {
            [_item setEndTime:[date timeIntervalSinceReferenceDate]];
            if ([_item startTime] == 0)
            {
                [_item setStartTime:[_item endTime] - [_item duration]*60];
            }
            else
            {
                if ([_item endTime] < [_item startTime])
                {
                    [_item setEndTime:[_item startTime]];
                }
                [_item setDuration:([_item endTime] - [_item startTime])/60];
                [self updateDurationDisplay];
            }
        }
        [self updateDateDisplay];
        if (!date)
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [popOver dismissPopoverAnimated:YES];
            }
            else
            {
                //[[self navigationController] popViewControllerAnimated:YES];
                [picker dismissPicker:self];
            }
        }
    };
    NSDate *date = nil;
    if ([_item startTime] > 0)
    {
        if ([sender isEqual:startButton])
        {
            date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[_item startTime]];
        }
        else
        {
            date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[_item endTime]];
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        DateTimePickerController *dtpc = [[DateTimePickerController alloc] initWithDate:date useActionSheet:NO title:nil delegate:nil callback:cbBlock];
        popOver = [[UIPopoverController alloc] initWithContentViewController:dtpc];
        [popOver setDelegate:self];
        [popOver setPopoverContentSize:CGSizeMake(320, 265)];
        CGRect rect = [[self view] convertRect:[sender bounds] fromView:sender];
        [popOver presentPopoverFromRect:rect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        //[[self navigationController] pushViewController:dtpc animated:YES];
        picker = [[DateTimePickerController alloc] initWithDate:date useActionSheet:YES title:[sender isEqual:startButton] ? @"Start Time" : @"End Time" delegate:self callback:cbBlock];
    }
}

- (IBAction)showDurationPicker:(id)sender
{
    void (^cbBlock)(int) = ^(int duration) {
        
        [_item setDuration:duration];
        if ([_item startTime] > 0)
        {
            [_item setEndTime:[_item startTime] + duration*60];
            [self updateDateDisplay];
        }
        [self updateDurationDisplay];
        if (!duration)
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [popOver dismissPopoverAnimated:YES];
            }
            else
            {
                //[[self navigationController] popViewControllerAnimated:YES];
                [picker dismissPicker:self];
            }
        }

    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        DurationPickerController *dpc = [[DurationPickerController alloc] initWithDuration:[_item duration] useActionSheet:NO title:nil delegate:nil callback:cbBlock];
        popOver = [[UIPopoverController alloc] initWithContentViewController:dpc];
        [popOver setDelegate:self];
        [popOver setPopoverContentSize:CGSizeMake(320, 216)];
        CGRect rect = [[self view] convertRect:[sender bounds] fromView:sender];
        [popOver presentPopoverFromRect:rect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        //[[self navigationController] pushViewController:dpc animated:YES];
        picker = [[DurationPickerController alloc] initWithDuration:[_item duration] useActionSheet:YES title:@"Duration" delegate:self callback:cbBlock];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popOver dismissPopoverAnimated:YES];
    popOver = nil;
}

- (void)didDismissActionSheet
{
    picker = nil;
}


@end
