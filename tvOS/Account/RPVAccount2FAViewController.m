//
//  RPVAccount2FAViewController.m
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVAccount2FAViewController.h"
#import "RPVAccountTeamIDViewController.h"
#import "RPVAccountFinalController.h"
#import "RPVAccountChecker.h"

@interface RPVAccount2FAViewController (){
    BOOL _viewBuilt;

}

@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSArray *_interimTeamIDArray;
@property (nonatomic, strong) NSURLCredential *credentials;

@end

@implementation RPVAccount2FAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self buildView];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text.length > 0){
        self.confirmBarButtonItem.enabled = true;
    } else {
        self.confirmBarButtonItem.enabled = false;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self darkMode]){
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
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
    
    self.titleLabel.text = @"2-Factor Authentication";
    self.titleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.text = @"Create an app-specific password at appleid.apple.com to sign into your account";
    self.appleOnlyLabel.text = @"Your details are only sent to Apple";
    
    self.passwordTextField = [[UITextField alloc] initForAutoLayout];
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = TRUE;
    
    self.cbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cbutton.frame = CGRectMake(0, 0, 180, 80);
    [self.cbutton setTitle:@"Next" forState:UIControlStateNormal];
    [self.cbutton setTitle:@"Next" forState:UIControlStateFocused];
    [self.cbutton addTarget:self action:@selector(didTapConfirmButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    self.confirmBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cbutton];
    self.confirmBarButtonItem.enabled = FALSE;
    self.navigationItem.rightBarButtonItem = self.confirmBarButtonItem;
    
    [self.view  addSubview:self.passwordTextField];
    [self.passwordTextField autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withMultiplier:.50];
    
    [self.passwordTextField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.passwordTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:300];
    self.passwordTextField.placeholder = @"Password";
    [self.passwordTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.subtitleLabel withOffset:40];
    
    [self.appleOnlyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordTextField withOffset:40];
}

- (UIView *)preferredFocusedView {
    
    if (self.passwordTextField.text.length == 0){
        return self.passwordTextField;
    }
    return self.cbutton;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentTeamIDViewControllerIfNecessaryWithTeamIDs:(NSArray*)teamids credentials:(NSURLCredential*)credential {
    self._interimTeamIDArray = teamids;
    self.credentials = credential;
    if ([teamids count] == 1) {
        [self presentFinalController];
    } else {
        [self performSegueWithIdentifier:@"presentTeamIDController" sender:nil];
    }
}

- (void)presentFinalController {
   
    NSString *teamID = [[self._interimTeamIDArray firstObject] objectForKey:@"teamId"];
    NSString *username = self.emailAddress;
    NSString *password = self.passwordTextField.text;
    
    RPVAccountFinalController *finalController = [RPVAccountFinalController new];
    [finalController setupWithUsername:username password:password andTeamID:teamID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.navigationController pushViewController:finalController animated:true];
        
    });
    
}

- (IBAction)didTapConfirmButton:(id)sender {
    // Check with Apple whether this email/password combo is correct.
    //  -- from output status, handle. i.e., show incorrect, or success handler.
    
    // Set right bar item to a spinning wheel
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    /*
    [[RPVAccountChecker sharedInstance] checkUsername:self.emailAddress withPassword:self.passwordTextField.text andCompletionHandler:^(NSString *failureReason, NSString *resultCode, NSArray *teamIDArray, NSURLCredential *credentials) {
        
        if (teamIDArray) {
            // Handle the Team ID array. If one element, no worries. Otherwise we need to ask the user
            // which team to use.
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentTeamIDViewControllerIfNecessaryWithTeamIDs:teamIDArray credentials:credentials];
            });
            
        } else if ([resultCode isEqualToString:@"appSpecificRequired"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self present2FAViewController];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeUIToIncorrectStatus:failureReason];
            });
        }
        
        // Stop using a spinner.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationItem setRightBarButtonItem:self.confirmButtonItem];
        });
    }];
    */
  
}

- (void)changeUIToIncorrectStatus:(NSString*)statusString {
    self.titleLabel.text = @"Failure";
    self.titleLabel.textColor = [UIColor redColor];
    
    self.subtitleLabel.text = statusString;

    // Reset
    self.passwordTextField.text = @"";
    
    // And disable button
    self.confirmBarButtonItem.enabled = NO;
}

- (void)setupWithEmailAddress:(NSString*)emailAddress {
    self.emailAddress = emailAddress;
}

////////////////////////////////////////////////////////
// UITextFieldDelegate
////////////////////////////////////////////////////////

- (void)textFieldDidChange:(id)sender {
    if (self.passwordTextField.text.length > 0) {
        self.confirmBarButtonItem.enabled = YES;
    } else {
        self.confirmBarButtonItem.enabled = YES;
    }
}

@end
