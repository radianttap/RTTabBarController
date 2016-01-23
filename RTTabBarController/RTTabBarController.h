//
//  RTTabBarController.h
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RTTabBarControllerMode) {
	RTTabBarControllerModeNormal,
	RTTabBarControllerModeSwitchable,	//	this is default
	RTTabBarControllerModeScrollable
};

@interface RTTabBarController : UIViewController

@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;
@property (nonatomic) NSInteger maximumVisibleTabs;

@property (nonatomic) RTTabBarControllerMode tabBarMode;
@property (nonatomic, getter=isLeadingSidePanelEnabled) BOOL leadingSidePanelEnabled;
@property (nonatomic, getter=isTrailingSidePanelEnabled) BOOL trailingSidePanelEnabled;

@property (nonatomic) NSInteger selectedIndex;
@property (nullable, nonatomic, assign) __kindof UIViewController *selectedViewController;
@property (nullable, nonatomic, assign) __kindof UIViewController *leadingSidePanelViewController;
@property (nullable, nonatomic, assign) __kindof UIViewController *trailingSidePanelViewController;
@property (nonatomic) CGFloat leadingSidePanelBufferWidth;
@property (nonatomic) CGFloat trailingSidePanelBufferWidth;

@end

NS_ASSUME_NONNULL_END