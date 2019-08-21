//
//  CCDragStackView.m
//  CCDragStackViweDemo
//
//  Created by pengchangcheng on 2019/8/19.
//  Copyright © 2019 pengchangcheng. All rights reserved.
//

#import "CCDragStackView.h"

static CGFloat kAnimateTime = 0.25;

// 当前view左右移动消失的阈值
static const CGFloat kDIstanceOfTriggerDismiss = 120;
//
static const CGFloat kScaleFactor = 4;
// 可缩放到的最小值
static const CGFloat kScaleMin = 0.93;
// 旋转的最大弧度
static const CGFloat kRadiusRotationMax = 1.0;
// 触发到最大旋转弧度的距离值
static const CGFloat kDistanceOfMaxRadius = 320;
// 最大旋转角度
static const CGFloat kRotationAngle = M_PI / 8;

@interface CCDragStackView ()

// for reuse logic
@property (nonatomic, strong) NSMutableDictionary *reuseIndentifiers;
@property (nonatomic, strong) NSMutableDictionary *cls2Identifiers;
@property (nonatomic, strong) NSMutableDictionary *reuseCellDicts;

@property (nonatomic, strong) NSMutableArray *itemArray;
// 拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
// 原始点
@property (nonatomic, assign) CGPoint originalPoint;
// center.x的差值
@property (nonatomic, assign) CGFloat xFromCenter;
// center.y的差值
@property (nonatomic, assign) CGFloat yFromCenter;
// 是否正在动画中
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) int hasSeenCnt;

@end

@implementation CCDragStackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _showingCnt = 5;
    _offSet = CGSizeMake(15, 8);
    _itemSize = CGSizeMake(64, 64);
    
    [self addGestureRecognizer:self.panGestureRecognizer];
}

#pragma mark - Lazy load
- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    return _panGestureRecognizer;
}

- (NSMutableDictionary *)reuseIndentifiers
{
    if (!_reuseIndentifiers) {
        _reuseIndentifiers = [NSMutableDictionary dictionary];
    }
    return _reuseIndentifiers;
}

- (NSMutableDictionary *)cls2Identifiers
{
    if (!_cls2Identifiers) {
        _cls2Identifiers = [NSMutableDictionary dictionary];
    }
    return _cls2Identifiers;
}

- (NSMutableDictionary *)reuseCellDicts
{
    if (!_reuseCellDicts) {
        _reuseCellDicts = [NSMutableDictionary dictionary];
    }
    return _reuseCellDicts;
}

- (NSMutableArray *)itemArray
{
    if (_itemArray == nil) {
        _itemArray = [[NSMutableArray alloc]initWithCapacity:_showingCnt];
    }
    return _itemArray;
}

- (void)setshowingCnt:(int)showingCnt
{
    NSInteger itemNum = showingCnt;
    if ([self.dataSource respondsToSelector:@selector(dragStackViewNumberOfItems:)]) {
        itemNum = [self.dataSource dragStackViewNumberOfItems:self];
    }
    _showingCnt = (itemNum >= showingCnt) ? showingCnt:(int)itemNum;
}

#pragma mark - 对外接口
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    if (identifier && cellClass) {
        [self.reuseIndentifiers setObject:cellClass forKey:identifier];
        [self.cls2Identifiers setObject:identifier forKey:NSStringFromClass(cellClass)];
    }
}

- (__kindof UIView *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    UIView *reuseCell;
    NSMutableArray *cells = [self.reuseCellDicts objectForKey:identifier];
    if (cells.count) {
        NSLog(@"复用一个cell");
        reuseCell = [cells firstObject];
        [cells removeObject:reuseCell];
    } else {
        Class cellCls = [self.reuseIndentifiers objectForKey:identifier];
        NSAssert(cellCls, @"Attention, not register class for %@, please use registerClass function before call\
                 this.", identifier);
        reuseCell = [[cellCls alloc] init];
    }
    return reuseCell;
}

- (void)reloadData
{
    _hasSeenCnt = 0;
    
    // 清空原来数据
    for (UIView *view in self.itemArray) {
        [view removeFromSuperview];
        [self prepareForReuse:view];
    }
    [self.itemArray removeAllObjects];
    
    if ([self.dataSource respondsToSelector:@selector(dragStackViewNumberOfItems:)]) {
        NSInteger totoalNum = [self.dataSource dragStackViewNumberOfItems:self];
        if (totoalNum > 0) {
            if (totoalNum < _showingCnt) {
                _showingCnt = (int)totoalNum;
            }
            if ([self.dataSource respondsToSelector:@selector(dragStackView:viewForItemAtIndex:)]) {
                for (NSInteger i = 0; i<_showingCnt; i++) {
                    UIView *view = [self.dataSource dragStackView:self viewForItemAtIndex:i];
                    if (!view) {
                        continue;
                    }
                    view.userInteractionEnabled = NO;
                    view.center = self.center;
                    CGRect frame = CGRectZero;
                    frame.size = self.itemSize;
                    view.frame = frame;
                    
                    [self.itemArray addObject:view];
                }
            }
        }
    }
    [self layoutViews:NO completion:nil];
}

- (void)dismissFromRight
{
    if (self.isAnimating) {
        NSLog(@"dismissFromRight isAnimating, return.");
        return;
    }
    UIView *topView = [self.itemArray firstObject];
    if (topView) {
        [self dismissAtDirect:CCDragStackViewDirectRight view:topView];
    }
}

- (void)dismissFromLeft
{
    if (self.isAnimating) {
        NSLog(@"dismissFromLeft isAnimating, return.");
        return;
    }
    UIView *topView = [self.itemArray firstObject];
    if (topView) {
        [self dismissAtDirect:CCDragStackViewDirectLeft view:topView];
    }
}

#pragma mark - 内部逻辑
- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    if (self.isAnimating) {
        return;
    }
    
    if (self.itemArray.count <= 0) {
        return;
    }
    
    UIView *firstCard = [self.itemArray firstObject];
    //获取当前center.x和之前的center.x的差值
    self.xFromCenter = [pan translationInView:firstCard].x;
    //获取当前center.y和之前的center.y的差值
    self.yFromCenter = [pan translationInView:firstCard].y;
    
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.originalPoint = firstCard.center;
            break;
        case UIGestureRecognizerStateChanged: {
            //取相对较小的值
            CGFloat rotationStrength = MIN(fabs(self.xFromCenter) / kDistanceOfMaxRadius, kRadiusRotationMax); // [0-1]
            //旋转角度
            CGFloat rotationAngel = rotationStrength * kRotationAngle; // [0 - M_PI/8]
            //比例
            CGFloat scale = MAX(1 - fabs(rotationStrength) / kScaleFactor, kScaleMin); // [0.93 - 1]
            //重置中点
            firstCard.center = CGPointMake(self.originalPoint.x + self.xFromCenter,
                                           self.originalPoint.y + self.yFromCenter);
            //旋转
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            //缩放
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            firstCard.transform = scaleTransform;
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self endSwiped:firstCard];
        }
            break;
        default:
            break;
    }
}

- (void)endSwiped:(UIView *)view
{
    // 默认支持滑动dismiss
    BOOL canDismissLeft = YES;
    BOOL canDismissRight = YES;
    if ([self.dataSource respondsToSelector:@selector(canDragDissmissView:)]) {
        canDismissLeft = [self.dataSource canDragDissmissView:CCDragStackViewDirectLeft];
    }
    if ([self.dataSource respondsToSelector:@selector(canDragDissmissView:)]) {
        canDismissRight = [self.dataSource canDragDissmissView:CCDragStackViewDirectRight];
    }
    
    //当这个差值大于kDIstanceOfTriggerDismiss 让它从右边消失
    if (self.xFromCenter > kDIstanceOfTriggerDismiss && canDismissRight) {
        [self dismissAtDirect:CCDragStackViewDirectRight view:view];
    } else if (self.xFromCenter < -kDIstanceOfTriggerDismiss && canDismissLeft) { //当这个差值小雨-kDIstanceOfTriggerDismiss 让它从左边消失
        [self dismissAtDirect:CCDragStackViewDirectLeft view:view];
    } else { //其他情况恢复原来的位置
        self.isAnimating = YES;
        [UIView animateWithDuration:kAnimateTime
                         animations: ^{
                             view.center = self.originalPoint;
                             view.transform = CGAffineTransformIdentity;
                             self.isAnimating = NO;
                         }];
    }
}

- (void)dismissAtDirect:(CCDragStackViewDirect)direct view:(UIView *)view
{
    int sign = (direct == CCDragStackViewDirectLeft) ? -1: 1;
    CGPoint finishPoint = CGPointMake(sign * 500, 2 * self.yFromCenter + self.originalPoint.y);
    
    // 动画
    self.isAnimating = YES;
    [UIView animateWithDuration:kAnimateTime animations:^{
        view.center = finishPoint;
    } completion:^(BOOL finished) {
        [self viewSwipAction:view direct:direct];
    }];
}

- (void)prepareForReuse:(UIView *)view
{
    NSString *identier = [self.cls2Identifiers objectForKey:NSStringFromClass([view class])];
    NSMutableArray *reuseArr = [self.reuseCellDicts objectForKey:identier];
    if (!reuseArr) {
        reuseArr = [NSMutableArray array];
        [self.reuseCellDicts setObject:reuseArr forKey:identier];
    }
    [reuseArr addObject:view];
}

- (void)viewSwipAction:(UIView *)view direct:(CCDragStackViewDirect)direct
{
    // 重制view属性
    view.transform = CGAffineTransformIdentity;
    view.center = self.originalPoint;
    
    // 用于复用
    [self prepareForReuse:view];
    
    // 移除
    [self.itemArray removeObject:view];
    [view removeFromSuperview];
    
    
    NSInteger totalNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(dragStackViewNumberOfItems:)]) {
       totalNumber = [self.dataSource dragStackViewNumberOfItems:self];
    }
    UIView *newView;
    int maxIndex = (int)(totalNumber - 1);
    int deleteItemIndex = self.hasSeenCnt;
    int newItemIndex = self.hasSeenCnt + self.showingCnt;
    self.hasSeenCnt ++; // 增加一个看过的
    
    // 通知delegate移除item
    if ([self.delegate respondsToSelector:@selector(dragStackView:didRemoveItemAtIndex:direct:)]) {
        [self.delegate dragStackView:self didRemoveItemAtIndex:deleteItemIndex direct:direct];
    }
    
    __weak typeof(self)weakSelf = self;
    BOOL isShowEmpty = NO;
    if (newItemIndex < maxIndex) {
        if ([self.dataSource respondsToSelector:@selector(dragStackView:viewForItemAtIndex:)]) {
            newView = [self.dataSource dragStackView:self viewForItemAtIndex:newItemIndex];
        }
        if (newView) {
            newView.userInteractionEnabled = NO;
            newView.frame = [self.itemArray.firstObject frame];
            [self.itemArray addObject:newView];
            [self layoutViews:YES completion:^{
                weakSelf.isAnimating = NO;
            }];
            NSLog(@"current has full aviable items at :%@", @(newItemIndex));
        }
    } else if (newItemIndex == maxIndex) {
        [self layoutViews:YES completion:^{
            if ([weakSelf.prefetchDataSource respondsToSelector:@selector(dragStackViewPrefetchData:hasSeenCount:)]) {
                [weakSelf.prefetchDataSource dragStackViewPrefetchData:weakSelf hasSeenCount:weakSelf.hasSeenCnt];
            }
            weakSelf.isAnimating = NO;
        }];
    } else { // 已经没有数据可供显示了
        self.showingCnt --;
        [self layoutViews:YES completion:^{
            weakSelf.isAnimating = NO;
        }];
        if (self.hasSeenCnt == totalNumber) {
            NSLog(@"显示空白视图！！");
            isShowEmpty = YES;
        }
    }
    self.emptyView.hidden = !isShowEmpty;
}

- (void)layoutViews:(BOOL)animate completion:(dispatch_block_t)completionBlock
{
    NSInteger num = self.itemArray.count;
    if (num <= 0) {
        return;
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self layoutIfNeeded]; // 得到tantanView自身的尺寸
    
    void (^workBlock) (void) = ^{
        CGFloat sW = self.frame.size.width;
        CGFloat sH = self.frame.size.height;
        CGFloat w = self.itemSize.width;
        CGFloat h = self.itemSize.height;
        CGFloat x = 0.5 * (sW - w);
        CGFloat y = 0.5 * (sH - h);
        for (NSInteger i = 0; i < num; i++) {
            UIView *tantan = self.itemArray[i];
            tantan.frame = CGRectMake(x, y, w, h);
            x += self.offSet.width;
            y -= self.offSet.height;
            w -= 2 * self.offSet.width;
            h = w / (self.itemSize.width / self.itemSize.height); // 等比缩放高度
            if (i == 0) {
                tantan.userInteractionEnabled = YES;
            }
            [self insertSubview:tantan atIndex:0];
        }
    };
    
    if (animate) {
        [UIView animateWithDuration:0.2 animations:^{
            workBlock();
        } completion:^(BOOL finished) {
            if (completionBlock) {
                completionBlock();
            }
        }];
    } else {
        workBlock();
        if (completionBlock) {
            completionBlock();
        }
    }
    NSLog(@"layoutsubviews");
}

@end
