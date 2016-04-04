//
//  RTTabBarItem.m
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTTabBarItem.h"

@interface RTTabBarItem ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation RTTabBarItem

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)reuseIdentifier {
	return [NSStringFromClass([self class]) uppercaseString];
}

- (void)awakeFromNib {
	[super awakeFromNib];

	_image = nil;
	_selectedImage = nil;

	self.captionLabel.textColor = [UIColor grayColor];
	self.iconView.tintColor = self.captionLabel.textColor;
	self.marker.tintColor = [UIColor grayColor];
	self.badgeContainer.alpha = 0;
	self.badgeContainer.backgroundColor = [UIColor redColor];

	self.badgeContainer.layer.cornerRadius = self.badgeContainer.frame.size.width / 2.0;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	_image = nil;
	_selectedImage = nil;
}

- (void)populateWithCaption:(NSString *)caption icon:(UIImage *)image selectedIcon:(UIImage *)selectedImage {

	self.image = image;
	self.selectedImage = selectedImage;

	self.captionLabel.text = caption;
	[self populateIcon];
	self.captionLabel.textColor = (self.selected) ? self.tintColor : [UIColor grayColor];
	self.iconView.tintColor = self.captionLabel.textColor;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

	[self populateIcon];
	self.captionLabel.textColor = (selected) ? self.tintColor : [UIColor grayColor];
	self.iconView.tintColor = self.captionLabel.textColor;
}

- (void)populateIcon {

	if (self.selected && self.selectedImage != nil) {
		self.iconView.image = self.selectedImage;
	} else {
		self.iconView.image = self.image;
	}
}

- (void)populateBadgeWith:(NSString *)badgeValue {

	if (badgeValue.length == 0) {
		self.badgeContainer.alpha = 0;
		return;
	}

	self.badgeLabel.text = badgeValue;
	self.badgeContainer.alpha = 1;
}

@end
