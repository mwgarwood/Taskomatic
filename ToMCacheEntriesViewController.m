//
//  ToMCacheEntriesViewController.m
//  TaskoMatic
//
//  Created by Mike Garwood on 6/1/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "ToMCacheEntriesViewController.h"
#import "ToMItemStore.h"
#import "ToMCacheEntry.h"
#import "ToMCacheEntryCell.h"
#import "ToMUtilities.h"

@interface ToMCacheEntriesViewController ()

@end

@implementation ToMCacheEntriesViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeUpdated:) name:ToMStoreUpdateNotification object:nil];
        UINavigationItem *n = [self navigationItem];
        [n setTitle:NSLocalizedString(@"Cache", @"Cache View Name")];
       // UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        //[n setRightBarButtonItem:bbi];
        [n setLeftBarButtonItem:[self editButtonItem]];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"TaskoMaticSetCacheDefaultsPrefKey"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TaskoMaticSetCacheDefaultsPrefKey"];
            NSDictionary *cacheDefaults = @{
                                      @"Breakfast" : @60,
                                      @"Lunch" : @60,
                                      @"Dinner" : @90,
                                      @"Airport security" : @45,
                                      @"Drive to airport" : @45,
                                      @"Drive home" : @30,
                                      @"Wake up" : @0,
                                      @"Groceries" : @60,
                                      @"Pack" : @30,
                                      @"Travel" : @60,
                                      @"Pick up" : @30,
                                      @"Catch flight" : @0,
                                      @"Exercise/Workout" : @90,
                                      @"Email" : @30,
                                      @"Meeting" : @60,
                                      };
            for (NSString *taskname in cacheDefaults)
            {
                int duration = [[cacheDefaults objectForKey:taskname] integerValue];
                [[ToMItemStore sharedStore] insertCacheEntryWithName:taskname minutes:duration];
            }
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[self tableView] respondsToSelector:@selector(setBackgroundView:)])
    {
        [[self tableView] setBackgroundView:nil];
    }
    [[self view] setBackgroundColor:[UIColor colorWithRed:3.0f/255.0f green:54.0f/255.0f blue:73.0f/255.0f alpha:1]];
    UINib *nib = [UINib nibWithNibName:@"ToMCacheEntryCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ToMCacheEntryCell"];
    [[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ToMItemStore sharedStore] allCacheEntries] count];
}

- (void)storeUpdated:(NSNotification *)note
{
    [[self tableView] reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToMCacheEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToMCacheEntryCell"];
    ToMCacheEntry *p = [[[ToMItemStore sharedStore] allCacheEntries] objectAtIndex:[indexPath row]];
    [[cell nameLabel] setText:[p name]];
    NSString *duration = [ToMUtilities normalizeTime:[p duration]];
    [[cell durationLabel] setText:duration];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ToMItemStore *ps = [ToMItemStore sharedStore];
        NSArray *entries = [ps allCacheEntries];
        ToMCacheEntry *p = [entries objectAtIndex:[indexPath row]];
        [ps removeCacheEntry:p];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

@end
