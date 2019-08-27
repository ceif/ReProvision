//
//  RPVAccountViewController.h
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPVAccountViewController : UIViewController <UITextFieldDelegate>
{
    UITapGestureRecognizer *menuTapRecognizer;
}
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *appleOnlyLabel;

@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIBarButtonItem *confirmButtonItem;
@property (strong, nonatomic) UIButton *cbutton;
@property (strong, nonatomic) UIButton *confirmButton;

@end
