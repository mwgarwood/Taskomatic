//
//  ToMItem.h
//  TaskoMatic
//
//  Created by Mike Garwood on 6/17/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ToMItem : NSManagedObject

@property (nonatomic) BOOL completed;
@property (nonatomic) int32_t duration;
@property (nonatomic) BOOL enableNotif;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval notifScheduled;
@property (nonatomic) double order;
@property (nonatomic) BOOL schedLate;
@property (nonatomic) NSTimeInterval schedTime;
@property (nonatomic) NSTimeInterval startTime;

@end
