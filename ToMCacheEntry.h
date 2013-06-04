//
//  ToMCacheEntry.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/31/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ToMCacheEntry : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t duration;

@end
