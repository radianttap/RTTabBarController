//
//  RTTabBarController.h
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface RTTabBarController : UIViewController

@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;

@property (nonatomic) NSInteger selectedIndex;
@property (nullable, nonatomic, assign) __kindof UIViewController *selectedViewController;

@end

NS_ASSUME_NONNULL_END