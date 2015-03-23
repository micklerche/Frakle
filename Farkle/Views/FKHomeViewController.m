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

@interface FKHomeViewController () <DieLabelDelegate, UICollisionBehaviorDelegate>
@property (nonatomic, retain) IBOutletCollection(FKDieLabel) NSArray *diceCollection;
@property NSMutableArray *dice;
@property NSMutableArray *rolls;
@property BOOL player;
@property (strong, nonatomic) IBOutlet UILabel *user1Score;
@property (strong, nonatomic) IBOutlet UILabel *user2Score;
@property int rollCounter;
@property NSMutableArray *rollCounts;
@property NSMutableArray *tempRollCounts;

@property int currentPlayerIndex;

// this is the permanent banked scores
//public @property NSMutableArray *players;

///@property NSMutableArray *rollScores;
// this only includes all completed 6 round scores
@property int turnScore;
// this is the score for current dice rolls 1 - 6
@property int roundScore;

// UI Stuff
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@property (strong, nonatomic) IBOutlet UIView *boxView;
@property CGPoint startPoint1;
@property CGPoint startPoint2;
@property CGPoint startPoint3;
@property CGPoint startPoint4;
@property CGPoint startPoint5;
@property CGPoint startPoint6;

@end

@implementation FKHomeViewController


#pragma mark - UI play area

- (NSArray *)getDiceToRoll {
    NSMutableArray *activeDice = [NSMutableArray new];
    for (FKDieLabel *die in self.diceCollection) {
        if (die.backgroundColor != [UIColor grayColor]) {
            [activeDice addObject:die];
        }
    }
    return (activeDice.count > 0) ? activeDice : self.diceCollection;
}

- (void)setupAnimation {

    CGFloat flt = arc4random_uniform(100);
    CGFloat flt2 = arc4random_uniform(100);
    NSLog(@"%f %F", flt, flt2);
    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.boxView];


    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:[self getDiceToRoll]];
    gravityBehavior.magnitude = 0.7; //flt/1000;
    CGVector cgv = CGVectorMake(flt / (((int)flt % 2 == 1) ? 100 : -100), flt2 /(((int)flt2 % 2 == 1) ? 100 : -100));
    gravityBehavior.gravityDirection = cgv;
    [self.dynamicAnimator addBehavior:gravityBehavior];

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.diceCollection];
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;

    [self.collisionBehavior addBoundaryWithIdentifier:@"Top" fromPoint:CGPointMake(1.0, 1.0) toPoint:CGPointMake(1000.0, 1.0)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"Left" fromPoint:CGPointMake(1.0, 1.0) toPoint:CGPointMake(1.0, 1000.0)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"Right" fromPoint:CGPointMake(1000.0, 1.0) toPoint:CGPointMake(1000.0, 1000.0)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"Bottom" fromPoint:CGPointMake(1.0, 1000.0) toPoint:CGPointMake(1000.0, 1000.0)];
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.diceCollection];
    elasticityBehavior.elasticity = 0.75; //flt/100;
    elasticityBehavior.allowsRotation = YES;
    elasticityBehavior.friction = 0.0;
    [self.dynamicAnimator addBehavior:elasticityBehavior];

}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem: (id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    [self setupAnimation];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [self onRollButtonPressed:nil];
    }

    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] ) {
        [super motionEnded:motion withEvent:event];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - view/segue events

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FKScoreBoardViewController *svc = segue.destinationViewController;
    svc.players = self.players;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.startPoint1 = ((UILabel *)self.diceCollection[0]).center;
    self.startPoint2 = ((UILabel *)self.diceCollection[1]).center;
    self.startPoint3 = ((UILabel *)self.diceCollection[2]).center;
    self.startPoint4 = ((UILabel *)self.diceCollection[3]).center;
    self.startPoint5 = ((UILabel *)self.diceCollection[4]).center;
    self.startPoint6 = ((UILabel *)self.diceCollection[5]).center;

    self.dice = [NSMutableArray new];
    self.rolls = [NSMutableArray new];
    self.RollCounts = [NSMutableArray new];
    [self resetRollCounts];

    for (FKDieLabel *die in self.diceCollection) {
        die.delegate = self;
    }

    self.currentPlayerIndex = 0;
    self.title = ((FKPlayer *)self.players[self.currentPlayerIndex]).gamerHandle;

    // UI stuff
    //[self setupAnimation];
    [self refreshBoard];

}


#pragma mark - button events

- (IBAction)onRollButtonPressed:(id)sender {
    self.rollCounter++;

    ((UILabel *)self.diceCollection[0]).center = self.startPoint1;
    ((UILabel *)self.diceCollection[1]).center = self.startPoint2;
    ((UILabel *)self.diceCollection[2]).center = self.startPoint3;
    ((UILabel *)self.diceCollection[3]).center = self.startPoint4;
    ((UILabel *)self.diceCollection[4]).center = self.startPoint5;
    ((UILabel *)self.diceCollection[5]).center = self.startPoint6;


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
    [self setupAnimation];
}

- (IBAction)onBankButtonPressed:(id)sender {
    FKPlayer *player = self.players[self.currentPlayerIndex];
    player.score = player.score + self.turnScore + self.roundScore;

    self.turnScore = 0;
    self.roundScore = 0;

    self.user1Score.text = @"0";
    self.user2Score.text = [NSString stringWithFormat:@"%li", player.score];

    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = [UIColor grayColor];
    }
    [self resetRollCounts];
    [self resetTempRollCounts];


    // TODO: switch player
    self.currentPlayerIndex++;
    if (self.currentPlayerIndex == self.players.count) {
        self.currentPlayerIndex = 0;
    }
    self.title = ((FKPlayer *)self.players[self.currentPlayerIndex]).gamerHandle;

}

- (IBAction)onNewGameButtonPressed:(id)sender {
    [self.dice removeAllObjects];
    //self.player = !self.player;

    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = self.player ? [UIColor redColor] : [UIColor greenColor];
    }
}


#pragma mark - scoring implementation

- (void)dieToBeHeld:(id)die {
    FKDieLabel *heldDie = (FKDieLabel *)die;
    if (heldDie.backgroundColor == [UIColor grayColor]) { return; }

    heldDie.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);

    [self.dice addObject:die];
    ((FKDieLabel *)die).backgroundColor = [UIColor grayColor];

    [self.rolls addObject:[[FKRoll alloc]initWithPlayer:self.player roll:self.rollCounter andValue:((FKDieLabel *)die).tag]];
    NSLog(@"Player:%i  Roll: %i  Value: %li", self.player, self.rollCounter, (long)((FKDieLabel *)die).tag);

    self.rollCounts[heldDie.tag] = @([self.rollCounts[heldDie.tag] integerValue] + 1);
    NSLog(@"RollCount for %li: %@", (long)heldDie.tag, self.rollCounts[heldDie.tag]);


    [self calculateScore];
}

- (void)calculateScore {
    int scoreForRoll = 0;

    self.tempRollCounts = [[NSMutableArray alloc] initWithArray:self.rollCounts copyItems:YES];

    scoreForRoll += [self checkForSix];
    scoreForRoll += [self checkForStraight];
    scoreForRoll += [self checkForThreePairs];

    scoreForRoll += [self checkForThrees];
    scoreForRoll += [self checkForThrees];
    scoreForRoll += [self checkForSingles];

    self.roundScore = scoreForRoll;
    self.user1Score.text = [NSString stringWithFormat:@"%i", scoreForRoll + self.turnScore];

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


#pragma mark - helpers

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
    //[self rollCounts];
    for (FKDieLabel *die in self.diceCollection) {
        die.backgroundColor = [UIColor greenColor];
    }
    [self resetRollCounts];

}







@end
