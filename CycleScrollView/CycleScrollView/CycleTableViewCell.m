//
//  CycleTableViewCell.m
//  CycleScrollView
//
//  Created by Leecholas on 2018/1/4.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import "CycleTableViewCell.h"

@interface CycleTableViewCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *cycleScrollView;
@property (nonatomic, strong) NSArray<NSString *> *imageArray;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, assign) NSInteger leftIndex;
@property (nonatomic, assign) NSInteger centerIndex;
@property (nonatomic, assign) NSInteger rightIndex;
@property (nonatomic, assign) NSInteger tapIndex; //当前的点击下标

@end

@implementation CycleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    self.pageControl.center = CGPointMake(kScreenWidth/2, self.pageControl.center.y);
}

- (void)setupSubViews {
    [self.contentView addSubview:self.cycleScrollView];
    [self.contentView addSubview:self.pageControl];
    
    [_cycleScrollView addSubview:self.leftImageView];
    [_cycleScrollView addSubview:self.centerImageView];
    [_cycleScrollView addSubview:self.rightImageView];
}

- (void)showCycleImageWithImageArray:(NSArray<NSString *> *)imageArray section:(NSInteger)section {
    if (!imageArray) {
        return;
    }
    _imageArray = imageArray;
    
    // 若只有单图，不需要滑动
    // 给imageView设置image，一开始展示中间的centerImageView
    if (_imageArray.count == 1) {
        _cycleScrollView.scrollEnabled = NO;
        
        _leftImageView.hidden = YES;
        _rightImageView.hidden = YES;
    }else {
        _leftImageView.hidden = NO;
        _leftImageView.image = [UIImage imageNamed:[_imageArray lastObject]];
        
        _rightImageView.hidden = NO;
        _rightImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:1]];
    }
    self.centerImageView.image = [UIImage imageNamed:[_imageArray firstObject]];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = _imageArray.count;
    
    _centerIndex = _pageControl.currentPage;
    _rightIndex = 1;
    _leftIndex = _imageArray.count - 1;
    _tapIndex = _centerIndex;
    
    [self startTimer];
}

- (void)startTimer {
    if (_timer && _timer.isValid) {
        return;
    }
    // 多图方开启timer
    if (_imageArray && _imageArray.count > 1) {
        _timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timeChanged:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

// 整页滑动结束时刷新三个imageView的image
- (void)reloadImage {
    // 根据滑动结果重设currentPage
    if (_cycleScrollView.contentOffset.x == kScreenWidth) { //没有滑动
        _pageControl.currentPage = _centerIndex;
        return;
    }
    else if (_cycleScrollView.contentOffset.x == 2*kScreenWidth) { //向右滑动
        _pageControl.currentPage = _rightIndex;
    }
    else if (_cycleScrollView.contentOffset.x == 0) { //向左滑动
        _pageControl.currentPage = _leftIndex;
    }
    
    // 根据重设后的currentPage重设index
    _centerIndex = _pageControl.currentPage;
    _rightIndex = (_pageControl.currentPage + 1) > (_pageControl.numberOfPages - 1) ? 0 : (_pageControl.currentPage + 1);
    _leftIndex = (_pageControl.currentPage - 1) < 0 ? (_pageControl.numberOfPages - 1) : (_pageControl.currentPage - 1);
    
    // 根据重设后的index给imageView重设image
    _centerImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:_centerIndex]];
    _rightImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:_rightIndex]];
    _leftImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:_leftIndex]];
    
    // 始终保持centerImageView在中间
    _cycleScrollView.contentOffset = CGPointMake(kScreenWidth, 0);
}

#pragma mark - Action
- (void)timeChanged:(NSTimer *)timer {
    // timer控制始终向右滑动
    [_cycleScrollView setContentOffset:CGPointMake(2*kScreenWidth, 0) animated:YES];
    if (!_cycleScrollView.scrollEnabled) {
        _cycleScrollView.scrollEnabled = YES;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleTableViewCell:TapActionWithIndex:)]) {
        [self.delegate cycleTableViewCell:self TapActionWithIndex:_tapIndex];
    }
    // 防止滑动中点击时scrollView还未重新开启滑动(一次滑动动画停止前会禁止scrollView的滑动)
    if (!_cycleScrollView.scrollEnabled) {
        _cycleScrollView.scrollEnabled = YES;
    }
}

#pragma mark - UIScrollViewDelegate
// scrollView滑动时执行
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_cycleScrollView.contentOffset.x > kScreenWidth + kScreenWidth/2) { //向右滑动超过一半屏幕时
        _pageControl.currentPage = _rightIndex;
    }else if (_cycleScrollView.contentOffset.x < kScreenWidth/2) { //向左滑动超过一半屏幕时
        _pageControl.currentPage = _leftIndex;
    }else { // 向左滑动不超过一半屏幕或向右滑动不超过一半屏幕
        _pageControl.currentPage = _centerIndex;
    }
    // 重设点击下标
    _tapIndex = _pageControl.currentPage;
}

// scrollView滑动动画完成时调用，如果不设置动画，该方法不会被调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // timer控制自动滑动完成时刷新三个imageView的image
    [self reloadImage];
}

// scrollView开始滑动时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 用户自主拖动视图，停止计时器
    [self stopTimer];
}

// scrollView滑动减速时调用该方法
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    // 用户一次自主滑动结束后，强制不允许再滑动，等待刷新图片完成后方允许再次滑动
    _cycleScrollView.scrollEnabled = NO;
}

// scrollView减速完成，滑动将停止时，调用该方法。一次有效滑动，只执行一次
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 用户自主滑动结束时，刷新图片，重启计时器
    [self startTimer];
    [self reloadImage];
    _cycleScrollView.scrollEnabled = YES;
}

#pragma mark - Lazy Load
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenWidth/4, kScreenWidth - 20, 20)];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (UIScrollView *)cycleScrollView {
    if (!_cycleScrollView) {
        _cycleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 228*kScreenWidth/750)];
        _cycleScrollView.contentSize = CGSizeMake(3*kScreenWidth, 0);
        _cycleScrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        _cycleScrollView.pagingEnabled = YES;
        _cycleScrollView.showsHorizontalScrollIndicator = NO;
        _cycleScrollView.delegate = self;
        [_cycleScrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    }
    return _cycleScrollView;
}

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.cycleScrollView.height)];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _leftImageView;
}

- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, self.cycleScrollView.height)];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _centerImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2*kScreenWidth, 0, kScreenWidth, self.cycleScrollView.height)];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _rightImageView;
}

@end
