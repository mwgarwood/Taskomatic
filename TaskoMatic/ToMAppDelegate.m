//
//  ToMAppDelegate.m
//  TaskoMatic
//
//  Created by Mike Garwood on 5/16/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "ToMAppDelegate.h"
#import "ToMItemsViewController.h"
#import "ToMItemStore.h"
#import "ToMCacheEntriesViewController.h"
#import "ToMAboutViewController.h"

@implementation ToMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // sleep(10);  // for testing launch image
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UITabBarController *tbvc = [[UITabBarController alloc] init];
    ToMItemsViewController *ivc = [[ToMItemsViewController alloc] init];
    UINavigationController *nvc1 = [[UINavigationController alloc] initWithRootViewController:ivc];
    ToMCacheEntriesViewController *cevc = [[ToMCacheEntriesViewController alloc] init];
    UINavigationController *nvc2 = [[UINavigationController alloc] initWithRootViewController:cevc];
    ToMAboutViewController *avc = [[ToMAboutViewController alloc] init];
    [tbvc setViewControllers:[NSArray arrayWithObjects:nvc1, nvc2, avc, nil]];
    [[[[tbvc viewControllers] objectAtIndex:0] tabBarItem] setTitle:@"Active Tasks"];
    [[[[tbvc viewControllers] objectAtIndex:1] tabBarItem] setTitle:@"Cached Tasks"];
    [[[[tbvc viewControllers] objectAtIndex:2] tabBarItem] setTitle:@"About"];
    UIImage *i = [UIImage imageNamed:@"work1.png"];
    [[[[tbvc viewControllers] objectAtIndex:0] tabBarItem] setImage:i];
    i = [UIImage imageNamed:@"blocks1.png"];
    [[[[tbvc viewControllers] objectAtIndex:1] tabBarItem] setImage:i];
    i = [UIImage imageNamed:@"info1.png"];
    [[[[tbvc viewControllers] objectAtIndex:2] tabBarItem] setImage:i];
    [self.window setRootViewController:tbvc];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    (void)[[ToMItemStore sharedStore] saveChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
