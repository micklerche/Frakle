//
//  FKRolls.m
//  Farkle
//
//  Created by Mick Lerche on 3/19/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import "FKRoll.h"

@implementation FKRoll

- (instancetype)initWithPlayer:(int)player roll:(int)roll andValue:(long)value {
    self = [ super init];
    if (self) {
        self.player = player;
        self.roll = roll;
        self.value = value;
    }

    return self;
}




@end
