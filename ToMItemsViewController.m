//
//  ToMItemsViewController.m
//  TaskoMatic
//
//  Created by Mike Garwood on 5/16/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "ToMItemsViewController.h"
#import "ToMItemStore.h"
#import "ToMItemCell.h"
#import "ToMItem.h"
#import "ToMDetailItemViewController.h"
#import "ToMNavigationController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ToMExplanationViewController.h"

@implementation ToMItemsViewController

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeUpdated:) name:ToMStoreUpdateNotification object:nil];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        for (ToMItem *item in [[ToMItemStore sharedStore] allItems])
        {
            [item setNotifScheduled:0];
        }
        UINavigationItem *n = [self navigationItem];
        [n setTitle:NSLocalizedString(@"Task-O-Matic", @"Application Name")];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        [n setRightBarButtonItem:bbi];
        [[self editButtonItem] setPossibleTitles:[NSSet setWithArray:[NSArray arrayWithObjects:@"Edit", @"Reschedule", nil]]];
        [n setLeftBarButtonItem:[self editButtonItem]];
        notifications = [[NSMutableDictionary alloc] init];
        sectionIndexFormatter = [[NSDateFormatter alloc] init];
        [sectionIndexFormatter setTimeStyle:NSDateFormatterNoStyle];
        [sectionIndexFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ToMItemStore sharedStore] allItems] count];
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sectionRows objectAtIndex:section+1] integerValue] - [[sectionRows objectAtIndex:section] integerValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = [sectionTitles objectAtIndex:section];
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (void)storeUpdated:(NSNotification *)note
{
    [[self tableView] reloadData];
}

- tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToMItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToMItemCell"];
    int itemIndex = [[sectionRows objectAtIndex:[indexPath section]] integerValue] + [indexPath row];
    ToMItem *p = [[[ToMItemStore sharedStore] allItems] objectAtIndex:itemIndex];
    [[cell nameLabel] setText:[p name]];
    NSMutableString *timeLabel = [[NSMutableString alloc] init];
    [cell setHighlighted: [p startTime] > 0 ? YES : NO];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[p schedTime]];
    [timeLabel setString:[dateFormatter stringFromDate:date]];
    [timeLabel appendString:@" - "];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    date = [NSDate dateWithTimeIntervalSinceReferenceDate:[p schedTime] + [p duration]*60];
    [timeLabel appendString:[dateFormatter stringFromDate:date]];
    [[cell timeLabel] setText:timeLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSTimeInterval currTime = [[[NSDate alloc] init] timeIntervalSinceReferenceDate];
     int itemIndex = [[sectionRows objectAtIndex:[indexPath section]] integerValue] + [indexPath row];
    ToMItem *p = [[[ToMItemStore sharedStore] allItems] objectAtIndex:itemIndex];
    if ([p startTime] > 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:205.0f/255.0f green:179.0f/255.0f blue:128.0f/255.0f alpha:1]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor colorWithRed:232.0f/255.0f green:221.0f/255.0f blue:203.0f/255.0f alpha:1]];
    }
    ToMItemCell *tomCell = (ToMItemCell *)cell;
    if ([[[[p objectID] URIRepresentation] absoluteString] isEqual:_alertItemObjectID])
    {
        [self setAlertItemObjectID:nil];
        [[tomCell nameLabel] setBackgroundColor:[UIColor blackColor]];
        [[tomCell nameLabel] setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [[tomCell nameLabel] setBackgroundColor:[UIColor clearColor]];
        [[tomCell nameLabel] setTextColor:[UIColor blackColor]];
    }
    if ([[[tomCell nameLabel] subviews] count] > 0)
    {
        [[[[tomCell nameLabel] subviews] objectAtIndex:0] removeFromSuperview];
    }
    if ([p completed])
    {
        CGSize expectedNameSize = [[[tomCell nameLabel] text] sizeWithFont:tomCell.nameLabel.font constrainedToSize:tomCell.nameLabel.frame.size lineBreakMode:UILineBreakModeClip];
        UIView *strikethrough = [[UIView alloc] init];
        strikethrough.frame = CGRectMake(0, tomCell.nameLabel.frame.size.height/2, expectedNameSize.width, 1);
        strikethrough.backgroundColor = tomCell.nameLabel.textColor;
        [[tomCell nameLabel] addSubview:strikethrough];
    }
    if ([p enableNotif])
    {
        UIImage *image = [UIImage imageNamed:@"alarm.png"];
        [[tomCell alarmImage] setImage:image];
    }
    else
    {
        [[tomCell alarmImage] setImage:nil];
    }
    if (currTime >= [p schedTime] && currTime <= [p schedTime] + [p duration]*60)
    {
        CGRect bounds = [[self tableView] rectForRowAtIndexPath:indexPath];
        
        if (!progressLine)
        {
            progressLine = [[CALayer alloc] init];
            [progressLine setDelegate:self];
        }
        float y = (currTime - [p schedTime]) / ([p duration]*60.) * bounds.size.height + bounds.origin.y;
        [progressLine setPosition:CGPointMake(SCREEN_WIDTH/2, y)];
        [progressLine setBounds:CGRectMake(0, 0, SCREEN_WIDTH, 6)];
        [[[self view] layer] addSublayer:progressLine];
        [progressLine setNeedsDisplay];
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (layer == progressLine)
    {
        CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        
        CGContextAddEllipseInRect(ctx, CGRectMake(2, 0, 6, 6));
        CGContextDrawPath(ctx, kCGPathFillStroke);

        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 2, 3);
        CGContextAddLineToPoint(ctx, SCREEN_WIDTH, 3);
        
        CGContextStrokePath(ctx);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (progressLine)
    {
        [progressLine setBounds:CGRectMake(0, 0, SCREEN_WIDTH, 6)];
        [progressLine setPosition:CGPointMake(SCREEN_WIDTH/2, [progressLine position].y)];
        [progressLine setNeedsDisplay];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[self tableView] respondsToSelector:@selector(setBackgroundView:)])
    {
        [[self tableView] setBackgroundView:nil];
    }
    [[self view] setBackgroundColor:[UIColor colorWithRed:3.0f/255.0f green:54.0f/255.0f blue:73.0f/255.0f alpha:1]];
    UINib *nib = [UINib nibWithNibName:@"ToMItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ToMItemCell"];
    [[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
}

- (void)addNewItem:(id)sender
{
    ToMItem *newitem = [[ToMItemStore sharedStore] createItem];
    //int lastRow = [[[BNRItemStore sharedStore] allItems] indexOfObject:newitem];
    //NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    //[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
    ToMDetailItemViewController *dvc = [[ToMDetailItemViewController alloc] initForNewItem:YES];
    [dvc setItem:newitem];
    [dvc setDismissBlock:^{ [self reinsertItem:newitem]; [self rescheduleItems]; [[self tableView] reloadData]; }];
    ToMNavigationController *navc = [[ToMNavigationController alloc] initWithRootViewController:dvc];
    [[navc navigationBar] setTintColor:[UIColor blackColor]];
    [navc setModalPresentationStyle:UIModalPresentationFormSheet];
    [navc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ToMItemStore *ps = [ToMItemStore sharedStore];
        NSArray *items = [ps allItems];
        int section = [indexPath section];
        int itemIndex = [[sectionRows objectAtIndex:section] integerValue] + [indexPath row];
        ToMItem *p = [items objectAtIndex:itemIndex];
        if ([p enableNotif])
        {
            [self cancelNotification:p];
        }
        for (section++; section < [sectionRows count]; section++)
        {
            int rows = [[sectionRows objectAtIndex:section] integerValue] - 1;
            [sectionRows setObject:[NSNumber numberWithInteger:rows] atIndexedSubscript:section];
        }
        [ps removeItem:p cache:YES];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    int srcSection = [sourceIndexPath section];
    int destSection = [destinationIndexPath section];
    int indexFrom = [[sectionRows objectAtIndex:srcSection] integerValue] + [sourceIndexPath row];
    int incr = 0;
    int current = srcSection;
    int end = destSection;
    if (srcSection < destSection)
    {
        incr = -1;
    }
    else if (srcSection > destSection)
    {
        incr = 1;
        current = destSection;
        end = srcSection;
    }
    for (current++; current <= end; current++)
    {
        int rows = [[sectionRows objectAtIndex:current] integerValue] + incr;
        [sectionRows setObject:[NSNumber numberWithInteger:rows] atIndexedSubscript:current];
    }
    int indexTo = [[sectionRows objectAtIndex:destSection] integerValue] + [destinationIndexPath row];
    [[ToMItemStore sharedStore] moveItemAtIndex:indexFrom toIndex:indexTo];
    [self adjustItemAtIndex:indexTo];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToMDetailItemViewController *dvc = [[ToMDetailItemViewController alloc] initForNewItem:NO];
    NSArray *items = [[ToMItemStore sharedStore] allItems];
    int itemIndex = [[sectionRows objectAtIndex:[indexPath section]] integerValue] + [indexPath row];
    ToMItem *selectedItem = [items objectAtIndex:itemIndex];
    [dvc setItem:selectedItem];
    [self setEditItem:selectedItem];
    [dvc setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:dvc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[ToMItemStore sharedStore] allItems];
    int itemIndex = [[sectionRows objectAtIndex:[indexPath section]] integerValue] + [indexPath row];
    ToMItem *thisItem = [items objectAtIndex:itemIndex];
    return [thisItem startTime] > 0 ? NO : YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reinsertItem:_editItem];
    [self setEditItem:nil];
    [self rescheduleItems];
    [[self tableView] reloadData];
    if ([[[ToMItemStore sharedStore] allItems] count] == 0)
    {
        UIViewController *vc = [[ToMExplanationViewController alloc] init];
        [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return (io == UIInterfaceOrientationPortrait || io == UIInterfaceOrientationLandscapeLeft || io == UIInterfaceOrientationLandscapeRight);
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing == NO)
    {
        [self rescheduleItems];
        [[self tableView] reloadData];
    }
    else
    {
        [[self editButtonItem] setTitle:@"Reschedule"];
    }
}

- (void)rescheduleItems
{
    sectionRows = [[NSMutableArray alloc] init];
    sectionTitles = [[NSMutableArray alloc] init];
    if (progressLine)
    {
        [progressLine removeFromSuperlayer];
    }
    NSTimeInterval nextTime = [[[NSDate alloc] init] timeIntervalSinceReferenceDate];
    NSTimeInterval currTime = nextTime;
    NSArray *allItems = [[ToMItemStore sharedStore] allItems];
    
    for (int i = 0; i < [allItems count]; i++)
    {
        ToMItem *item = [allItems objectAtIndex:i];
        if ([item startTime] > 0)
        {
            nextTime = [item startTime];
            [item setSchedTime:nextTime];
        }
        else if ([item schedLate])
        {
            [item setSchedTime:nextTime];  // set in case we can't find an anchor
            nextTime += [item duration]*60;
            // look for next anchored item
            int savej = [allItems count] - 1;
            for (int j = i+1; j < [allItems count]; j++)
            {
                item = [allItems objectAtIndex:j];
                if ([item startTime] > 0)
                {
                    nextTime = [item startTime];
                    [item setSchedTime:nextTime];
                    // save anchored item and back-up from here to schedule as late as possible
                    savej = j;
                    for (int k = j-1; k >= i; k--)
                    {
                        item = [allItems objectAtIndex:k];
                        nextTime -= [item duration]*60;
                        [item setSchedTime:nextTime];
                    }
                    break;  // done late as possible scheduling
                }
                else
                {
                    // just in case again
                    [item setSchedTime:nextTime];
                    nextTime += [item duration]*60;
                }
            }
            // set up to pick back up at point after anchored item
            i = savej;
            item = [allItems objectAtIndex:i];
            nextTime = [item startTime];
        }
        else
        {
            if ([item schedTime] == 0 || i > 0)
            {
                [item setSchedTime:nextTime];
            }
            else
            {
                nextTime = [item schedTime] + [item duration]*60;
                continue;
            }
            
        }
        nextTime += [item duration] * 60;
    }
    [[ToMItemStore sharedStore] saveChanges];
    
    int nrows = 0;
    for (int i = 0; i < [allItems count]; i++)
    {
        ToMItem *item = [allItems objectAtIndex:i];
        if ([item enableNotif])
        {
            if ([item notifScheduled] != [item schedTime]  && [item schedTime] > currTime)
            {
                [self scheduleNotification:item];
            }
        }
        else
        {
            [self cancelNotification:item];
        }
        NSString *date = [sectionIndexFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[item schedTime]]];
        if ([sectionTitles count] == 0 || [(NSString *)[sectionTitles lastObject] compare:date] != NSOrderedSame)
        {
            [sectionRows addObject:[NSNumber numberWithInt:nrows]];  // number of rows prior
            [sectionTitles addObject:date];
        }
        nrows++;
    }
    [sectionRows addObject:[NSNumber numberWithInt:nrows]];
}

- (void)scheduleNotification:(ToMItem *)item
{
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    if (notice == nil)
    {
        return;
    }
    NSManagedObjectID *oid = [item objectID];
    //[self cancelNotification:item];
    UILocalNotification *oldNotice = [notifications objectForKey:oid];
    if (oldNotice != nil)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:oldNotice];
        
    }
    [notifications setObject:notice forKey:oid];
    [item setNotifScheduled:[item schedTime]];
    notice.fireDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[item schedTime]];
    notice.timeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *alert = [item name] == nil ? @"Task Reminder" : [NSString stringWithFormat:@"%@ - %@", [item name], [dateFormatter stringFromDate:notice.fireDate]];
    notice.alertBody = alert;
    notice.alertAction = @"View Task List";
    notice.soundName = UILocalNotificationDefaultSoundName;
    notice.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[[oid URIRepresentation] absoluteString], @"objectID", nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
    
}

- (void)cancelNotification:(ToMItem *)item
{
    UILocalNotification *oldNotice = [notifications objectForKey:[item objectID]];
    if (oldNotice != nil)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:oldNotice];
    }
    [notifications removeObjectForKey:[item objectID]];
    [item setNotifScheduled:0];
}

- (void)reinsertItem:(ToMItem *)item
{
    if (!item || [item startTime] == 0)
    {
        return;
    }
    [item setSchedTime:[item startTime]];  // belt and suspenders
    NSArray *allItems = [[ToMItemStore sharedStore] allItems];
    int from = [allItems indexOfObject:item];
    if (from == NSNotFound)
    {
        return;  // creation must have been cancelled
    }
    for (int i = 0; i < [allItems count]; i++)
    {
        ToMItem *storedItem = [allItems objectAtIndex:i];
        if (i == from)
        {
            continue;
        }
        if ([item startTime] < [storedItem schedTime])
        {
            [[ToMItemStore sharedStore] moveItemAtIndex:from toIndex: from < i ? i-1 : i];
            return;
        }
    }
    [[ToMItemStore sharedStore] moveItemAtIndex:from toIndex: [allItems count]-1];
}

- (void)adjustItemAtIndex:(int)index
{
    if (index == 0)  // really only need to worry about insertions at the top
    {
        NSTimeInterval currTime = [[[NSDate alloc] init] timeIntervalSinceReferenceDate];
        NSArray *allItems = [[ToMItemStore sharedStore] allItems];
        ToMItem *thisItem = [allItems objectAtIndex:0];
        ToMItem *nextItem = [allItems objectAtIndex:1];
        if (![thisItem schedLate])
        {
            if (currTime < [nextItem schedTime] - [thisItem duration]*60)
            {
                [thisItem setSchedTime:currTime];
            }
            else if (![nextItem schedLate])
            {
                [thisItem setSchedTime:[nextItem schedTime]];
            }
            else
            {
                [thisItem setSchedTime:[nextItem schedTime] - [thisItem duration]*60]; // ???
            }
        }
        else
        {
            [thisItem setSchedTime:[nextItem schedTime]];  // doesn't really matter
        }
        [[ToMItemStore sharedStore] saveChanges];
    }
}

@end
