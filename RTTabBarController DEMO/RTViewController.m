//
//  RTViewController.m
//  RTTabBarController DEMO
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTViewController.h"

@interface RTViewController ()

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *viewTitle;

@end

@implementation RTViewController

- (void)setupTabContent {

	self.tabBarItem.image = [UIImage imageNamed:self.imageName];
	self.tabBarItem.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"sel%@", self.imageName]];
	self.tabBarItem.title = self.viewTitle;
}

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)icon {

	self = [super init];
	if (!self) return nil;

	self.imageName = icon;
	self.viewTitle = title;
	[self setupTabContent];

	return self;
}

- (void)loadView {
	[super loadView];

	UIImageView *iv = [UIImageView new];
	iv.contentMode = UIViewContentModeScaleAspectFill;
	iv.translatesAutoresizingMaskIntoConstraints = NO;
	self.photoView = iv;
	[self.view addSubview:iv];

	NSDictionary *vd = @{@"iv": iv};
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[iv]|" options:0 metrics:nil views:vd]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[iv]|" options:0 metrics:nil views:vd]];
}

@end
