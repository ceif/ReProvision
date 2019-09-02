//
//  UIViewController+Additions.h
//  nitoTV4
//
//  Created by Kevin Bradley on 7/17/18.
//  Copyright © 2018 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (Additions)

- (BOOL)appViewVisible;
@end

@interface UIView (Additions)
- (BOOL)darkMode;
@end

@interface UIViewController (Additions)
- (void)forceFocusUpdateDelayed:(CGFloat)delay;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message ;
- (BOOL)darkMode;
- (void)disableViewAndRefocus;
@end
