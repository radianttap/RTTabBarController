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
@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic) CGFloat leftEdgeOffset;
@property (nonatomic) CGFloat cvWidth;

@end

@protocol RTTabPickerControllerDelegate <NSObject>
- (void)tabPickerController:(RTTabPickerController *)controller didSelectItemAtIndex:(NSInteger)index;
//- (void)tabPickerController:(RTTabPickerController *)controller didSelectVC:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END