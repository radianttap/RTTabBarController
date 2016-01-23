//
//  RTTabPickerController.m
//  RTTabBarController DEMO
//
//  Created by Aleksandar Vacić on 23.1.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTTabPickerController.h"
#import "RTTabBarItem.h"






@interface RTTabPickerLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSMutableDictionary *cachedLayoutAttributes;

@end

@implementation RTTabPickerLayout

- (instancetype)init {

	self = [super init];

	self.scrollDirection = UICollectionViewScrollDirectionVertical;
	self.itemSize = CGSizeMake(44, 54);
	self.minimumLineSpacing = 8;
	self.minimumInteritemSpacing = 0;
	self.sectionInset = UIEdgeInsetsZero;

	_cachedLayoutAttributes = [NSMutableDictionary dictionary];

	return self;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {

	UICollectionViewFlowLayoutInvalidationContext *context = (UICollectionViewFlowLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
	context.invalidateFlowLayoutDelegateMetrics = (
												   CGRectGetWidth(newBounds) != CGRectGetWidth(self.collectionView.bounds) ||
												   CGRectGetHeight(newBounds) != CGRectGetHeight(self.collectionView.bounds)
												   );
	return context;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {

	NSArray<UICollectionViewLayoutAttributes *> *attrs = [super layoutAttributesForElementsInRect:rect];

	[attrs enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		self.cachedLayoutAttributes[obj.indexPath] = obj;
	}];

	return attrs;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {

	UICollectionViewLayoutAttributes *attr = [[self layoutAttributesForItemAtIndexPath:itemIndexPath] copy];
	CGRect f = attr.frame;
	f.origin.y = self.collectionView.bounds.size.height * 2;
	attr.frame = f;
	return attr;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {

	UICollectionViewLayoutAttributes *attr = [self.cachedLayoutAttributes[itemIndexPath] copy];
	CGRect f = attr.frame;
	f.origin.y = self.collectionView.bounds.size.height;
	attr.frame = f;
	return attr;
}

@end






@interface RTTabPickerController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout >

@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *dataSource;
@property (nonatomic, copy) NSArray<NSIndexPath *> *indexPaths;

@end

@implementation RTTabPickerController

- (instancetype)init {

	self = [super init];
	if (!self) return nil;

	_dataSource = nil;

	return self;
}

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [UIColor clearColor];

	{
		RTTabPickerLayout *layout = [RTTabPickerLayout new];
		UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		collectionView.translatesAutoresizingMaskIntoConstraints = NO;
		collectionView.delegate = self;
		collectionView.dataSource = self;
		collectionView.showsVerticalScrollIndicator = NO;
		collectionView.showsHorizontalScrollIndicator = NO;
		collectionView.backgroundColor = [UIColor clearColor];// [[UIColor whiteColor] colorWithAlphaComponent:.5];
		[self.view addSubview:collectionView];
		self.collectionView = collectionView;
	}

	NSDictionary *vd = @{@"cv": self.collectionView};
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cv]|" options:0 metrics:nil views:vd]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv]|" options:0 metrics:nil views:vd]];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.collectionView registerNib:[RTTabBarItem nib] forCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier]];

	self.view.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[UIView animateWithDuration:.3 animations:^{
		self.view.alpha = 1.0;
	}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	//	animate items up
	self.dataSource = [self.delegate itemsForTabPickerController:self];
	NSMutableArray *marr = [NSMutableArray array];
	[self.dataSource enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
		[marr addObject:indexPath];
	}];
	self.indexPaths = marr;
	[self.collectionView performBatchUpdates:^{
		[self.collectionView insertItemsAtIndexPaths:marr];
	} completion:nil];
}



#pragma mark - Collection View

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

	CGFloat w = collectionView.bounds.size.width;
	CGFloat h = collectionViewLayout.itemSize.height;
	return CGSizeMake(w, h);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	RTTabBarItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier] forIndexPath:indexPath];
	UIViewController *vc = self.dataSource[indexPath.item];
	UITabBarItem *tbi = vc.tabBarItem;

	[cell populateWithCaption:tbi.title icon:tbi.image selectedIcon:tbi.selectedImage];
	cell.captionLabel.textColor = [UIColor whiteColor];
	cell.iconView.tintColor = cell.captionLabel.textColor;

	return cell;
}

#pragma mark Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	[UIView animateWithDuration:.3 animations:^{
		self.view.alpha = 0;
	}];

	//	animate items down
	self.dataSource = nil;
	[self.collectionView performBatchUpdates:^{
		[self.collectionView deleteItemsAtIndexPaths:self.indexPaths];
	} completion:^(BOOL finished) {
		[self.delegate tabPickerController:self didSelectItemAtIndex:indexPath.item];
	}];
}


@end
