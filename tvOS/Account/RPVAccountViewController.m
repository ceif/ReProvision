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

@interface RPVAccountViewController (){
    BOOL _viewBuilt;
    NSString *_tmpUserName;
    NSString *_tmpPw;
}

@property (nonatomic, strong) NSArray *_interimTeamIDArray;

@end

@implementation RPVAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.confirmButtonItem.enabled = NO;
    self.confirmButton.enabled = NO;
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
    
    //self.confirmButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(presentFinalController)];
    
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
  
    /*
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view  addSubview:self.confirmButton];
    [self.confirmButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.emailTextField];
    [self.confirmButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateFocused];
    self.confirmButton.enabled = false;
    [self.confirmButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordTextField withOffset:30];
    [self.confirmButton addTarget:self action:@selector(didTapConfirmButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
     */
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if ([self darkMode]){
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.emailTextField;
        
    } else {
        
        self.titleLabel.textColor = [UIColor blackColor];
        
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    LOG_SELF;
    NSLog(@"text field value: %@", textField.text);
    if (textField == self.emailTextField){
        _tmpUserName = textField.text;
    } else if (textField == self.passwordTextField){
        _tmpPw = textField.text;
    }
    
    if (_tmpUserName.length > 0 && _tmpPw.length > 0){
        self.confirmButtonItem.enabled = true;
        self.confirmButton.enabled = true;
        
    } else {
        self.confirmButtonItem.enabled = false;
        self.confirmButton.enabled = false;
    }
    
    
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

- (void)present2FAViewController {
    
    LOG_SELF;
    RPVAccount2FAViewController *controller = [RPVAccount2FAViewController new];
    [controller setupWithEmailAddress:self.emailTextField.text];
    //[self performSegueWithIdentifier:@"present2FA" sender:nil];
    [self.navigationController pushViewController:controller animated:true];
    // Reset in case of a previous failure
    self.titleLabel.text = @"Apple ID";
    self.titleLabel.textColor = [UIColor blackColor];
    
    self.subtitleLabel.text = @"Sign in to the account you used for Cydia Impactor";
}

- (void)presentTeamIDViewControllerIfNecessaryWithTeamIDs:(NSArray*)teamids {
    self._interimTeamIDArray = teamids;
    
    if ([teamids count] == 1) {
        [self presentFinalController];
    } else {
        RPVAccountTeamIDViewController *teamidController = [RPVAccountTeamIDViewController new];
        [teamidController setupWithDataSource:self._interimTeamIDArray username:self.emailTextField.text andPassword:self.passwordTextField.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController pushViewController:teamidController animated:true];
            
        });
    }
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
    
    //[self performSegueWithIdentifier:@"presentFinalController" sender:nil];
}

- (IBAction)didTapConfirmButton:(id)sender {
    // Check with Apple whether this email/password combo is correct.
    //  -- from output status, handle. i.e., segue to 2FA, show incorrect, or success handler.
    
    // Set right bar item to a spinning wheel
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    
    [[RPVAccountChecker sharedInstance] checkUsername:self.emailTextField.text withPassword:self.passwordTextField.text andCompletionHandler:^(NSString *failureReason, NSString *resultCode, NSArray *teamIDArray) {
       
        if (teamIDArray) {
            // TODO: Handle the Team ID array. If one element, no worries. Otherwise we need to ask the user
            // which team to use.
            // TODO: Once handled, we need to register the current device if so required to that Team ID.
            // TODO: Save Team ID and username/password combo
            // TODO: Un-present ourselves!
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentTeamIDViewControllerIfNecessaryWithTeamIDs:teamIDArray];
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
    self.confirmButton.enabled = NO;
}

////////////////////////////////////////////////////////
// UITextFieldDelegate
////////////////////////////////////////////////////////

- (void)textFieldDidChange:(id)sender {
    if ([self.emailTextField.text containsString:@"@"] && self.passwordTextField.text.length > 0) {
        self.confirmButtonItem.enabled = YES;
        self.confirmButton.enabled = YES;
    } else {
        self.confirmButtonItem.enabled = NO;
        self.confirmButton.enabled = NO;
    }
}

////////////////////////////////////////////////////////
// Segue Navigation
////////////////////////////////////////////////////////

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[[segue destinationViewController] class] isEqual:[RPVAccount2FAViewController class]]) {
        RPVAccount2FAViewController *twofaController = (RPVAccount2FAViewController*)[segue destinationViewController];
        
        // Setup 2FA controller with the current email address
        [twofaController setupWithEmailAddress:self.emailTextField.text];
    } else if ([[[segue destinationViewController] class] isEqual:[RPVAccountTeamIDViewController class]]) {
        // If Team ID controller, pass through the interim team ID array.
        RPVAccountTeamIDViewController *teamidController = (RPVAccountTeamIDViewController*)[segue destinationViewController];
        
        [teamidController setupWithDataSource:self._interimTeamIDArray username:self.emailTextField.text andPassword:self.passwordTextField.text];
    } else if ([[[segue destinationViewController] class] isEqual:[RPVAccountFinalController class]]) {
        // or if the final controller, send everything through!
        
        NSString *teamID = [[self._interimTeamIDArray firstObject] objectForKey:@"teamId"];
        NSString *username = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
        
        RPVAccountFinalController *finalController = (RPVAccountFinalController*)[segue destinationViewController];
        
        [finalController setupWithUsername:username password:password andTeamID:teamID];
    }
}

@end
