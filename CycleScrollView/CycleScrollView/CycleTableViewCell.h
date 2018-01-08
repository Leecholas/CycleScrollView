//
//  CycleTableViewCell.h
//  CycleScrollView
//
//  Created by Leecholas on 2018/1/4.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CycleTableViewCell;

@protocol CycleTableViewCellDelegate <NSObject>
- (void)cycleTableViewCell:(CycleTableViewCell *)cycleCell TapActionWithIndex:(NSInteger)index;
@end

@interface CycleTableViewCell : UITableViewCell
@property (nonatomic, assign) id<CycleTableViewCellDelegate> delegate;

- (void)showCycleImageWithImageArray:(NSArray<NSString *> *)imageArray section:(NSInteger)section;
- (void)startTimer;
- (void)stopTimer;
@end
