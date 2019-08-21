//
//  CCDragStackView.h
//  CCDragStackViweDemo
//
//  Created by pengchangcheng on 2019/8/19.
//  Copyright © 2019 pengchangcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCDragStackViewDirect)
{
    CCDragStackViewDirectLeft = 1,
    CCDragStackViewDirectRight = 2
};

@protocol CCDragStackViewDelegate, CCDragStackViewDataSource, CCDragStackViewDataSourcePrefetching;

@interface CCDragStackView : UIView

@property (nonatomic, weak) id <CCDragStackViewDelegate> delegate;
@property (nonatomic, weak) id <CCDragStackViewDataSource> dataSource;
@property (nonatomic, weak) id <CCDragStackViewDataSourcePrefetching> prefetchDataSource;

// 当前正显示出来的数量
@property (nonatomic, assign) int showingCnt;
// 堆叠卡片之间的偏移量，默认{15，8}
@property (nonatomic, assign) CGSize offSet;
// itemSize默认大小为64*64
@property (nonatomic, assign) CGSize itemSize;
// 空白提示视图
@property (nonatomic, strong) UIView *emptyView;

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (__kindof UIView *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

//刷新展示数据
- (void)reloadData;
// 外部手动调用
- (void)dismissFromRight;
- (void)dismissFromLeft;

@end

@protocol CCDragStackViewDelegate <NSObject>

@optional
- (void)dragStackView:(CCDragStackView *)dragstackView didRemoveItemAtIndex:(NSInteger)index direct:(CCDragStackViewDirect)direct;

@end

@protocol CCDragStackViewDataSource <NSObject>

- (NSInteger)dragStackViewNumberOfItems:(CCDragStackView *)dragStackView;
- (UIView *)dragStackView:(CCDragStackView *)dragStackView viewForItemAtIndex:(NSInteger)index;

@optional
// 是否可以滑动dimiss最上层视图
- (BOOL)canDragDissmissView:(CCDragStackViewDirect)direct;

@end

@protocol CCDragStackViewDataSourcePrefetching <NSObject>

// 触发预加载（当前数据源最后一个数据显示到界面时触发）可以实现该方法来提前拉取数据 params:
// seenCount: 看过的数量，当前已经不出现在屏幕上
- (void)dragStackViewPrefetchData:(CCDragStackView *)dragStackView hasSeenCount:(int)seenCount;

@end

NS_ASSUME_NONNULL_END
