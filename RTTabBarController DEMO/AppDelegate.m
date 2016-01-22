//
//  AppDelegate.m
//  RTTabBarController DEMO
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "AppDelegate.h"

#import "RTTabBarController.h"
#import "RTViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	NSMutableArray *marr = [NSMutableArray array];
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Bookmarks" iconName:@"icon-bookmarks"];
		[vc.photoView setImage:[UIImage imageNamed:@"01"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Chats" iconName:@"icon-chats"];
		[vc.photoView setImage:[UIImage imageNamed:@"02"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Contacts" iconName:@"icon-contacts"];
		[vc.photoView setImage:[UIImage imageNamed:@"03"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Favorites" iconName:@"icon-favs"];
		[vc.photoView setImage:[UIImage imageNamed:@"04"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Around me" iconName:@"icon-locations"];
		[vc.photoView setImage:[UIImage imageNamed:@"05"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Playlists" iconName:@"icon-music"];
		[vc.photoView setImage:[UIImage imageNamed:@"06"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Recents" iconName:@"icon-recent"];
		[vc.photoView setImage:[UIImage imageNamed:@"07"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Settings" iconName:@"icon-settings"];
		[vc.photoView setImage:[UIImage imageNamed:@"08"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Stopwatch" iconName:@"icon-stopwatch"];
		[vc.photoView setImage:[UIImage imageNamed:@"09"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"World" iconName:@"icon-world"];
		[vc.photoView setImage:[UIImage imageNamed:@"10"]];
		[marr addObject:vc];
	}
	{
		RTViewController *vc = [[RTViewController alloc] initWithTitle:@"Trash" iconName:@"icon-trash"];
		[vc.photoView setImage:[UIImage imageNamed:@"11"]];
		[marr addObject:vc];
	}

	RTTabBarController *tc = [RTTabBarController new];
	tc.viewControllers = marr;
//	tc.tabsScrollable = YES;
	self.window.rootViewController = tc;

	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
