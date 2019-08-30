
#import <UIKit/UIKit.h>
#import "NSTask.h"

@interface LogViewController : UIViewController
{
    UITapGestureRecognizer *menuTapRecognizer;
}
@property (nonatomic, strong) __block NSTask *task;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (readwrite, assign) BOOL running;
@property (nonatomic, strong) NSString *runCommand;
@property (nonatomic, strong) UIButton *finishedButton;


- (id)initWithCommand:(NSString *)installCommand;
- (void)appendToText:(NSString *)text;

@end
