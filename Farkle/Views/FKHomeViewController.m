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
#import "FKPlayer.h"
#import "FKScoreBoardViewController.h"

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

// this is the permanent banked scores
//public @property NSMutableArray *players;

///@property NSMutableArray *rollScores;
// this only includes all completed 6 round scores
@property int turnScore;
// this is the score for current dice rolls 1 - 6
@property int roundScore;


@end

@implementation FKHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dice = [NSMutableArray new];
    self.rolls = [NSMutableArray new];
    ///self.rollScores = [NSMutableArray new];

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
    for (int i = 0; i < 7; i++) {
        [self.rollCounts addObject:[[NSNumber alloc]initWithInt:0]];
    }
}

- (BOOL)allDicePlayed {
    BOOL allDicePlayed = YES;
    for (FKDieLabel *die in self.diceCollection) {
        if (![die.backgroundColor isEqual:[UIColor grayColor] ]){
            allDicePlayed = NO;
            break;
        }
    }
    return allDicePlayed;
}

- (void)refreshBoard {
    [self rollCounts];
    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = [UIColor greenColor];
    }

}

#pragma mark - button events


- (IBAction)onRollButtonPressed:(id)sender {
    self.rollCounter++;

    if ([self allDicePlayed]) {
        self.turnScore = self.turnScore + self.roundScore;
        self.roundScore = 0;
        [self refreshBoard];
        self.rollCounter = 1;
    }


    for (FKDieLabel *die in self.diceCollection) {
        //if (![self.dice containsObject:die]) {
        if (die.backgroundColor != [UIColor grayColor]) {
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


- (IBAction)onBankButtonPressed:(id)sender {
    FKPlayer *player = self.players[0];
    player.score = player.score + self.turnScore + self.roundScore;

    self.turnScore = 0;
    self.roundScore = 0;

    self.user1Score.text = @"0";
    self.user2Score.text = [NSString stringWithFormat:@"%li", player.score];

    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = [UIColor grayColor];
    }
    [self resetRollCounts];

    // TODO: switch palyers

}

- (IBAction)onNewGameButtonPressed:(id)sender {
    [self.dice removeAllObjects];
    //self.player = !self.player;

    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = self.player ? [UIColor redColor] : [UIColor greenColor];
    }
}

#pragma mark - Scoring implementation

- (void)dieToBeHeld:(id)die {
    FKDieLabel *heldDie = (FKDieLabel *)die;
    if (heldDie.backgroundColor == [UIColor grayColor]) { return; }

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

    scoreForRoll += [self checkForThrees];
    scoreForRoll += [self checkForThrees];
    //if ([self isCalculateScoreComplete]) {return;}
    scoreForRoll += [self checkForSingles];
    //if ([self isCalculateScoreComplete]) {return;}

    self.roundScore = scoreForRoll;
    self.user1Score.text = [NSString stringWithFormat:@"%i", scoreForRoll];

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

- (int)checkForThrees {
    int score = 0;
    BOOL isThree = NO;
    int counter = 0;
    for (NSNumber *count in self.tempRollCounts) {
        if ([count integerValue] > 2) {
            isThree = YES;
            break;
        }
        counter++;
    }
    if (isThree) {
        if (counter == 1 || counter == 5){
            score = 1000;
        } else {
            score = 100 * counter;
        }

        self.tempRollCounts[counter] = [[NSNumber alloc]initWithInteger:[self.tempRollCounts[counter] integerValue] - 3];

    }
    return score;
}

- (int)checkForSingles {
    int score = 0;
    if (!self.tempRollCounts.count == 0) {
        long oneCount = [self.tempRollCounts[1] integerValue];
        long fiveCount = [self.tempRollCounts[5] integerValue];

        if (oneCount > 0) {
            score += oneCount * 100;
        }
        if (fiveCount > 0) {
            score += fiveCount * 50;
        }
        [self.tempRollCounts removeAllObjects];
    }

    return score;
}


//
//- (BOOL)isCalculateScoreComplete {
//    int remainingHolds = 0;
//    for (NSNumber *count in self.tempRollCounts) {
//        remainingHolds += [count integerValue];
//    }
//    return remainingHolds == 0;
//
//}
//
//
//
//- (int)scoreForRoll:(int)count of:(PointValue)diceValue {
//    int score = 0;
//    switch (count) {
//        case 6: score += 2000; break;
//        case 5: score += 1000 + (2 * diceValue); break;
//        case 4: score += 1000 + diceValue; break;
//        case 3: score += 1000; break;
//        case 2: score += 2 * diceValue; break;
//        case 1: score += diceValue; break;
//    }
//    return score;
//}
//
//
//

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FKScoreBoardViewController *svc = segue.destinationViewController;
    svc.players = self.players;



}


























@end
