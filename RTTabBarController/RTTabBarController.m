//
//  RTTabBarController.m
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTTabBarController.h"
#import "RTTabBarItem.h"

@interface RTTabBarController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout >

@property (nonatomic, strong) UIScrollView *layoutWrapperView;

@property (nonatomic, strong) UIView *leadingSideContainerView;
@property (nonatomic, strong) UIView *trailingSideContainerView;
@property (nonatomic, strong) UIView *mainLayoutView;

@property (nonatomic, strong) UIView *mainContainerView;
@property (nonatomic, strong) UICollectionView *tabItemsCollectionView;

@property (nonatomic, strong) NSLayoutConstraint *leadingSideWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *trailingSideWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tabsHeightConstraint;

@property (nullable, nonatomic, copy) NSArray<__kindof UITabBarItem *> *tabsDataSource;

@end

@implementation RTTabBarController

- (instancetype)init {

	self = [super init];
	if (!self) return nil;

	_viewControllers = nil;
	_tabsDataSource = nil;
	_selectedIndex = NSNotFound;
	_selectedViewController = nil;
	_tabsDataSource = nil;

	_tabsSwitchable = NO;
	_tabsScrollable = NO;
	_leadingSidePanelEnabled = NO;
	_trailingSidePanelEnabled = NO;

	_maximumVisibleTabs = 5;

	return self;
}

#pragma mark - View hierarchy

- (void)loadView {
	[super loadView];

	{
		UIScrollView *v = [UIScrollView new];
		v.scrollEnabled = NO;
		v.showsHorizontalScrollIndicator = NO;
		v.showsVerticalScrollIndicator = NO;
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:v];
		self.layoutWrapperView = v;
	}

	{
		UIView *v = [UIView new];
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[self.layoutWrapperView addSubview:v];
		self.leadingSideContainerView = v;
	}

	{
		UIView *v = [UIView new];
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[self.layoutWrapperView addSubview:v];
		self.mainLayoutView = v;
	}

	{
		UIView *v = [UIView new];
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[self.layoutWrapperView addSubview:v];
		self.trailingSideContainerView = v;
	}

	//	layout
	NSDictionary *vd = @{@"v":  self.view,
						 @"wv": self.layoutWrapperView,
						 @"lv": self.leadingSideContainerView,
						 @"mv": self.mainLayoutView,
						 @"tv": self.trailingSideContainerView};

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[wv]|" options:0 metrics:nil views:vd]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wv]|" options:0 metrics:nil views:vd]];

	[self.layoutWrapperView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[lv][mv][tv]|" options:0 metrics:nil views:vd]];
	[self.layoutWrapperView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lv]|" options:0 metrics:nil views:vd]];
	[self.layoutWrapperView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mv]|" options:0 metrics:nil views:vd]];
	[self.layoutWrapperView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tv]|" options:0 metrics:nil views:vd]];

	//	main container is always as wide as the self.view
	[self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"[mv(v)]" options:0 metrics:nil views:vd] ];
	[self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mv(v)]" options:0 metrics:nil views:vd] ];

	//	side containers are by default 0-wide
	self.leadingSideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.leadingSideContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
	[self.leadingSideContainerView addConstraint:self.leadingSideWidthConstraint];
	self.trailingSideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.trailingSideContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
	[self.trailingSideContainerView addConstraint:self.trailingSideWidthConstraint];

	[self populateMainLayoutView];
}

- (void)populateMainLayoutView {

	{
		UIView *v = [UIView new];
		v.translatesAutoresizingMaskIntoConstraints = NO;
		[self.mainLayoutView addSubview:v];
		self.mainContainerView = v;
	}
	{
		UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
		layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		layout.itemSize = CGSizeMake(44, 54);
		layout.minimumLineSpacing = 1;
		layout.minimumInteritemSpacing = 0;
		layout.sectionInset = UIEdgeInsetsZero;

		UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		collectionView.translatesAutoresizingMaskIntoConstraints = NO;
		collectionView.delegate = self;
		collectionView.dataSource = self;
		collectionView.scrollEnabled = self.areTabsScrollable;
		collectionView.showsVerticalScrollIndicator = NO;
		collectionView.showsHorizontalScrollIndicator = NO;
		collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
		self.tabItemsCollectionView = collectionView;

		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		UIVisualEffectView *blurredBackgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		collectionView.backgroundView = blurredBackgroundView;

		[self.mainLayoutView addSubview:collectionView];
	}

	//	layout
	NSDictionary *vd = @{@"cv": self.mainContainerView, @"tabs": self.tabItemsCollectionView};

	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cv]|" options:0 metrics:nil views:vd]];
	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tabs]|" options:0 metrics:nil views:vd]];
//	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv][tabs]|" options:0 metrics:nil views:vd]];
	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv]|" options:0 metrics:nil views:vd]];

	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tabs]|" options:0 metrics:nil views:vd]];
	self.tabsHeightConstraint = [NSLayoutConstraint constraintWithItem:self.tabItemsCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:54.0];
	[self.tabItemsCollectionView addConstraint:self.tabsHeightConstraint];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.layoutWrapperView.backgroundColor = [UIColor blackColor];
	self.leadingSideContainerView.backgroundColor = [UIColor yellowColor];
	self.trailingSideContainerView.backgroundColor = [UIColor orangeColor];

	self.mainLayoutView.backgroundColor = [UIColor darkGrayColor];
	self.mainContainerView.backgroundColor = [UIColor lightGrayColor];

	[self.tabItemsCollectionView registerNib:[RTTabBarItem nib] forCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier]];

	[self displaySelectedController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.selectedIndex != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
		[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:(self.areTabsScrollable) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];
	}
}

#pragma mark CollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

	CGFloat w = collectionView.bounds.size.width;
	CGFloat h = collectionViewLayout.itemSize.height;

	w -= collectionViewLayout.minimumLineSpacing * (self.maximumVisibleTabs-1);
	CGFloat cellw = w / self.maximumVisibleTabs;

	return CGSizeMake(cellw, h);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	RTTabBarItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier] forIndexPath:indexPath];
	cell.selected = (self.selectedIndex == indexPath.item);
	cell.marker.hidden = !self.areTabsSwitchable;

	UITabBarItem *tbi = self.tabsDataSource[indexPath.item];
	[cell populateWithCaption:tbi.title icon:tbi.image selectedIcon:tbi.selectedImage];

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	self.selectedIndex = indexPath.item;
	[collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(self.areTabsScrollable) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];
}



#pragma mark - Internal API

- (void)displaySelectedController {
	if (!self.isViewLoaded) return;
	if (!self.selectedViewController) return;

	[self.mainContainerView.subviews.firstObject removeFromSuperview];

	UIViewController *vc = self.selectedViewController;

	[self addChildViewController:vc];
	[self.mainContainerView addSubview:vc.view];
	vc.view.translatesAutoresizingMaskIntoConstraints = NO;
	[vc didMoveToParentViewController:self];

	NSDictionary *vd = @{@"iv": vc.view};
	[self.mainContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[iv]|" options:0 metrics:nil views:vd]];
	[self.mainContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[iv]|" options:0 metrics:nil views:vd]];
}






#pragma mark - Public API

- (void)setTabsScrollable:(BOOL)tabsScrollable {

	if (_tabsScrollable == tabsScrollable) return;
	_tabsScrollable = tabsScrollable;

	self.tabItemsCollectionView.scrollEnabled = tabsScrollable;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {

	if (_selectedIndex == selectedIndex) return;
	_selectedIndex = selectedIndex;

	_selectedViewController = self.viewControllers[selectedIndex];

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(self.areTabsScrollable) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];

	[self displaySelectedController];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {

	if (_selectedViewController == selectedViewController) return;
	_selectedViewController = selectedViewController;

	_selectedIndex = [self.viewControllers indexOfObject:selectedViewController];

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(self.areTabsScrollable) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];

	[self displaySelectedController];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {

	if (viewControllers.count == 0) {
		//	remove visible controlers
		//	remove tabs
		return;
	}

	_viewControllers = viewControllers;

	if (self.selectedIndex == NSNotFound) self.selectedIndex = 0;
	self.selectedViewController = viewControllers[self.selectedIndex];

	NSMutableArray <UITabBarItem*> *marr = [NSMutableArray array];
	[viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
		UITabBarItem *tbi = vc.tabBarItem;
		[marr addObject:tbi];
	}];

	self.tabsDataSource = marr;
	[self.tabItemsCollectionView reloadData];
	[self displaySelectedController];
}

- (void)setLeadingSidePanelEnabled:(BOOL)leadingSidePanelEnabled {

}

- (void)setTrailingSidePanelEnabled:(BOOL)trailingSidePanelEnabled {
	
}

@end
