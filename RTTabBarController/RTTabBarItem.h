//
//  RTTabBarItem.h
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface RTTabBarItem : UICollectionViewCell

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;

@property (nonatomic, weak) IBOutlet UILabel *captionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UIImageView *marker;

@property (nonatomic, weak) IBOutlet UIView *badgeContainer;
@property (nonatomic, weak) IBOutlet UILabel *badgeLabel;

- (void)populateWithCaption:(nullable NSString *)caption icon:(nullable UIImage *)image selectedIcon:(nullable UIImage *)selectedImage;
- (void)populateBadgeWith:(NSString *)badgeValue;

@end

NS_ASSUME_NONNULL_END
