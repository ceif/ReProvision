//
//  RPVAccountViewController.m
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVAccountViewController.h"
#import "RPVAccount2FAViewController.h"
#import "RPVAccountTeamIDViewController.h"
#import "RPVAccountFinalController.h"
#import "RPVAccountChecker.h"
#import "RPVResources.h"

@interface RPVAccountViewController (){
    BOOL _viewBuilt;
    NSString *_tmpUserName;
    NSString *_tmpPw;
}

@property (nonatomic, strong) NSArray *_interimTeamIDArray;
@property (nonatomic, strong) NSURLCredential *credentials;
@end

@implementation RPVAccountViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.confirmButtonItem.enabled = NO;
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self buildView];
    
}


- (UIView *)preferredFocusedView {
    
    if (self.emailTextField.text.length == 0){
        return self.emailTextField;
    }
    if (self.passwordTextField.text.length == 0){
        return self.passwordTextField;
    }
    
    return self.cbutton;
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
    
    self.titleLabel.text = @"Apple ID";
    self.titleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.text = @"Sign in to the account you used for Cydia Impactor";
    self.appleOnlyLabel.text = @"Your details are only sent to Apple";
    
    self.emailTextField = [[UITextField alloc] initForAutoLayout];
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.delegate = self;
    self.passwordTextField = [[UITextField alloc] initForAutoLayout];
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = TRUE;
    
    self.cbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cbutton.frame = CGRectMake(0, 0, 180, 80);
    [self.cbutton setTitle:@"Next" forState:UIControlStateNormal];
    [self.cbutton setTitle:@"Next" forState:UIControlStateFocused];
    [self.cbutton addTarget:self action:@selector(didTapConfirmButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    self.confirmButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cbutton];

    self.confirmButtonItem.enabled = FALSE;
    
    self.navigationItem.rightBarButtonItem = self.confirmButtonItem;

    [self.view addSubview:self.emailTextField];
    [self.view  addSubview:self.passwordTextField];
    
    [self.emailTextField autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withMultiplier:.50];
    [self.passwordTextField autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.emailTextField];
    
    [self.emailTextField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.passwordTextField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.emailTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:300];
    self.emailTextField.placeholder = @"Apple ID";
    self.passwordTextField.placeholder = @"Password";
    [self.passwordTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.emailTextField withOffset:15];
    [self.appleOnlyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordTextField withOffset:40];

}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self darkMode]){
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

//this may be redundant

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.emailTextField){
        _tmpUserName = textField.text;
    } else if (textField == self.passwordTextField){
        _tmpPw = textField.text;
    }
    if (_tmpUserName.length > 0 && _tmpPw.length > 0){
        self.confirmButtonItem.enabled = true;
        
    } else {
        self.confirmButtonItem.enabled = false;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    menuTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleMenuTap:)];
    menuTapRecognizer.numberOfTapsRequired = 1;
    menuTapRecognizer.allowedPressTypes = @[[NSNumber numberWithInteger:UIPressTypeMenu]];
    [self.view addGestureRecognizer:menuTapRecognizer];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)present2FAViewController {
    
    RPVAccount2FAViewController *controller = [RPVAccount2FAViewController new];
    [controller setupWithEmailAddress:self.emailTextField.text];
    [self.navigationController pushViewController:controller animated:true];
    // Reset in case of a previous failure
    self.titleLabel.text = @"Apple ID";
    self.titleLabel.textColor = [UIColor blackColor];
    self.subtitleLabel.text = @"Sign in to the account you used for Cydia Impactor";
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
- (void)handleMenuTap:(id)sender
{
    //LOG_SELF;
    [RPVResources setHasDismissedAccountView:TRUE];
    [self dismissViewControllerAnimated:true completion:nil];
    
}

- (void)presentFinalController {
    
    NSString *teamID = [[self._interimTeamIDArray firstObject] objectForKey:@"teamId"];
    NSString *username = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    RPVAccountFinalController *finalController = [RPVAccountFinalController new];
    [finalController setupWithUsername:username password:password andTeamID:teamID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.navigationController pushViewController:finalController animated:true];
    });
}

- (IBAction)didTapConfirmButton:(id)sender {
    // Check with Apple whether this email/password combo is correct.
    //  -- from output status, handle. i.e., segue to 2FA, show incorrect, or success handler.
    
    // Set right bar item to a spinning wheel
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    
    [[RPVAccountChecker sharedInstance] checkUsername:self.emailTextField.text withPassword:self.passwordTextField.text andCompletionHandler:^(NSString *failureReason, NSString *resultCode, NSArray *teamIDArray, NSURLCredential* credentials) {
        
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
}

- (void)changeUIToIncorrectStatus:(NSString*)statusString {
    self.titleLabel.text = @"Failure";
    self.titleLabel.textColor = [UIColor redColor];
    
    self.subtitleLabel.text = statusString;
    
    // Reset input fields
    self.emailTextField.text = @"";
    [self.emailTextField becomeFirstResponder];
    
    self.passwordTextField.text = @"";
    
    // And disable button
    
    self.confirmButtonItem.enabled = NO;
}

////////////////////////////////////////////////////////
// UITextFieldDelegate
////////////////////////////////////////////////////////

- (void)textFieldDidChange:(id)sender {
    if ([self.emailTextField.text containsString:@"@"] && self.passwordTextField.text.length > 0) {
        self.confirmButtonItem.enabled = YES;
    } else {
        self.confirmButtonItem.enabled = NO;
    }
}


@end
