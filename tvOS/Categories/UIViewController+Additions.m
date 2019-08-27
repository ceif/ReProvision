//
//  UIViewController+Additions.m
//  nitoTV4
//
//  Created by Kevin Bradley on 7/17/18.
//  Copyright © 2018 nito. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation NSObject (Additions)


- (BOOL)appViewVisible {
    
    Class cls = NSClassFromString(@"RPVApplicationDetailController");
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    __block BOOL hasController = FALSE;
    [rootController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:cls]){
            *stop = TRUE;
            hasController = TRUE;
        }
    }];
    return hasController;
}


@end

@implementation UIView (Additions)


- (BOOL)darkMode {
    
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        return TRUE;
    }
    return FALSE;
}
@end

@implementation UIViewController (Additions)

- (void)disableViewAndRefocus {
    
}

- (void)forceFocusUpdateDelayed:(CGFloat)delay {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setNeedsFocusUpdate];
        [self updateFocusIfNeeded];
    });
    
}

- (BOOL)darkMode {
    
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        return TRUE;
    }
    return FALSE;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ac animated:true completion:nil];
    });
    
}

@end
