//
//  FKScoreBoardViewController.m
//  Farkle
//
//  Created by Mick Lerche on 3/20/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import "FKScoreBoardViewController.h"
#import "FKPlayer.h"

@interface FKScoreBoardViewController ()

@end

@implementation FKScoreBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    FKPlayer *player = self.players[indexPath.row];

    cell.textLabel.text = player.gamerHandle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Score: %li", player.score];
    return cell;
}

@end
