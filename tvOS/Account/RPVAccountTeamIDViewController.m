//
//  RPVAccountTeamIDViewController.m
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVAccountTeamIDViewController.h"
#import "RPVAccountFinalController.h"

@interface RPVAccountTeamIDViewController (){
    BOOL _viewBuilt;
}

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *selectedTeamID;

@end

@implementation RPVAccountTeamIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup tableView.
    
    [self buildView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = nil;
    self.tableView.tableFooterView = nil;
    
    //self.tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    
    [self.tableView reloadData];
}

- (UIView *)preferredFocusedView {

    return self.cbutton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWithDataSource:(NSArray*)dataSource username:(NSString*)username andPassword:(NSString*)password {
    // If tableView already exists, then reload it entirely.
    self.dataSource = dataSource;
    self.username = username;
    self.password = password;
    
    [self.tableView reloadData];
}

- (void)buildView {
    
    if (_viewBuilt) return;
    _viewBuilt = true;

    self.cbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cbutton.frame = CGRectMake(0, 0, 180, 80);
    [self.cbutton setTitle:@"Next" forState:UIControlStateNormal];
    [self.cbutton setTitle:@"Next" forState:UIControlStateFocused];
    [self.cbutton addTarget:self action:@selector(presentFinalController) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithCustomView:self.cbutton];
    
    //self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(presentFinalController)];
    self.nextButton.enabled = FALSE;
    
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    self.titleLabel = [[UILabel alloc] initForAutoLayout];
    self.titleLabel.font = [UIFont systemFontOfSize:80];
    self.subtitleLabel = [[UILabel alloc] initForAutoLayout];
    self.subtitleLabel.font = [UIFont systemFontOfSize:20];
    self.appleOnlyLabel = [[UILabel alloc] initForAutoLayout];
    self.appleOnlyLabel.font = [UIFont systemFontOfSize:20];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.appleOnlyLabel];
    
    [self.subtitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.appleOnlyLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80];
    [self.subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];
    
    self.titleLabel.text = @"Team ID";
    self.titleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.text = @"Your account is part of multiple development teams\n\nChoose one to proceed";
    self.subtitleLabel.numberOfLines = 0;
    self.subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if ([self darkMode]){
        self.tableView.backgroundColor  = [UIColor clearColor];
    } else {
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    //self.tableView.backgroundView = nil;
    //self.tableView.maskView = nil;
    //self.view.backgroundColor = [UIColor clearColor];
    [self.view  addSubview:self.tableView];
    [self.tableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.subtitleLabel withOffset:10];
    
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"teamid.cell"];
  /*
   
   self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
   
   
    [self.view  addSubview:self.confirmButton];
    
    [self.confirmButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withMultiplier:.50];
    
    [self.confirmButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateFocused];
    self.confirmButton.enabled = false;
    
    [self.confirmButton addTarget:self action:@selector(didTapConfirmButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
   */
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if ([self darkMode]){
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.tableView.backgroundColor = [UIColor clearColor];
    } else {
        
        self.titleLabel.textColor = [UIColor blackColor];
        self.tableView.backgroundColor = [UIColor clearColor];
        
    }
    
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teamid.cell" forIndexPath:indexPath];
    
    NSString *teamName = @"";
    NSString *teamID = @"";
    NSString *membershipName = @"";
    
    // Grab Team ID info for this cell.
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    teamID = [data objectForKey:@"teamId"];
    membershipName = [[[data objectForKey:@"memberships"] firstObject] objectForKey:@"name"];
    teamName = [NSString stringWithFormat:@"%@ (%@)", [data objectForKey:@"name"], [data objectForKey:@"type"]];
    //cell.backgroundColor = nil;
    //cell.backgroundView = nil;
    cell.textLabel.text = teamName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", teamID, membershipName];
    
    // Add the checkmark if currently selected.
    if ([teamID isEqualToString:self.selectedTeamID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

// Handle selection of a given table cell, and enable the "Next" button when one becomes selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    self.selectedTeamID = [data objectForKey:@"teamId"];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.nextButton.enabled = YES;
}

-(BOOL)tableView:(UITableView *)tableView shouldDrawTopSeparatorForSection:(NSInteger)section {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}


- (void)presentFinalController {
    
    NSString *teamID = self.selectedTeamID;
    NSString *username = self.username;
    NSString *password = self.password;
    RPVAccountFinalController *finalController = [RPVAccountFinalController new];
    
    [finalController setupWithUsername:username password:password andTeamID:teamID];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.navigationController pushViewController:finalController animated:true];
        
    });
    
    //[self performSegueWithIdentifier:@"presentFinalController" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[[segue destinationViewController] class] isEqual:[RPVAccountFinalController class]]) {
        // if the final controller, send everything through!
        
        NSString *teamID = self.selectedTeamID;
        NSString *username = self.username;
        NSString *password = self.password;
        
        RPVAccountFinalController *finalController = (RPVAccountFinalController*)[segue destinationViewController];
        
        [finalController setupWithUsername:username password:password andTeamID:teamID];
    }
}


@end
