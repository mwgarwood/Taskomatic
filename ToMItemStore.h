//
//  ToMItemStore.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/16/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToMItem;
@class ToMCacheEntry;


extern NSString * const ToMStoreUpdateNotification;


@interface ToMItemStore : NSObject
{
    NSMutableArray *allItems;
    NSMutableArray *allCacheEntries;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (ToMItemStore *)sharedStore;

- (NSArray *)allItems;
- (void)loadAllItems;
- (BOOL)saveChanges;
- (void)removeItem:(ToMItem *)p cache:(BOOL)cache;
- (void)moveItemAtIndex:(int)from toIndex:(int)to;
- (ToMItem *)createItem;
- (double)allocateOrderValue:(int)index;
- (NSArray *)allCacheEntries;
- (void)insertCacheEntry:(ToMItem *)item;
- (void)removeCacheEntry:(ToMCacheEntry *)p;
- (void)insertCacheEntryWithName:(NSString *)name minutes:(int)duration;



@end
