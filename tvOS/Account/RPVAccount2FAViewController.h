//
//  RPVAccount2FAViewController.h
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPVAccount2FAViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *appleOnlyLabel;

@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIBarButtonItem *confirmBarButtonItem;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *cbutton;

- (void)setupWithEmailAddress:(NSString*)emailAddress;

@end
