//
//  RTTabBarItem.m
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTTabBarItem.h"

@implementation RTTabBarItem

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)reuseIdentifier {
	return [NSStringFromClass([self class]) uppercaseString];
}

- (void)awakeFromNib {
	[super awakeFromNib];

}

- (void)populateWithCaption:(NSString *)caption icon:(UIImage *)image selectedIcon:(UIImage *)selectedImage {

	self.captionLabel.text = caption;
	if (self.selected && selectedImage != nil) {
		self.iconView.image = selectedImage;
	} else {
		self.iconView.image = image;
	}
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

	self.captionLabel.textColor = (selected) ? self.tintColor : nil;
	self.iconView.tintColor = (selected) ? self.tintColor : nil;
}

@end
