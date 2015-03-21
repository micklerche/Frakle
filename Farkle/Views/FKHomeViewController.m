//
//  FKHomeViewController.m
//  Farkle
//
//  Created by Mick Lerche on 3/19/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import "FKHomeViewController.h"
#import "FKDieLabel.h"
#import "FKRoll.h"

@interface FKHomeViewController () <DieLabelDelegate>
@property (nonatomic, retain) IBOutletCollection(FKDieLabel) NSArray *diceCollection;
@property NSMutableArray *dice;
@property NSMutableArray *rolls;
@property BOOL player;
@property (strong, nonatomic) IBOutlet UILabel *user1Score;
@property (strong, nonatomic) IBOutlet UILabel *user2Score;
@property int rollCounter;
@property NSMutableArray *rollCounts;
@property NSMutableArray *tempRollCounts;



@end

@implementation FKHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dice = [NSMutableArray new];
    self.rolls = [NSMutableArray new];

    for (FKDieLabel *die in self.diceCollection) {
        die.delegate = self;
    }

    self.RollCounts = [NSMutableArray new];
    [self resetRollCounts];


}

- (void)resetRollCounts {
    [self.rollCounts removeAllObjects];
    for (int i = 0; i < 7; i++) {
        [self.rollCounts addObject:[[NSNumber alloc]initWithInt:0]];
    }
}

- (void)resetTempRollCounts {
    [self.tempRollCounts removeAllObjects];
}

- (IBAction)onRollButtonPressed:(id)sender {
    //[self resetRollCounts];

    self.rollCounter++;

    for (FKDieLabel *die in self.diceCollection) {
        if (![self.dice containsObject:die]) {
            [die roll];




            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            [anim setToValue:[NSNumber numberWithFloat:0.0f]];
            [anim setFromValue:[NSNumber numberWithDouble:M_PI/12]]; // rotation angle
            [anim setDuration:.1];
            [anim setRepeatCount:5];
            [anim setAutoreverses:YES];
            [((FKDieLabel *)die).layer addAnimation:anim forKey:@"iconShake"];
            
            



        }
    }
}

- (IBAction)onPlayer2ButtonPressed:(id)sender {
    self.player = !self.player;




}

- (IBAction)onNewGameButtonPressed:(id)sender {
    [self.dice removeAllObjects];
    self.player = !self.player;

    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = self.player ? [UIColor redColor] : [UIColor greenColor];

    }




}

#pragma mark - DieLabelDelegate implementation

- (void)dieToBeHeld:(id)die {
    FKDieLabel *heldDie = (FKDieLabel *)die;

    [self.dice addObject:die];
    ((FKDieLabel *)die).backgroundColor = [UIColor grayColor];

    [self.rolls addObject:[[FKRoll alloc]initWithPlayer:self.player roll:self.rollCounter andValue:((FKDieLabel *)die).tag]];
    NSLog(@"Player:%i  Roll: %i  Value: %li", self.player, self.rollCounter, ((FKDieLabel *)die).tag);

    self.rollCounts[heldDie.tag] = @([self.rollCounts[heldDie.tag] integerValue] + 1);
    NSLog(@"RollCount for %li: %@", (long)heldDie.tag, self.rollCounts[heldDie.tag]);


    [self calculateScore];


}



- (void)calculateScore {
    int scoreForRoll = 0;

    self.tempRollCounts = [[NSMutableArray alloc] initWithArray:self.rollCounts copyItems:YES];

    scoreForRoll += [self checkForSix];
    //if ([self isCalculateScoreComplete]) {return;}
    scoreForRoll += [self checkForStraight];
    //if ([self isCalculateScoreComplete]) {return;}
    scoreForRoll += [self checkForThreePairs];
    //if ([self isCalculateScoreComplete]) {return;}

    //scoreForRoll += [self checkForThrees];
    //if ([self isCalculateScoreComplete]) {return;}
    scoreForRoll += [self checkForSingles];
    //if ([self isCalculateScoreComplete]) {return;}

    self.user1Score.text = [NSString stringWithFormat:@"%i", scoreForRoll];

}

- (int)checkForSingles {
    int score = 0;

    long oneCount = [self.tempRollCounts[1] integerValue];
    long fiveCount = [self.tempRollCounts[5] integerValue];

    if (oneCount > 0) {
        score += oneCount * 100;
    }
    if (fiveCount > 0) {
        score += fiveCount * 50;
    }
    [self.tempRollCounts removeAllObjects];

    return score;
}

- (int)checkForSix {
    int score = 0;
    BOOL isSix = NO;

    for (NSNumber *count in self.tempRollCounts) {
        if ([count integerValue] == 6) {
            isSix = YES;
        }
    }
    if (isSix) {
        score = 1000;
        [self resetTempRollCounts];
    }
    return score;
}

- (int)checkForStraight {
    int score = 0;
    BOOL isStraight = YES;
    int counter = 0;

    for (NSNumber *count in self.tempRollCounts) {
        if ([count integerValue] == 0 && counter > 0) {
            isStraight = NO;
        }
        counter++;
    }
    if (isStraight) {
        score = 1000;
        [self resetTempRollCounts];
    }
    return score;
}

- (int)checkForThreePairs {
    int score = 0;
    int numbersOfPairs = 0;

    for (NSNumber *count in self.tempRollCounts) {
        if ([count integerValue] == 2) {
            numbersOfPairs += 1;
        }
    }

    if (numbersOfPairs == 3) {
        score = 1000;
        [self resetTempRollCounts];
    }
    return score;
}



- (BOOL)isCalculateScoreComplete {
    int remainingHolds = 0;
    for (NSNumber *count in self.tempRollCounts) {
        remainingHolds += [count integerValue];
    }
    return remainingHolds == 0;

}



- (int)scoreForRoll:(int)count of:(PointValue)diceValue {
    int score = 0;
    switch (count) {
        case 6: score += 2000; break;
        case 5: score += 1000 + (2 * diceValue); break;
        case 4: score += 1000 + diceValue; break;
        case 3: score += 1000; break;
        case 2: score += 2 * diceValue; break;
        case 1: score += diceValue; break;
    }
    return score;
}































@end
