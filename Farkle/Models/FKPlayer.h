//
//  FKPlayers.h
//  Farkle
//
//  Created by Mick Lerche on 3/20/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FKPlayer : NSObject
@property NSString *name;
@property NSString *gamerHandle;
@property UIImage *image;
@property long score;

- (instancetype)initWithName:(NSString *)name gamerHandle:(NSString *)gamerHandle andImage:(UIImage *)image;


@end
