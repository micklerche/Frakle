//
//  FKPlayers.m
//  Farkle
//
//  Created by Mick Lerche on 3/20/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import "FKPlayer.h"

@implementation FKPlayer

- (instancetype)initWithName:(NSString *)name gamerHandle:(NSString *)gamerHandle andImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.name = name;
        self.gamerHandle = gamerHandle;
        self.image = image;
    }

    return self;
}




@end
