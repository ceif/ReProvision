//
//  RPVAccountFinalController.m
//  iOS
//
//  Created by Matt Clarke on 08/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVAccountFinalController.h"
#import "EEBackend.h"
#import "EEAppleServices.h"
#import "RPVResources.h"
#import "RPVAccountChecker.h"

@interface RPVAccountFinalController (){
    BOOL _viewBuilt;
    
}


@property (nonatomic, strong) NSString *identity;
@property (nonatomic, strong) NSString *gsToken;
@property (nonatomic, strong) NSString *teamId;

@end

@implementation RPVAccountFinalController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildView];
    
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

- (void)buildView {
    
    if (_viewBuilt) return;
    _viewBuilt = true;
    
    if (@available(tvOS 10.0, *)) {
        self.restoresFocusAfterTransition = false;
    } else {
        // Fallback on earlier versions
    }
    
    self.cbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cbutton.frame = CGRectMake(0, 0, 180, 80);
    [self.cbutton setTitle:@"Done" forState:UIControlStateNormal];
    [self.cbutton setTitle:@"Done" forState:UIControlStateFocused];
    [self.cbutton addTarget:self action:@selector(_dismissAccountModal:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:self.cbutton];
    
    self.doneButton.enabled = FALSE;
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    self.titleLabel = [[UILabel alloc] initForAutoLayout];
    self.titleLabel.font = [UIFont systemFontOfSize:80];
    self.subtitleLabel = [[UILabel alloc] initForAutoLayout];
    self.subtitleLabel.font = [UIFont systemFontOfSize:20];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initForAutoLayout];

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.activityIndicatorView];
    
    [self.subtitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.activityIndicatorView autoCenterInSuperview];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80];
    [self.subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];
    
    self.titleLabel.text = @"Checking Device Status";
    self.titleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.text = @"Verifying...";
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Height is (data count+1) * row height.
    self.tableView.frame = CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 25, self.view.frame.size.width, [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]] * (self.dataSource.count+1));
    
    CGRect rect = [RPVResources boundedRectForFont:self.certificatesExplanation.font andText:self.certificatesExplanation.text width:self.view.frame.size.width - 40];
    self.certificatesExplanation.frame = CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 20, self.view.frame.size.width - 40, rect.size.height);
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollEnabled = NO;
    [self.tableView setEditing:YES animated:NO];
    
    [self.view addSubview:self.tableView];
    
    self.certificatesExplanation = [[UILabel alloc] initWithFrame:CGRectZero];
    self.certificatesExplanation.numberOfLines = 0;
    self.certificatesExplanation.text = @"Free accounts are only allowed up to two active certificates at any time.\n\nPlease remove an existing certificate to continue.";
    self.certificatesExplanation.font = [UIFont systemFontOfSize:17];
    self.certificatesExplanation.textAlignment = NSTextAlignmentCenter;
    self.certificatesExplanation.hidden = YES;
    
    [self.view addSubview:self.certificatesExplanation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Start checking with Apple for device registration!
    [self _checkDevelopmentCertificates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWithUsername:(NSString*)username password:(NSString*)password andTeamID:(NSString*)teamID {
    self.identity = username;
    self.gsToken = password;
    self.teamId = teamID;
    
    NSLog(@"SETUP WITH USERNAME: %@ AND PASSWORD: %@", username, password);
}

- (void)_checkDevelopmentCertificates {
    self.titleLabel.text = @"Checking Signing Certificates";
    self.subtitleLabel.text = @"Verifying...";
    
    // Check whether the user needs to revoke any existing codesigning certificate.
    [[EEAppleServices sharedInstance] listTeamsWithCompletionHandler:^(NSError *error, NSDictionary *dictionary) {
        if (error) {
            // TODO: handle!
            return;
        }
        
        // Check to see if the current Team ID is from a free profile.
        NSArray *teams = [dictionary objectForKey:@"teams"];
        
        BOOL isFreeUser = YES;
        for (NSDictionary *team in teams) {
            NSString *teamIdToCheck = [team objectForKey:@"teamId"];
            
            if ([teamIdToCheck isEqualToString:self.teamId]) {
                NSArray *memberships = [team objectForKey:@"memberships"];
                
                for (NSDictionary *membership in memberships) {
                    NSString *name = [membership objectForKey:@"name"];
                    NSString *platform = [membership objectForKey:@"platform"];
                    if ([name containsString:@"Apple Developer Program"] && [platform isEqualToString:@"ios"]) {
                        isFreeUser = NO;
                        break;
                    }
                }
                
                if (!isFreeUser)
                    break;
            }
        }
        
        NSLog(@"Is free user? %d", isFreeUser);
        
        if (isFreeUser) {
            [[EEAppleServices sharedInstance] listAllDevelopmentCertificatesForTeamID:self.teamId systemType:EESystemTypeiOS withCompletionHandler:^(NSError *error, NSDictionary *dictionary) {
                if (error) {
                    // TODO: Handle error!
                }
                
                // If the count of certs is > 1 existing profiles, we need the user to revoke one.
                NSArray *certificates = [dictionary objectForKey:@"certificates"];
                if (certificates.count > 1) {
                    NSLog(@"Need to remove an existing certificate!");
                    [self _setupUIForRevokingCertificates:certificates];
                } else {
                    // No need to revoke anything
                    [self _checkDeviceRegistration];
                }
            }];
        } else {
            // No need to check development certificate counts.
            [self _checkDeviceRegistration];
        }
    }];
}

- (void)_setupUIForRevokingCertificates:(NSArray*)certificates {
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.titleLabel.text = @"Remove a Certificate";
        self.subtitleLabel.text = @"";
        self.activityIndicatorView.hidden = YES;
        
        self.dataSource = [certificates mutableCopy];
        
        // update frames.
        [self.view setNeedsLayout];
        
        // Reload tableView.
        [self.tableView reloadData];
        
        // Show tableView.
        self.tableView.alpha = 0.0;
        self.tableView.hidden = NO;
        self.certificatesExplanation.alpha = 0.0;
        self.certificatesExplanation.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1.0;
            self.certificatesExplanation.alpha = 1.0;
        }];
    });
}

- (void)_checkDeviceRegistration {
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.titleLabel.text = @"Checking Device Status";
        self.subtitleLabel.text = @"Verifying...";
    
        [[EEAppleServices sharedInstance] listDevicesForTeamID:self.teamId systemType:EESystemTypetvOS withCompletionHandler:^(NSError *errors, NSDictionary *dicts) {
           //2AS958ND7M
            NSArray <NSDictionary*> *devices = dicts[@"devices"];
            NSString *ourUDID = [[RPVAccountChecker sharedInstance] UDIDForCurrentDevice];
            [devices enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull currentDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *deviceUDID = currentDevice[@"deviceNumber"];
                NSString *deviceID = currentDevice[@"deviceId"];
                if ([deviceUDID isEqualToString:ourUDID]){
                    DDLogInfo(@"found our device: %@", currentDevice);
                    *stop = TRUE;
                    [[EEAppleServices sharedInstance] deleteDevice:deviceID forTeamID:self.teamId systemType:EESystemTypetvOS withCompletionHandler:^(NSError *rError, NSDictionary *rDict) {
                       
                        DDLogInfo(@"deleted device with response: %@ error: %@", rDict, rError);
                        
                    }];
                }
                
            }];
            
           // DDLogInfo(@"devices: %@ error: %@", dicts, errors);
            
        }];
        
        [[RPVAccountChecker sharedInstance] registerCurrentDeviceForTeamID:self.teamId withIdentity:self.identity gsToken:self.gsToken andCompletionHandler:^(NSError *error) {
            DDLogInfo(@"error: %@", error);
            // Error only happens if user already has registered this device!
            [self _checkAppleWatchRegistration];
        }];
    });
}

- (void)_checkAppleWatchRegistration {
    if ([RPVResources hasActivePairedWatch]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.titleLabel.text = @"Checking Apple Watch Status";
            self.subtitleLabel.text = @"Verifying...";
            
            [[RPVAccountChecker sharedInstance] registerCurrentWatchForTeamID:self.teamId withIdentity:self.identity gsToken:self.gsToken andCompletionHandler:^(NSError *error) {
                // Error only happens if user already has registered this device!
                [self _storeUserDetails];
            }];
        });
    } else {
        // No paired watch, continue.
        [self _storeUserDetails];
    }
}

- (void)_storeUserDetails {
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.titleLabel.text = @"Storing Login Information";
        self.subtitleLabel.text = @"Working...";
    
        // Store details of the user to RPVResources
        [RPVResources storeUsername:self.identity password:self.gsToken andTeamID:self.teamId];
    
        [self performSelector:@selector(_done) withObject:nil afterDelay:2.0];
    });
}

- (void)_done {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.text = @"Finished";
        self.subtitleLabel.text = @"Signed in successfully!";
        
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        
        self.doneButton.enabled = YES;
    });
    
    // Notify throughout the app that the user did sign in.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.matchstic.reprovision.ios/userDidSignIn" object:nil];
}

- (IBAction)_dismissAccountModal:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

/////////////////////////////////////////////////////////////////////////////////////
// TableView delegate
/////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"certificate.cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    // Fill from data source
    NSDictionary *dictionary = [self.dataSource objectAtIndex:indexPath.row];
    
    NSString *machineName = [dictionary objectForKey:@"machineName"];
    machineName = [machineName stringByReplacingOccurrencesOfString:@"RPV- " withString:@""];
    
    NSString *applicationName = @"Unknown";
    if ([(NSString*)[dictionary objectForKey:@"machineName"] containsString:@"RPV"])
        applicationName = @"ReProvision";
    else if ([(NSString*)[dictionary objectForKey:@"machineName"] containsString:@"Cydia"]) {
        machineName = @"Unknown";
        applicationName = @"Cydia Impactor or Extender";
    } else
        applicationName = @"Xcode";
    
    if ([self darkMode] && ![cell isFocused]){
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Device: %@", machineName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Application: %@", applicationName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView shouldDrawTopSeparatorForSection:(NSInteger)section {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Actually delete this certificate from Apple's servers!
        
        // First, switch UI to state we're revoking...
        self.titleLabel.text = @"Revoking Certificate";
        self.subtitleLabel.text = @"Working...";
        
        self.tableView.hidden = YES;
        self.certificatesExplanation.hidden = YES;
        self.activityIndicatorView.hidden = NO;
        DDLogInfo(@"self.dataSource: %@", self.dataSource);;
        id object = [self.dataSource objectAtIndex:indexPath.row];
        DDLogInfo(@"removing item: %@", object);
        [self _revokeCertificate:object withCompletion:^(NSError *error) {
            if (!error) {
                // Delete the row from the data source
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.dataSource removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadData];
                    
                    //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    // Switch back to tableView if needed.
                    if (self.dataSource.count > 1) {
                        [self _setupUIForRevokingCertificates:self.dataSource];
                    } else {
                        // Otherwise, we're good to continue!
                        [self _checkDeviceRegistration];
                    }
                });
            }
        }];
    }
}


- (void)_revokeCertificate:(NSDictionary*)certificate withCompletion:(void (^)(NSError *error))completionHandler {
    [[EEAppleServices sharedInstance] ensureSessionWithIdentity:self.identity gsToken:self.gsToken andCompletionHandler:^(NSError *error, NSDictionary *plist) {
        if (!error) {
            [[EEAppleServices sharedInstance] revokeCertificateForSerialNumber:[certificate objectForKey:@"serialNumber"] andTeamID:self.teamId systemType:EESystemTypeiOS  withCompletionHandler:^(NSError *error, NSDictionary *dictionary) {
                
                completionHandler(error);
            }];
        }
    }];
}

@end
