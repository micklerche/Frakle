//
//  FKHomeViewController.h
//  Farkle
//
//  Created by Mick Lerche on 3/19/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    For1 = 100,
    For5 = 50
} PointValue;

@interface FKHomeViewController : UIViewController
@property NSMutableArray *players;

@end
