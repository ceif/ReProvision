//
//  RPVTabBarController.m
//  iOS
//
//  Created by Matt Clarke on 07/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVTabBarController.h"
#import "RPVAccountViewController.h"
#import "RPVResources.h"

@interface RPVTabBarController ()

@end

@implementation RPVTabBarController

- (BOOL)shouldUpdateFocusInContext:(UIFocusUpdateContext *)context {
    
    static NSString *kUITabBarButtonClassName = @"UITabBar";
    NSString *nextFocusedView = NSStringFromClass([context.nextFocusedView class]);
    NSLog(@"RPVInstalledView next focused view: %@ previous: %@", context.nextFocusedView, context.previouslyFocusedView);
    if ([self appViewVisible]){
        NSLog(@"app view visible");
        if ([nextFocusedView containsString:kUITabBarButtonClassName] || [nextFocusedView isEqualToString:@"RPVInstalledCollectionViewCell"] || [nextFocusedView isEqualToString:@"RPVInstalledTableViewCell"]){
            return FALSE;
        }
    }
    return [super shouldUpdateFocusInContext:context];;
    
}

- (UIView *)preferredFocusedView  {
    
    if ([self appViewVisible]){
        DDLogInfo(@"app view visible");
        return nil;
    }
    
    return [super preferredFocusedView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRequestAccountViewController:) name:@"RPVDisplayAccountSignInController" object:nil];
    
    // Check if we need to present the account view based upon settings.
    if (![RPVResources getUsername] || [[RPVResources getUsername] isEqualToString:@""])
        [self presentAccountViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userDidRequestAccountViewController:(id)sender {
    [self presentAccountViewControllerAnimated:YES];
}

- (void)presentAccountViewControllerAnimated:(BOOL)animated {

    RPVAccountViewController *accountController = [RPVAccountViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountController];
    
    [self presentViewController:navController animated:animated completion:^{
        
    }];
    
    
}


@end
