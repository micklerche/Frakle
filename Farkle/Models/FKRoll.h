//
//  FKRolls.h
//  Farkle
//
//  Created by Mick Lerche on 3/19/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKRoll : NSObject
@property int player;
@property int roll;
@property long value;

- (instancetype)initWithPlayer:(int)player roll:(int)roll andValue:(long)value;

@end
