//
//  FKDieLabel.m
//  Farkle
//
//  Created by Mick Lerche on 3/19/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import "FKDieLabel.h"

@implementation FKDieLabel



- (IBAction)onTapped:(UITapGestureRecognizer *)sender {
    [self.delegate dieToBeHeld:self];




    //[self roll];
    
}

- (void)roll {
    self.tag = 1 + (random() % 6);
    self.text = [NSString stringWithFormat:@"%li", self.tag];

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/








@end
