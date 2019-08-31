

#import "UIView+RecursiveFind.h"

@implementation UIApplication (PrintRecursion)

- (void)printWindow
{
    [self.keyWindow.rootViewController.view printRecursiveDescription];
}

@end

@implementation UIView (RecursiveFind)



- (UIView *)findFirstSubviewWithClass:(Class)theClass {
    
    if ([self isMemberOfClass:theClass]) {
            return self;
        }
    
    for (UIView *v in self.subviews) {
        UIView *theView = [v findFirstSubviewWithClass:theClass];
        if (theView != nil)
        {
            return theView;
        }
    }
    return nil;
}

- (void)printRecursiveDescription
{
    NSString *recursiveDesc = [self performSelector:@selector(recursiveDescription)];
    DDLogInfo(@"%@", recursiveDesc);
}

- (void)removeAllSubviews
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}


@end
