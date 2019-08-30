#import "LogViewController.h"


@implementation LogViewController

@synthesize running, runCommand;

- (id)initWithCommand:(NSString *)installCommand
{
    DDLogInfo(@"installCommand: %@", installCommand);
    self = [super init];
    self.runCommand = installCommand;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.running = false;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [self.view addSubview:blurView];
    [blurView autoPinEdgesToSuperviewEdges];
    [self.view addSubview:vibrancyEffectView];
    [vibrancyEffectView autoPinEdgesToSuperviewEdges];
    self.titleLabel = [[UILabel alloc] initForAutoLayout];
    UIView *bufferView = [[UIView alloc] initForAutoLayout];
    [self.view insertSubview:self.titleLabel aboveSubview:vibrancyEffectView];
    self.titleLabel.textColor = [UIColor whiteColor];
    UIFont *currentFont = self.titleLabel.font;
    DLog(@"currentFont: %@", currentFont);
    //currentFont = [currentFont copyWithPointSize:70];
    [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:30];
    self.titleLabel.font = currentFont;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:vibrancyEffectView withMultiplier:0.8];
    
    //self.textView = [[KBSelectableTextView alloc] initWithFrame:CGRectMake(100, 200, self.view.bounds.size.width-200, self.view.bounds.size.height-400)];
    self.textView = [[UITextView alloc] initForAutoLayout];
    [self.textView autoSetDimensionsToSize:CGSizeMake(self.view.bounds.size.width-200, self.view.bounds.size.height-400)];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = false;
    self.textView.userInteractionEnabled = true;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    CGRect viewBounds = self.view.bounds;
    
    self.finishedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    // [self.view addSubview:self.textView];
    [vibrancyEffectView.contentView addSubview:self.textView];
    [self.textView autoCenterInSuperview];
    //self.textView.focusColorChange = NO;
    [self.finishedButton setHidden:true];
    [self.finishedButton setTitle:@"Done" forState:UIControlStateNormal];
    CGRect buttonFrame = CGRectMake((viewBounds.size.width - 400)/2, viewBounds.size.height - 150, 400, 86);
    
    [self.finishedButton addTarget:self action:@selector(popController) forControlEvents:UIControlEventPrimaryActionTriggered];
    [[self finishedButton] setEnabled:false];
    [self.finishedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.finishedButton setTitleColor:[UIColor blackColor] forState:UIControlStateFocused];
    self.finishedButton.frame = buttonFrame;
    [[self view] addSubview:self.finishedButton];
    
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan) {
 
    }
    else if ( gesture.state == UIGestureRecognizerStateEnded) {
 
    }
}

- (void)popController
{
    DDLogInfo(@"done");

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)handleMenuTap:(id)sender
{
    LOG_SELF;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.title;
    [self run];
    
    self.textView.panGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeIndirect)];
    
    
}


- (void)run
{

    if (self.running == true) { DDLogInfo(@"already running"); return; }
    
    DDLogInfo(@"running task: %@", runCommand);
    
    //could probably just move this into view did load, but likely was culprit for the erratic removal crash.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.textView.layoutManager ensureLayoutForTextContainer:self.textView.textContainer];
    });
    
    [self runTask:self.runCommand withCompletion:^(NSInteger returnStatus) {
        
        self.running = false;

        [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
        DDLogInfo(@"%@ completed with status: %lu", runCommand, returnStatus);
        [self.finishedButton setHidden:false];
    
        [[self finishedButton] setEnabled:true];
    }];
    
}

- (void)scrollToBottom
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.textView.scrollEnabled= NO;
        [UIView setAnimationsEnabled:NO];
        [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
        [UIView setAnimationsEnabled:YES];
        self.textView.scrollEnabled = YES;
    });
}


- (void)appendToText:(NSString *)text
{
    NSString *currentText = [self.textView text];
    [UIView setAnimationsEnabled:NO];
    currentText = [currentText stringByAppendingString:text];
    [self.textView setText:currentText];
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
    [UIView setAnimationsEnabled:YES];

}
/*
- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event
{
    LOG_SELF;
    DDLogInfo(@"presses: %@", presses);
    
    for (UIPress *press in presses)
    {
        if (press.type == UIPressTypeMenu)
        {
            DDLogInfo(@"no exit for u!");
        } else {
            [super pressesBegan:presses withEvent:event];
        }
    }
    
}
*/

/*
- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event
{
    DDLogInfo(@"presses: %@", presses);
    
    for (UIPress *press in presses)
    {
        if (press.type == UIPressTypeMenu)
        {
            DDLogInfo(@"no exit for u!");
        } else {
            [super pressesEnded:presses withEvent:event];
        }
    }
}
 */

- (BOOL)canRunTask
{
    return true;
 
}

- (void)runTask:(NSString *)task withCompletion:(void(^)(NSInteger returnStatus))completionBlock
{
    if ([self canRunTask] == false)
    {
        completionBlock(-20);
        return;
    }
    
    self.running = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @autoreleasepool {
            
            NSInteger _returnCode = 0;
             char line[10000];
            
            NSString *command = [NSString stringWithFormat:@"/usr/bin/tail %@", task];
            
             FILE* fp = popen([command UTF8String], "r");
             
             if (fp)
             {
             while (fgets(line, sizeof line, fp))
             {
             NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
             dispatch_async(dispatch_get_main_queue(), ^{
             
             
             [self appendToText:s];
             //NSLog(@"%@",s);
             });
             }
             }
             
             _returnCode = pclose(fp);
             //_finished =YES;
             
            
            
            /*
            NSArray *taskArguments = [task componentsSeparatedByString:@" "];
            NSInteger _returnCode = 0;
            
            DDLogInfo(@"%@ %@", @"/usr/bin/tail", [taskArguments componentsJoinedByString:@" "]);
            self.task = [[NSTask alloc] init];
            NSPipe *pipe = [[NSPipe alloc] init];
            NSFileHandle *handle = [pipe fileHandleForReading];
            [self.task setLaunchPath:@"/usr/bin/tail"];
            [self.task setArguments:taskArguments];
            [self.task setStandardOutput:pipe];
            [self.task setStandardError:pipe];
            NSPipe *input = [[NSPipe alloc] init];
            [self.task setStandardInput:input];
            [self.task launch];
            
            NSData *outData = nil;
            NSString *temp = nil;
            NSInteger  lineCount = 0;
            NSMutableArray *lines = [NSMutableArray new];
            NSFileHandle *readHandle = [pipe fileHandleForReading];
            while ((outData = [readHandle availableData]) &&
                   [outData length]) {
                temp = [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
                [lines addObject:temp];
                lineCount++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendToText:temp];
                    DDLogInfo(@"%@",temp);
                });
            }
            
            while ([self.task isRunning]) {
                DDLogInfo(@"task is still running!! try to kill it with fire!");
                [self.task terminate];
            }
            
            _returnCode = [self.task terminationStatus];
            [handle closeFile];
            self.task = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionBlock(_returnCode);
                
            });
      */
        }
        
    });
    
}

- (void)sendCommand:(NSString *)theString
{
    if(theString == nil)
        return;
    
    NSData *outData = nil;
    outData = [theString dataUsingEncoding:NSASCIIStringEncoding
                      allowLossyConversion:YES];
    [[[self.task standardInput] fileHandleForWriting] writeData:outData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self appendToText:@"\n"];
        
    });
    
}




@end
