//
//  FKPlayerSelectViewController.m
//  Farkle
//
//  Created by Mick Lerche on 3/20/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import "FKPlayerSelectViewController.h"
#import "FKPlayer.h"
#import "FKHomeViewController.h"
#import "FKPlayerTableViewCell.h"

@interface FKPlayerSelectViewController ()
@property NSMutableArray *players;

@end

@implementation FKPlayerSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.players = [NSMutableArray arrayWithObjects:
                    [[FKPlayer alloc]initWithName:@"Mick" gamerHandle:@"McBiker" andImage:[UIImage imageNamed:@"McBiker"]]
                    , nil];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FKHomeViewController *hvc = segue.destinationViewController;
    hvc.players = self.players;

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FKPlayerTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    FKPlayer *player = self.players[indexPath.row];
    cell.playerImageView.image = player.image;
    cell.nameLabel.text = player.name;
    cell.gamerHandleLabel.text = player.gamerHandle;
    return cell;
}




















@end
