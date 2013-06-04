//
//  ToMItem.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/22/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ToMItem : NSManagedObject

@property (nonatomic) int32_t duration;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) double order;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval schedTime;
@property (nonatomic) BOOL schedLate;

@end
