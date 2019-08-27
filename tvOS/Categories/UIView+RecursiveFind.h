

#import <UIKit/UIKit.h>

@interface NSString (Debugging)

- (id)objectForKey:(NSString *)key;

@end

@interface UIApplication (PrintRecursion)

- (void)printWindow;

@end

@interface UIView (RecursiveFind)

- (UIView *)findFirstSubviewWithClass:(Class)theClass;
- (void)printRecursiveDescription;
- (void)removeAllSubviews;

@end
