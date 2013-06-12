//
//  ToMAppDelegate.h
//  TaskoMatic
//
//  Created by Mike Garwood on 5/16/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToMItemsViewController;

@interface ToMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ToMItemsViewController *itemsViewController;

@end
