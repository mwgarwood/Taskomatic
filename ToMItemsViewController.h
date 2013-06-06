//
//  ToMItemsViewController.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/16/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class ToMItem;

@interface ToMItemsViewController : UITableViewController 
{
    CALayer *progressLine;
}

@property (nonatomic, strong) ToMItem *editItem;

- (void)addNewItem:(id)sender;
- (void)rescheduleItems;
- (void)reinsertItem:(ToMItem *)item;
- (void)adjustItemAtIndex:(int)index;

@end
