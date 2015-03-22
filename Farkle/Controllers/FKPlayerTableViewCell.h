//
//  FKPlayerTableViewCell.h
//  Farkle
//
//  Created by Mick Lerche on 3/22/15.
//  Copyright (c) 2015 Mick Lerche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKPlayerTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *playerImageView;
@property (strong, nonatomic) IBOutlet UILabel *gamerHandleLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
