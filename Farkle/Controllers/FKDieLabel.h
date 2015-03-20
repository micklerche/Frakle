//
//  FKDieLabel.h
//  Farkle
//
//  Created by Mick Lerche on 3/19/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DieLabelDelegate <NSObject>


//@optional
- (void)dieToBeHeld:(id)die;

@end




@interface FKDieLabel : UILabel
@property (nonatomic, assign) id <DieLabelDelegate> delegate;

- (void)roll;


@end
