//
//  RTTabBarItem.m
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTTabBarItem.h"

@interface RTTabBarItem ()

@property (nonatomic, weak) UIImage *image;
@property (nonatomic, weak) UIImage *selectedImage;

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
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

	self.captionLabel.textColor = (selected) ? self.tintColor : [UIColor grayColor];
	self.iconView.tintColor = self.captionLabel.textColor;
	[self populateIcon];
}

- (void)populateIcon {

	if (self.selected && self.selectedImage != nil) {
		self.iconView.image = self.selectedImage;
	} else {
		self.iconView.image = self.image;
	}
}

@end
