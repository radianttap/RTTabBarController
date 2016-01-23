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

@property (nonatomic, strong) NSLayoutConstraint *leftEdgeConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

@property (nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *dataSource;
@property (nonatomic, copy) NSArray<NSIndexPath *> *indexPaths;

@end

@implementation RTTabPickerController

- (instancetype)init {

	self = [super init];
	if (!self) return nil;

	_dataSource = nil;
	_leftEdgeOffset = 0;

	return self;
}

- (void)setLeftEdgeOffset:(CGFloat)leftEdgeOffset {

	_leftEdgeOffset = leftEdgeOffset;
	if (!self.isViewLoaded) return;

	self.leftEdgeConstraint.constant = leftEdgeOffset;
	[self.view layoutIfNeeded];
}

- (void)setCvWidth:(CGFloat)cvWidth {

	_cvWidth = cvWidth;
	if (!self.isViewLoaded) return;

	self.widthConstraint.constant = cvWidth;
	[self.view layoutIfNeeded];
}

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];

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
	//	width
	CGFloat w = self.cvWidth;
	self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:w];
	[self.collectionView addConstraint:self.widthConstraint];
	//	height
	CGFloat h = self.numberOfItems * 54.0 + (self.numberOfItems - 1) * 8.0;
	[self.collectionView addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:h]];
	//	vertical constraints
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[cv]|" options:0 metrics:nil views:vd]];
	//	left edge position
	CGFloat x = self.leftEdgeOffset;
	if (x < 0) x = 0;
	self.leftEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:x];
	[self.view addConstraint:self.leftEdgeConstraint];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self.collectionView registerNib:[RTTabBarItem nib] forCellWithReuseIdentifier:[RTTabBarItem reuseIdentifier]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

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

	CGFloat h = collectionViewLayout.itemSize.height;
	return CGSizeMake(self.cvWidth, h);
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

	self.dataSource = nil;
	[self.collectionView performBatchUpdates:^{
		[self.collectionView deleteItemsAtIndexPaths:self.indexPaths];
	} completion:^(BOOL finished) {
		[self.delegate tabPickerController:self didSelectItemAtIndex:indexPath.item];
	}];
}


@end
