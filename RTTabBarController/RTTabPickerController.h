//
//  RTTabPickerController.h
//  RTTabBarController DEMO
//
//  Created by Aleksandar Vacić on 23.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTTabPickerControllerDelegate;
@interface RTTabPickerController : UIViewController

@property (nonatomic, weak) id< RTTabPickerControllerDelegate > delegate;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nullable, nonatomic, copy, readonly) NSArray<__kindof UIViewController *> *dataSource;

@end

@protocol RTTabPickerControllerDelegate <NSObject>
- (NSArray<__kindof UIViewController *> *)itemsForTabPickerController:(RTTabPickerController *)controller;

- (void)tabPickerController:(RTTabPickerController *)controller didSelectItemAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END