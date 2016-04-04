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

@class RTTabBarItem;

@interface RTTabBarController : UIViewController

@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;
@property (nonatomic) NSInteger maximumVisibleTabs;
@property (nullable, nonatomic, strong, readonly) NSMutableArray<__kindof UIViewController *> *visibleViewControllers;
@property (nonatomic, getter=shouldBlurMainContentWhenSidePanelAppears) BOOL blurMainContentWhenSidePanelAppears;

@property (nonatomic) RTTabBarControllerMode tabBarMode;
@property (nonatomic, getter=isLeadingSidePanelEnabled) BOOL leadingSidePanelEnabled;
@property (nonatomic, getter=isTrailingSidePanelEnabled) BOOL trailingSidePanelEnabled;

@property (nonatomic) NSInteger selectedIndex;
@property (nullable, nonatomic, assign) __kindof UIViewController *selectedViewController;
@property (nullable, nonatomic, assign) __kindof UIViewController *leadingSidePanelViewController;
@property (nullable, nonatomic, assign) __kindof UIViewController *trailingSidePanelViewController;
@property (nonatomic) CGFloat leadingSidePanelBufferWidth;
@property (nonatomic) CGFloat trailingSidePanelBufferWidth;

- (void)hideLeadingSidePanel;
- (void)hideTrailingSidePanel;

/**
 *	Go through viewControllers array and if there's a VC (even if it's wrapped inside Navigation Controller) with sentClass, display it
 *	Existing tabs are not changed, unless the found VC is one of the visible tabs - then the tab is selected
 *
 *	@param sentClass	Class of the view controllers that should be display
 */
- (void)showViewControllerWithClass:(Class)sentClass;

/**
 *	Append the sent controller into viewControllers and forcefully inject at sent tab index position.
 *	If the value of index is higher then maximumVisibleTabs, then VC is still added and it's contnet shown, but tabs are left unchanged
 *
 *	@param vc		View Controller instance to append/show
 *	@param index	Index of the tab where the sent VC should be injected
 */
- (void)injectViewController:(UIViewController *)vc atIndex:(NSInteger)index;


- (nullable RTTabBarItem *)tabItemAtIndex:(NSInteger)idx;

@end

NS_ASSUME_NONNULL_END
