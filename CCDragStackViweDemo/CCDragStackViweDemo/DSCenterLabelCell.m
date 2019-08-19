//
//  DSCenterLabelCell.m
//  CCDragStackViweDemo
//
//  Created by pengchangcheng on 2019/8/19.
//  Copyright © 2019 pengchangcheng. All rights reserved.
//

#import "DSCenterLabelCell.h"

@interface DSCenterLabelCell ()

@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UIButton *likeBtn;
//@property (nonatomic, strong) UIButton *disLikeBtn;

@end

@implementation DSCenterLabelCell

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
    
//    //like
//    UIButton *likebutton = [UIButton buttonWithType:UIButtonTypeCustom];
//    likebutton.frame = CGRectMake(0, self.frame.size.height-(self.frame.size.width/2), self.frame.size.width/2, self.frame.size.width/2);
//    [likebutton setTitle:@"喜欢" forState:UIControlStateNormal];
//    [likebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [likebutton addTarget:self action:@selector(likebuttonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:likebutton];
//    self.likeBtn = likebutton;
//
//
//    //unlike
//    UIButton *unlikebutton = [UIButton buttonWithType:UIButtonTypeCustom];
//    unlikebutton.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height-(self.frame.size.width/2), self.frame.size.width/2, self.frame.size.width/2);
//    [unlikebutton setTitle:@"不喜欢" forState:UIControlStateNormal];
//    [unlikebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [unlikebutton addTarget:self action:@selector(unlikebuttonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:unlikebutton];
//    self.disLikeBtn = unlikebutton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize sSize = self.frame.size;
    CGSize lSize = [self.titleLabel frame].size;
    self.titleLabel.frame = CGRectMake(0.5 * (sSize.width - lSize.width), 0.5 * (sSize.height - lSize.height),
                                       lSize.width, lSize.height);
//    self.likeBtn.frame = CGRectMake(0, self.frame.size.height-(self.frame.size.width/2),
//                                    self.frame.size.width/2, self.frame.size.width/2);
//    self.disLikeBtn.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height-(self.frame.size.width/2),
//                                       self.frame.size.width/2, self.frame.size.width/2);
}

- (void)setText:(NSString *)text
{
    self.titleLabel.text = text;
//    [self setNeedsLayout];
}

@end
