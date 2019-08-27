//
//  RPVAccountTeamIDViewController.h
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPVAccountTeamIDViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *appleOnlyLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *cbutton;

- (void)setupWithDataSource:(NSArray*)dataSource username:(NSString*)username andPassword:(NSString*)password;

@end
