//
//  RTTabBarController.m
//  RTTabBarController
//
//  Created by Aleksandar Vacić on 21.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTTabBarController.h"
#import "RTTabBarItem.h"
#import "RTTabPickerController.h"

@interface RTTabBarController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RTTabPickerControllerDelegate >

@property (nonatomic, strong) UIScrollView *layoutWrapperView;

@property (nonatomic, strong) UIView *leadingSideContainerView;
@property (nonatomic, strong) UIView *trailingSideContainerView;
@property (nonatomic, strong) UIView *mainLayoutView;

@property (nonatomic, strong) UIView *mainContainerView;
@property (nonatomic, strong) UICollectionView *tabItemsCollectionView;
@property (nonatomic, strong) UILongPressGestureRecognizer *tabPickerGR;
@property (nonatomic, strong) RTTabPickerController *tabPicker;
@property (nullable, nonatomic, strong) NSIndexPath *pickerIndexPath;

@property (nonatomic, strong) UIView *mainCoverView;
@property (nonatomic, strong) UITapGestureRecognizer *coverTapGR;
@property (nonatomic, getter=isLeadingSidePanelShown) BOOL leadingSidePanelShown;
@property (nonatomic, getter=isTrailingSidePanelShown) BOOL trailingSidePanelShown;

@property (nonatomic, strong) NSLayoutConstraint *leadingSideWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leadingSideWidthMatchConstraint;
@property (nonatomic, strong) NSLayoutConstraint *trailingSideWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *trailingSideWidthMatchConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tabsHeightConstraint;

@property (nullable, nonatomic, strong) NSMutableArray<__kindof UITabBarItem *> *tabsDataSource;
@property (nullable, nonatomic, strong) NSMutableArray<__kindof UIViewController *> *visibleViewControllers;

@end

@implementation RTTabBarController

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return self.isLeadingSidePanelShown || self.isTrailingSidePanelShown;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationSlide;
}

- (instancetype)init {

	self = [super init];
	if (!self) return nil;

	_viewControllers = nil;
	_tabsDataSource = nil;
	_selectedIndex = NSNotFound;
	_selectedViewController = nil;
	_leadingSidePanelViewController = nil;
	_trailingSidePanelViewController = nil;

	_tabBarMode = RTTabBarControllerModeSwitchable;
	_leadingSidePanelEnabled = NO;
	_trailingSidePanelEnabled = NO;

	_leadingSidePanelBufferWidth = 44.0;
	_trailingSidePanelBufferWidth = 44.0;
	_leadingSidePanelShown = NO;
	_trailingSidePanelShown = NO;

	_maximumVisibleTabs = 5;
	_visibleViewControllers = [NSMutableArray array];

	_blurMainContentWhenSidePanelAppears = NO;

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
		v.clipsToBounds = YES;
		[self.layoutWrapperView addSubview:v];
		self.leadingSideContainerView = v;
	}

	{
		UIView *v = [UIView new];
		v.translatesAutoresizingMaskIntoConstraints = NO;
		v.clipsToBounds = YES;
		[self.layoutWrapperView addSubview:v];
		self.mainLayoutView = v;
	}

	{
		UIView *v = [UIView new];
		v.translatesAutoresizingMaskIntoConstraints = NO;
		v.clipsToBounds = YES;
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
	self.leadingSideWidthConstraint.active = YES;
	//	when enabled they should match the width of the screen - 44.0, as option to tap and go back
	self.leadingSideWidthMatchConstraint = [NSLayoutConstraint constraintWithItem:self.leadingSideContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-self.leadingSidePanelBufferWidth];
	[self.view addConstraint:self.leadingSideWidthMatchConstraint];
	self.leadingSideWidthMatchConstraint.active = NO;

	self.trailingSideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.trailingSideContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
	[self.trailingSideContainerView addConstraint:self.trailingSideWidthConstraint];
	self.trailingSideWidthConstraint.active = YES;
	//	when enabled they should match the width of the screen - 44.0, as option to tap and go back
	self.trailingSideWidthMatchConstraint = [NSLayoutConstraint constraintWithItem:self.trailingSideContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-self.trailingSidePanelBufferWidth];
	[self.view addConstraint:self.trailingSideWidthMatchConstraint];
	self.trailingSideWidthMatchConstraint.active = NO;

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
		layout.minimumLineSpacing = 0;
		layout.minimumInteritemSpacing = 0;
		layout.sectionInset = UIEdgeInsetsZero;

		UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		collectionView.translatesAutoresizingMaskIntoConstraints = NO;
		collectionView.delegate = self;
		collectionView.dataSource = self;
		collectionView.scrollEnabled = (self.tabBarMode == RTTabBarControllerModeScrollable);
		collectionView.showsVerticalScrollIndicator = NO;
		collectionView.showsHorizontalScrollIndicator = NO;
		collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
		self.tabItemsCollectionView = collectionView;

		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		UIVisualEffectView *blurredBackgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		collectionView.backgroundView = blurredBackgroundView;

		[self.mainLayoutView addSubview:collectionView];
	}

	{
		if (self.shouldBlurMainContentWhenSidePanelAppears) {
			UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			UIVisualEffectView *coverView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
			coverView.translatesAutoresizingMaskIntoConstraints = NO;
			coverView.hidden = YES;
			self.mainCoverView = coverView;
			[self.mainLayoutView addSubview:coverView];
		} else {
			UIView *v = [UIView new];
			v.translatesAutoresizingMaskIntoConstraints = NO;
			v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
			v.hidden = YES;
			self.mainCoverView = v;
			[self.mainLayoutView addSubview:v];
		}
	}

	//	layout
	NSDictionary *vd = @{@"cv": self.mainContainerView, @"tabs": self.tabItemsCollectionView, @"cover": self.mainCoverView};

	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cv]|" options:0 metrics:nil views:vd]];
	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tabs]|" options:0 metrics:nil views:vd]];
//	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv][tabs]|" options:0 metrics:nil views:vd]];
	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv]|" options:0 metrics:nil views:vd]];

	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tabs]|" options:0 metrics:nil views:vd]];
	self.tabsHeightConstraint = [NSLayoutConstraint constraintWithItem:self.tabItemsCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:54.0];
	[self.tabItemsCollectionView addConstraint:self.tabsHeightConstraint];

	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cover]|" options:0 metrics:nil views:vd]];
	[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cover]|" options:0 metrics:nil views:vd]];
}

#pragma mark - Cover view behavior

- (void)setupCoverView {
	if (self.tabBarMode == RTTabBarControllerModeScrollable) return;

	UITapGestureRecognizer *tapgr = [UITapGestureRecognizer new];
	[tapgr addTarget:self action:@selector(coverViewTapped:)];
	[self.mainCoverView addGestureRecognizer:tapgr];
	self.mainCoverView.userInteractionEnabled = YES;
	self.coverTapGR = tapgr;
}

- (void)coverViewTapped:(UITapGestureRecognizer *)gr {

	if (self.isLeadingSidePanelShown) {
		[self hideLeadingSidePanel];
	} else if (self.isTrailingSidePanelShown) {
		[self hideTrailingSidePanel];
	}

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(self.tabItemsCollectionView.scrollEnabled) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];
}

#pragma mark - Tab picker

- (void)setupTabPicker {
	if (self.tabBarMode != RTTabBarControllerModeSwitchable) return;

	UILongPressGestureRecognizer *gr = [UILongPressGestureRecognizer new];
	[gr addTarget:self action:@selector(tabPickerInitiated:)];
	[self.tabItemsCollectionView addGestureRecognizer:gr];
	self.tabPickerGR = gr;
}

- (void)tabPickerInitiated:(UILongPressGestureRecognizer *)gr {

	if (gr.state == UIGestureRecognizerStateBegan) {
		if (self.tabPicker) {
			[self cleanupTabPicker];
		}
		
		CGPoint p = [gr locationInView:gr.view];
		NSIndexPath *indexPath = [self.tabItemsCollectionView indexPathForItemAtPoint:p];
		if (!indexPath) return;
		BOOL isLeadingSidePanelItem = (indexPath.item == 0 && self.isLeadingSidePanelEnabled);
		BOOL isTrailingSidePanelItem = (indexPath.item == self.tabsDataSource.count - 1 && self.isTrailingSidePanelEnabled);
		if (isLeadingSidePanelItem || isTrailingSidePanelItem) return;

		self.pickerIndexPath = indexPath;

		RTTabPickerController *picker = [RTTabPickerController new];
		picker.delegate = self;
		//	needed for height
		NSArray *arr = [self.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.visibleViewControllers]];
		CGFloat h = arr.count * (54.0 + 8.0);
		//	show it
		[self addChildViewController:picker];
		[self.mainLayoutView addSubview:picker.view];
		picker.view.translatesAutoresizingMaskIntoConstraints = NO;
		[picker didMoveToParentViewController:self];
		self.tabPicker = picker;

		RTTabBarItem *cell = (RTTabBarItem *)[self.tabItemsCollectionView cellForItemAtIndexPath:self.pickerIndexPath];
		NSDictionary *vd = @{@"cv": self.tabPicker.view, @"av": cell, @"tabs": self.tabItemsCollectionView};
		[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[cv(h@750)][tabs]|" options:0 metrics:@{@"h":@(h)} views:vd]];
		//	width
		[self.mainLayoutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[cv(av)]" options:0 metrics:nil views:vd]];
		//	left edge position
		[self.mainLayoutView addConstraint:[NSLayoutConstraint constraintWithItem:self.tabPicker.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
		//	layout
		[self.mainLayoutView layoutIfNeeded];

		[UIView animateWithDuration:.3 animations:^{
			self.mainContainerView.alpha = .4;
		}];
	}
}

- (NSArray<UIViewController *> *)itemsForTabPickerController:(RTTabPickerController *)controller {

	NSArray *arr = [self.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.visibleViewControllers]];
	return arr;
}

- (void)tabPickerController:(RTTabPickerController *)controller didSelectItemAtIndex:(NSInteger)index {

	NSArray *arr = [self.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.visibleViewControllers]];
	UIViewController *vc = arr[index];
	self.visibleViewControllers[self.pickerIndexPath.item] = vc;
	self.tabsDataSource[self.pickerIndexPath.item] = vc.tabBarItem;
	[self.tabItemsCollectionView reloadItemsAtIndexPaths:@[self.pickerIndexPath]];

	if (self.selectedIndex == self.pickerIndexPath.item) {
		self.selectedViewController = self.visibleViewControllers[self.selectedIndex];
	}
	[self cleanupTabPicker];
}

- (void)cleanupTabPicker {

	[UIView animateWithDuration:.3 animations:^{
		self.mainContainerView.alpha = 1;
	}];
	[self removeController:self.tabPicker];
	self.tabPicker = nil;
	self.pickerIndexPath = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.layoutWrapperView.backgroundColor = [UIColor darkGrayColor];
	self.mainLayoutView.backgroundColor = [UIColor blackColor];
	self.mainContainerView.backgroundColor = [UIColor darkGrayColor];

	[self.tabItemsCollectionView registerNib:[RTTabBarItem nib] forCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier]];
	[self setupCoverView];

	[self processViewControllers];
	[self setupTabPicker];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.selectedIndex != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
		[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:(self.tabItemsCollectionView.scrollEnabled) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];
	}
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

	//	relayout tabs
	[self.tabItemsCollectionView.collectionViewLayout invalidateLayout];
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - CollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

	CGFloat w = collectionView.bounds.size.width;
	CGFloat h = collectionViewLayout.itemSize.height;

	w -= collectionViewLayout.minimumLineSpacing * (self.tabsDataSource.count - 1);
	CGFloat cellw = w / self.tabsDataSource.count;

	return CGSizeMake(cellw, h);
}

#pragma mark Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.tabsDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	RTTabBarItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier] forIndexPath:indexPath];
	cell.selected = (self.selectedIndex == indexPath.item);
	BOOL isLeadingSidePanelItem = (indexPath.item == 0 && self.isLeadingSidePanelEnabled);
	BOOL isTrailingSidePanelItem = (indexPath.item == self.tabsDataSource.count - 1 && self.isTrailingSidePanelEnabled);
	cell.marker.hidden = (self.tabBarMode != RTTabBarControllerModeSwitchable || isLeadingSidePanelItem || isTrailingSidePanelItem);

	UITabBarItem *tbi = self.tabsDataSource[indexPath.item];
	[cell populateWithCaption:tbi.title icon:tbi.image selectedIcon:tbi.selectedImage];

	return cell;
}

#pragma mark Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	if (self.tabPicker) {
		[self cleanupTabPicker];
	}

	BOOL isLeadingSidePanelItem = (indexPath.item == 0 && self.isLeadingSidePanelEnabled);
	BOOL isTrailingSidePanelItem = (indexPath.item == self.tabsDataSource.count - 1 && self.isTrailingSidePanelEnabled);
	if (isLeadingSidePanelItem) {
		[self revealLeadingSidePanel];
		[collectionView deselectItemAtIndexPath:indexPath animated:NO];
		return;
	} else if (isTrailingSidePanelItem) {
		[self revealTrailingSidePanel];
		[collectionView deselectItemAtIndexPath:indexPath animated:NO];
		return;
	}

	self.selectedIndex = indexPath.item;
}



#pragma mark - Internal API

- (void)loadController:(UIViewController *)vc intoView:(UIView *)containerView {
	if (!vc || !containerView) return;

	[self addChildViewController:vc];
	[containerView addSubview:vc.view];
	vc.view.translatesAutoresizingMaskIntoConstraints = NO;
	[vc didMoveToParentViewController:self];
	NSDictionary *vd = @{@"iv": vc.view};
	[containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[iv]|" options:0 metrics:nil views:vd]];
	[containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[iv]|" options:0 metrics:nil views:vd]];
}

- (void)removeController:(UIViewController *)vc {
	if (!vc) return;

	[vc willMoveToParentViewController:nil];
	[vc.view removeFromSuperview];	//	this clears out embedded child view, but box stays inside boxesScrollView
	[vc removeFromParentViewController];
}

- (void)processViewControllers {

	NSMutableArray <UITabBarItem*> *marr = [NSMutableArray array];
	NSMutableArray <__kindof UIViewController*> *varr = [NSMutableArray array];
	[self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
		if (self.tabBarMode == RTTabBarControllerModeSwitchable || self.tabBarMode == RTTabBarControllerModeNormal) {
			if (idx >= self.maximumVisibleTabs) {
				*stop = YES;
				return;
			}
		}
		[varr addObject:vc];

		if ([vc isKindOfClass:[UINavigationController class]]) {
			UIViewController *realVC = [(UINavigationController *)vc viewControllers].firstObject;
			UITabBarItem *tbi = realVC.tabBarItem;
			[marr addObject:tbi];
		} else {
			UITabBarItem *tbi = vc.tabBarItem;
			[marr addObject:tbi];
		}
	}];

	self.visibleViewControllers = varr;
	self.tabsDataSource = marr;
	[self.tabItemsCollectionView reloadData];

	_leadingSidePanelViewController = varr.firstObject;
	_trailingSidePanelViewController = varr.lastObject;

	if (self.selectedIndex == NSNotFound) {
		if (self.isLeadingSidePanelEnabled) {
			_selectedIndex = 1;
		} else {
			_selectedIndex = 0;
		}
		_selectedViewController = self.visibleViewControllers[self.selectedIndex];
	}

	[self displaySelectedController];
}

#pragma mark

- (void)displaySelectedController {
	if (!self.isViewLoaded) return;
	if (!self.selectedViewController) return;

	UIViewController *vc = self.selectedViewController;
	[self loadController:vc intoView:self.mainContainerView];
}

#pragma mark

- (void)revealLeadingSidePanel {

	UIViewController *vc = self.leadingSidePanelViewController;
	[self loadController:vc intoView:self.leadingSideContainerView];

	self.leadingSidePanelShown = YES;
	[self setNeedsStatusBarAppearanceUpdate];

	self.leadingSideWidthConstraint.active = NO;
	self.leadingSideWidthMatchConstraint.active = YES;
	[UIView animateWithDuration:.4
						  delay:0
		 usingSpringWithDamping:.96
		  initialSpringVelocity:12
						options:0
					 animations:^{
						 [self.view layoutIfNeeded];
						 self.mainCoverView.hidden = NO;
					 } completion:^(BOOL finished) {
						 if (!finished) return;
					 }];
}

- (void)hideLeadingSidePanel {

	UIViewController *vc = self.leadingSidePanelViewController;
	[self removeController:vc];

	self.leadingSidePanelShown = NO;
	[self setNeedsStatusBarAppearanceUpdate];

	self.leadingSideWidthMatchConstraint.active = NO;
	self.leadingSideWidthConstraint.active = YES;
	[UIView animateWithDuration:.4
						  delay:0
		 usingSpringWithDamping:.96
		  initialSpringVelocity:12
						options:0
					 animations:^{
						 [self.view layoutIfNeeded];
						 self.mainCoverView.hidden = YES;
					 } completion:^(BOOL finished) {
						 if (!finished) return;
					 }];
}

#pragma mark

- (void)revealTrailingSidePanel {

	UIViewController *vc = self.trailingSidePanelViewController;
	[self loadController:vc intoView:self.trailingSideContainerView];

	self.trailingSidePanelShown = YES;
	[self setNeedsStatusBarAppearanceUpdate];

	self.trailingSideWidthConstraint.active = NO;
	self.trailingSideWidthMatchConstraint.active = YES;
	[UIView animateWithDuration:.4
						  delay:0
		 usingSpringWithDamping:.96
		  initialSpringVelocity:12
						options:0
					 animations:^{
						 [self.view layoutIfNeeded];
						 [self.layoutWrapperView scrollRectToVisible:self.trailingSideContainerView.frame animated:NO];
						 self.mainCoverView.hidden = NO;
					 } completion:^(BOOL finished) {
						 if (!finished) return;
					 }];
}

- (void)hideTrailingSidePanel {

	UIViewController *vc = self.trailingSidePanelViewController;
	[self removeController:vc];

	self.trailingSidePanelShown = NO;
	[self setNeedsStatusBarAppearanceUpdate];

	self.trailingSideWidthMatchConstraint.active = NO;
	self.trailingSideWidthConstraint.active = YES;
	[UIView animateWithDuration:.4
						  delay:0
		 usingSpringWithDamping:.96
		  initialSpringVelocity:12
						options:0
					 animations:^{
						 [self.view layoutIfNeeded];
						 [self.layoutWrapperView scrollRectToVisible:self.mainLayoutView.frame animated:NO];
						 self.mainCoverView.hidden = YES;
					 } completion:^(BOOL finished) {
						 if (!finished) return;
					 }];
}




#pragma mark - Public API

- (void)setSelectedIndex:(NSInteger)selectedIndex {

	if (_selectedIndex == selectedIndex) return;
	[self removeController:self.selectedViewController];
	_selectedIndex = selectedIndex;
	_selectedViewController = self.visibleViewControllers[selectedIndex];

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(self.tabItemsCollectionView.scrollEnabled) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];

	[self displaySelectedController];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {

	if ([_selectedViewController isEqual:selectedViewController]) return;
	[self removeController:self.selectedViewController];
	_selectedViewController = selectedViewController;
	_selectedIndex = [self.visibleViewControllers indexOfObject:selectedViewController];

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.tabItemsCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(self.tabItemsCollectionView.scrollEnabled) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];

	[self displaySelectedController];
}

- (void)injectViewController:(UIViewController *)vc atIndex:(NSInteger)index {

	NSMutableArray *vcarr = [self.viewControllers mutableCopy];
	[vcarr addObject:vc];
	_viewControllers = vcarr;

	if (index < self.maximumVisibleTabs) {
		NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
		//	update data sources
		self.visibleViewControllers[pickerIndexPath.item] = vc;
		self.tabsDataSource[pickerIndexPath.item] = vc.tabBarItem;
		//	reload tabs
		[self.tabItemsCollectionView reloadItemsAtIndexPaths:@[pickerIndexPath]];
		//	make it selected and display the content
		self.selectedViewController = self.visibleViewControllers[index];
	}
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {

	if ([_viewControllers isEqualToArray:viewControllers]) return;

	//	CLEAN UP

	//	remove all displayed controllers
	[self removeController:self.selectedViewController];
	self.selectedViewController = nil;
	[self removeController:self.leadingSidePanelViewController];
	self.leadingSidePanelViewController = nil;
	[self removeController:self.trailingSidePanelViewController];
	self.trailingSidePanelViewController = nil;

	if (viewControllers.count == 0) {
		//	remove visible controlers
		_viewControllers = nil;
		[self.visibleViewControllers removeAllObjects];
		//	remove tabs
		self.tabsDataSource = nil;
		[self.tabItemsCollectionView reloadData];
		//	clean up
		_selectedIndex = NSNotFound;
		_selectedViewController = nil;
		self.leadingSidePanelViewController = nil;
		self.trailingSidePanelViewController = nil;
		return;
	}

	//	SETUP NEW Controllers

	_viewControllers = viewControllers;
	if (!self.isViewLoaded) return;

	[self processViewControllers];
}

- (void)setLeadingSidePanelEnabled:(BOOL)leadingSidePanelEnabled {

	if (self.tabBarMode == RTTabBarControllerModeScrollable) {
		_leadingSidePanelEnabled = NO;
		return;
	}
	if (_leadingSidePanelEnabled == leadingSidePanelEnabled) return;
	_leadingSidePanelEnabled = leadingSidePanelEnabled;
}

- (void)setTrailingSidePanelEnabled:(BOOL)trailingSidePanelEnabled {

	if (self.tabBarMode == RTTabBarControllerModeScrollable) {
		_trailingSidePanelEnabled = NO;
		return;
	}
	if (_trailingSidePanelEnabled == trailingSidePanelEnabled) return;
	_trailingSidePanelEnabled = trailingSidePanelEnabled;
}

- (void)setLeadingSidePanelBufferWidth:(CGFloat)leadingSidePanelBufferWidth {

	if (_leadingSidePanelBufferWidth == leadingSidePanelBufferWidth) return;
	_leadingSidePanelBufferWidth = leadingSidePanelBufferWidth;

	self.leadingSideWidthMatchConstraint.constant = leadingSidePanelBufferWidth;
	if (self.isLeadingSidePanelShown) {
		[UIView animateWithDuration:.4
							  delay:0
			 usingSpringWithDamping:.96
			  initialSpringVelocity:12
							options:0
						 animations:^{
							 [self.view layoutIfNeeded];
							 [self.layoutWrapperView scrollRectToVisible:self.leadingSideContainerView.frame animated:NO];
						 } completion:nil];
	}
}

- (void)setTrailingSidePanelBufferWidth:(CGFloat)trailingSidePanelBufferWidth {

	if (_trailingSidePanelBufferWidth == trailingSidePanelBufferWidth) return;
	_trailingSidePanelBufferWidth = trailingSidePanelBufferWidth;

	self.trailingSideWidthMatchConstraint.constant = trailingSidePanelBufferWidth;
	if (self.isTrailingSidePanelShown) {
		[UIView animateWithDuration:.4
							  delay:0
			 usingSpringWithDamping:.96
			  initialSpringVelocity:12
							options:0
						 animations:^{
							 [self.view layoutIfNeeded];
							 [self.layoutWrapperView scrollRectToVisible:self.trailingSideContainerView.frame animated:NO];
						 } completion:nil];
	}
}


#pragma mark - Content Containment

- (void)showViewController:(UIViewController *)vc sender:(id)sender {
	//	replaces the sender controller with the sent VC, if sender is not side-panel
	//	if sender is not found in visible controllers or is in side panels, then present the sent VC

	NSInteger tabIndex = [self tabIndexForSenderViewController:sender];
	BOOL shouldPresent = NO;

	if (tabIndex == NSNotFound) {
		shouldPresent = YES;
	} else if (tabIndex == 0 && self.isLeadingSidePanelEnabled) {
		shouldPresent = YES;
	} else if (tabIndex == self.visibleViewControllers.count-1 && self.isTrailingSidePanelShown) {
		shouldPresent = YES;
	}

	[self showViewController:vc presented:shouldPresent orAtTabIndex:tabIndex];
}

- (void)showDetailViewController:(UIViewController *)vc sender:(id)sender {
	//	if sender is from one of side panels, then load sent VC into middle part
	//	otherwise, just present it

	NSInteger tabIndex = [self tabIndexForSenderViewController:sender];
	BOOL shouldPresent = YES;

	if (tabIndex == 0 && self.isLeadingSidePanelEnabled) {
		shouldPresent = NO;
		tabIndex = 1;	//	replace 2nd tab (1st after side panel tab)
		[self hideLeadingSidePanel];
	} else if (tabIndex == self.visibleViewControllers.count-1 && self.isTrailingSidePanelShown) {
		shouldPresent = NO;
		tabIndex = self.visibleViewControllers.count-2;	//	replace second to last tab (1st to the left of right panel tab)
		[self hideTrailingSidePanel];
	}

	[self showViewController:vc presented:shouldPresent orAtTabIndex:tabIndex];
}

#pragma mark Internal containment stuff

- (NSInteger)tabIndexForSenderViewController:(UIViewController *)sender {

	__block NSInteger tabIndex = NSNotFound;
	[self.visibleViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if ([sender isEqual:obj]) {
			tabIndex = idx;
			*stop = YES;
		}
	}];
	return tabIndex;
}

- (void)showViewController:(UIViewController *)vc presented:(BOOL)shouldPresent orAtTabIndex:(NSInteger)tabIndex {

	if (shouldPresent) {
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
		nc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
		[self presentViewController:nc animated:YES completion:nil];
		return;
	}

	//	should it also be added to viewControllers?

	NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForItem:tabIndex inSection:0];
	//	update data sources
	self.visibleViewControllers[pickerIndexPath.item] = vc;
	self.tabsDataSource[pickerIndexPath.item] = vc.tabBarItem;
	//	reload tabs
	[self.tabItemsCollectionView reloadItemsAtIndexPaths:@[pickerIndexPath]];
	//	make it selected and display the content
	self.selectedViewController = self.visibleViewControllers[tabIndex];
}

@end
