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

@end

NS_ASSUME_NONNULL_END