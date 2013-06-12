//
//  ToMItemStore.m
//  TaskoMatic
//
//  Created by Mike Garwood on 5/16/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "ToMItemStore.h"
#import "ToMItem.h"
#import "ToMCacheEntry.h"


NSString * const ToMStoreUpdateNotification = @"ToMStoreUpdateNotification";


@implementation ToMItemStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (ToMItemStore *)sharedStore
{
    static ToMItemStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentChange:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
        
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSURL *dbURL;
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
#ifdef ICLOUD_NOT_FLAKEY        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *ubContainer = [fm URLForUbiquityContainerIdentifier:nil];
        int cloudSupported = [[NSUserDefaults standardUserDefaults] integerForKey:@"TaskoMaticCloudSupportPrefKey"];
        if (ubContainer && cloudSupported >= 0)
        {
            [options setObject:@"taskomatic" forKey:NSPersistentStoreUbiquitousContentNameKey];
            [options setObject:ubContainer forKey:NSPersistentStoreUbiquitousContentURLKey];
            NSURL *nosyncDir = [ubContainer URLByAppendingPathComponent:@"tasks.nosync"];
            [fm createDirectoryAtURL:nosyncDir withIntermediateDirectories:YES attributes:nil error:nil];
            dbURL = [nosyncDir URLByAppendingPathComponent:@"tasks.db"];
        }
        else
        {
            if (cloudSupported == 0)
            {
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud Disabled" message:@"Your device does not support iCloud. Cloud operation diabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
                [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"TaskoMaticCloudSupportPrefKey"];
            }
            NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            dbPath = [dbPath stringByAppendingPathComponent:@"tasks.db"];
            dbURL = [NSURL fileURLWithPath:dbPath];
        }
#else
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"tasks.db"];
        dbURL = [NSURL fileURLWithPath:dbPath];
#endif
        NSError *error = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil URL:dbURL options:options error:&error])
        {
            [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        [context setUndoManager:nil];
        [self loadAllItems];
    }
    return self;
}

- (void)contentChange:(NSNotification *)note
{
    [context mergeChangesFromContextDidSaveNotification:note];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSNotification *updateNote = [NSNotification notificationWithName:ToMStoreUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:updateNote];
    }];
}

- (void)loadAllItems
{
    if (!allItems)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"ToMItem"];
        [request setEntity:e];
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result)
        {
            [NSException raise:@"Fetch failed" format:@"Reason %@", [error localizedDescription]];
        }
        allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (BOOL)saveChanges
{   NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful)
    {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

- (NSArray *)allItems
{
    return allItems;
}

- (ToMItem *)createItem
{
    ToMItem *p = [NSEntityDescription insertNewObjectForEntityForName:@"ToMItem" inManagedObjectContext:context];
    double order;
    if ([allItems count] == 0)
    {
        order = 1.0;
    }
    else
    {
        order = [[allItems lastObject] order] + 1.0;
    }
    [p setOrder:order];
    [allItems addObject:p];
    return p;
}

- (void)insertCacheEntry:(ToMItem *)item
{
    if ([[[item name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        return;
    }
    [self insertCacheEntryWithName:[item name] minutes:[item duration]];
}

- (void)insertCacheEntryWithName:(NSString *)name minutes:(int)duration
{
    
    if (!allCacheEntries)
    {
        [self allCacheEntries];
    }
    ToMCacheEntry *cacheEntry;
    for (int i = 0; i < [allCacheEntries count]; i++)
    {
        cacheEntry = [allCacheEntries objectAtIndex:i];
        switch ([name caseInsensitiveCompare:[cacheEntry name]]) {
            case NSOrderedSame:
                [cacheEntry setName:name];
                [cacheEntry setDuration:duration];
                return;
            case NSOrderedAscending:
                cacheEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ToMCacheEntry" inManagedObjectContext:context];
                [cacheEntry setName:name];
                [cacheEntry setDuration:duration];
                [allCacheEntries insertObject:cacheEntry atIndex:i];
                return;
            default:
                break;
        }
    }
    cacheEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ToMCacheEntry" inManagedObjectContext:context];
    [cacheEntry setName:name];
    [cacheEntry setDuration:duration];
    [allCacheEntries addObject:cacheEntry];
}

- (void)removeItem:(ToMItem *)p cache:(BOOL)cache
{
    if (cache)
    {
        [self insertCacheEntry:p];
    }
    [context deleteObject:p];
    [allItems removeObjectIdenticalTo:p];
}

- (void)removeCacheEntry:(ToMCacheEntry *)p
{
    [context deleteObject:p];
    [allCacheEntries removeObjectIdenticalTo:p];
}

- (void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to)
    {
        return;
    }
    ToMItem *p = [allItems objectAtIndex:from];
    [allItems removeObjectAtIndex:from];
    [allItems insertObject:p atIndex:to];
    [p setOrder:[self allocateOrderValue:to]];
}

- (double)allocateOrderValue:(int)index
{
    if ([allItems count] == 1)
    {
        return 1.0;
    }
    double lowerBound = 0.0;
    if (index > 0)
    {
        lowerBound = [[allItems objectAtIndex:index - 1] order];
    }
    else
    {
        lowerBound = [[allItems objectAtIndex:1] order] - 2.0;
    }
    double upperBound = 0.0;
    if (index < [allItems count] - 1)
    {
        upperBound = [[allItems objectAtIndex:index + 1] order];
    }
    else
    {
        upperBound = [[allItems objectAtIndex:index - 1] order] + 2.0;
    }
    return (lowerBound + upperBound) / 2.0;
}

- (NSArray *)allCacheEntries
{
    if (!allCacheEntries)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"ToMCacheEntry"];
        [request setEntity:e];
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result)
        {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        allCacheEntries = [result mutableCopy];
        [allCacheEntries sortUsingComparator:^(id obj1, id obj2) {
            ToMCacheEntry *ce1 = obj1;
            ToMCacheEntry *ce2 = obj2;
            return [[ce1 name] compare:[ce2 name] options:(NSCaseInsensitiveSearch)];
        }];
    }
    return allCacheEntries;
}

@end
