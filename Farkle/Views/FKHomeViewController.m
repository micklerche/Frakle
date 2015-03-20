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



@end

@implementation FKHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dice = [NSMutableArray new];
    self.rolls = [NSMutableArray new];

    for (FKDieLabel *die in self.diceCollection) {
        die.delegate = self;
    }





}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onRollButtonPressed:(id)sender {
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
    [self.dice addObject:die];

    ((FKDieLabel *)die).backgroundColor = [UIColor grayColor];




    [self.rolls addObject:[[FKRoll alloc]initWithPlayer:self.player roll:self.rollCounter andValue:((FKDieLabel *)die).tag]];

    NSLog(@"Player:%i  Roll: %i  Value: %li", self.player, self.rollCounter, ((FKDieLabel *)die).tag);



    [self calculateScore];


}


- (void)calculateScore {
    // vars
    int counterFor1 = 0;
    int counterFor5 = 0;
    int currentPlayer = 0;
    int currentRoll = 0;
    int scoreForPlayer = 0;
    int scoreForPlayer1 = 0;
    int scoreForPlayer2 = 0;
    bool onePlayerGame = YES;



    for (FKRoll* roll in self.rolls) {


        if (currentRoll != roll.roll) {
            // calculate

///////////////////////// put better place
            scoreForPlayer1 += scoreForPlayer;
            self.user1Score.text = [NSString stringWithFormat:@"%i", scoreForPlayer1];
/////////////////////////
            
            counterFor1 = 0;
            counterFor5 = 0;
            currentRoll = roll.roll;

        }


        if (roll.value == 1) { counterFor1++; }
        if (roll.value == 5) { counterFor5++; }


        scoreForPlayer = [self scoreForRoll:counterFor1 of:For1];
        scoreForPlayer += [self scoreForRoll:counterFor5 of:For5];


    }
    // if for player
    if (onePlayerGame) {
        scoreForPlayer1 += scoreForPlayer;
    } else {
        scoreForPlayer2 += scoreForPlayer;
    }
    self.user1Score.text = [NSString stringWithFormat:@"%i", scoreForPlayer1];
    self.user2Score.text = [NSString stringWithFormat:@"%i", scoreForPlayer2];



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
