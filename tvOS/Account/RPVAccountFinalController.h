//
//  RPVAccountFinalController.h
//  iOS
//
//  Created by Matt Clarke on 08/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPVAccountFinalController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIButton *cbutton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *certificatesExplanation;
@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)setupWithUsername:(NSString*)username password:(NSString*)password andTeamID:(NSString*)teamID;

@end
