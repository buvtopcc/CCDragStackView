//
//  ViewController.m
//  CCDragStackViweDemo
//
//  Created by pengchangcheng on 2019/8/19.
//  Copyright © 2019 pengchangcheng. All rights reserved.
//

#import "ViewController.h"
#import "DSCenterLabelCell.h"
#import "CCDragStackView.h"

// TODO ：目前只有当once > show 才会触发预加载
static int const kCountOnce = 5;
static int const kCountShow = 4;

#define RANDOM_COLOR [UIColor colorWithRed:arc4random_uniform(256)/255.0 \
                                    green:arc4random_uniform(256)/255.0 \
                                    blue:arc4random_uniform(256)/255.0 alpha:1]

@interface ViewController () <CCDragStackViewDataSource, CCDragStackViewDelegate, CCDragStackViewDataSourcePrefetching>

@property (nonatomic, strong) CCDragStackView *dragStackView;

@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UIButton *disLikeBtn;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initDragStackView];
    [self initBtns];
    [self initDatas];
    
    [self.dragStackView reloadData];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)initDragStackView
{
    CCDragStackView *ds = [[CCDragStackView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    ds.center = self.view.center;
    ds.dataSource = self;
    ds.delegate = self;
    ds.prefetchDataSource = self;
    ds.offSet = CGSizeMake(15, 8);
    ds.showingCnt = kCountShow;
    ds.itemSize = CGSizeMake(200, 200);
    [ds registerClass:[DSCenterLabelCell class] forCellReuseIdentifier:[DSCenterLabelCell identifier]];
    self.dragStackView = ds;
    [self.view addSubview:ds];
}

- (void)initBtns
{
    //like
    UIButton *likebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    likebutton.frame = CGRectMake(100, 600, 80, 80);
    [likebutton setTitle:@"喜欢" forState:UIControlStateNormal];
    [likebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [likebutton addTarget:self action:@selector(likebuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:likebutton];
    self.likeBtn = likebutton;
    
    
    //unlike
    UIButton *unlikebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    unlikebutton.frame = CGRectMake(230, 600, 80, 80);
    [unlikebutton setTitle:@"不喜欢" forState:UIControlStateNormal];
    [unlikebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [unlikebutton addTarget:self action:@selector(unlikebuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unlikebutton];
    self.disLikeBtn = unlikebutton;
}

- (void)likebuttonAction:(UIButton *)button
{
    [self.dragStackView dismissFromRight];
}

- (void)unlikebuttonAction:(UIButton *)button
{
    [self.dragStackView dismissFromLeft];
}

- (void)initDatas
{
    for (int i = 0 ; i<kCountOnce; i++) {
        [self.dataArray addObject:@(i)];
    }
}

// CDSDataSourcePrefetching
- (void)dragStackViewPrefetchData:(CCDragStackView *)dragStackView
{
    BOOL success = YES;
    if (success) {
        static int flag = 1;
        NSMutableArray *ret = [NSMutableArray array];
        for (int i = 0 ; i < kCountOnce; i++) {
            [ret addObject:@(i + flag * kCountOnce)];
        }
        flag ++;
        NSArray *oriArr = [self.dataArray copy];
        int seen = dragStackView.hasSeenCnt;
        NSRange range = NSMakeRange(seen, self.dataArray.count - seen);
        self.dataArray = [[self.dataArray subarrayWithRange:range] mutableCopy];
        [self.dataArray addObjectsFromArray:ret];
        NSLog(@"预加载成功 dataSource from %@ to %@", oriArr, self.dataArray);
        [self.dragStackView reloadData];
    } else {
        // 获取失败的情况
        NSLog(@"预加载失败");
        int seen = dragStackView.hasSeenCnt;
        NSRange range = NSMakeRange(seen, self.dataArray.count - seen);
        self.dataArray = [[self.dataArray subarrayWithRange:range] mutableCopy];
        [self.dragStackView reloadData];
    }
}

- (NSInteger)dragStackViewNumberOfItems:(CCDragStackView *)dragStackView
{
    return self.dataArray.count;
}

- (UIView *)dragStackView:(CCDragStackView *)dragStackView viewForItemAtIndex:(NSInteger)index
{
    DSCenterLabelCell *cell = [dragStackView dequeueReusableCellWithIdentifier:[DSCenterLabelCell identifier]];
    [cell setText:[NSString stringWithFormat:@"%@", self.dataArray[index]]];
    cell.backgroundColor = RANDOM_COLOR;
    return cell;
}

@end
