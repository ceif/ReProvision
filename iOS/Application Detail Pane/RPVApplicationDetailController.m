//
//  RPVApplicationDetailController.m
//  iOS
//
//  Created by Matt Clarke on 14/07/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//


#import "RPVApplicationDetailController.h"
#import "RPVApplication.h"
#import "RPVIpaBundleApplication.h"
#import "RPVApplicationSigning.h"
#import "RPVCalendarController.h"
#import "RPVResources.h"

#import <MarqueeLabel.h>

#if !TARGET_OS_TV
#import <MBCircularProgressBarView.h>
#endif

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface RPVApplicationDetailController (){
    
    CGFloat fontMultiplier;
}

// Basic heirarchy
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIView *darkeningView;
@property (nonatomic, strong) UIView *contentView;

// Components
@property (nonatomic, strong) UIImageView *applicationIconView;
@property (nonatomic, strong) MarqueeLabel *applicationNameLabel;
@property (nonatomic, strong) MarqueeLabel *applicationBundleIdentifierLabel;

@property (nonatomic, strong) UILabel *versionTitle;
@property (nonatomic, strong) UILabel *applicationVersionLabel;

@property (nonatomic, strong) UILabel *installedSizeTitle;
@property (nonatomic, strong) UILabel *applicationInstalledSizeLabel;

@property (nonatomic, strong) UILabel *calendarTitle;
@property (nonatomic, strong) RPVCalendarController *calendarController;

@property (nonatomic, strong) MarqueeLabel *percentCompleteLabel;
#if !TARGET_OS_TV
@property (nonatomic, strong) MBCircularProgressBarView *progressBar;
#endif
@property (nonatomic, strong) UIButton *signingButton;

// Exit controls
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITapGestureRecognizer *closeGestureRecogniser;

// Data source
@property (nonatomic, strong) RPVApplication *application;

@end

@implementation RPVApplicationDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithApplication:(RPVApplication*)application {
    
    fontMultiplier = 1;
#if TARGET_OS_TV
    fontMultiplier = 2;
#endif
    
    self = [super init];
    
    if (self) {
        self.application = application;
        self.lockWhenInstalling = NO;
        
        // Signing Notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onSigningStatusUpdate:) name:@"com.matchstic.reprovision/signingUpdate" object:nil];
    }
    
    return self;
}

- (void)setCurrentSigningPercent:(int)percent {
    if (percent < 100) // no need to show progress if 100% done
        [self _signingProgressDidUpdate:percent];
}

- (void)setButtonTitle:(NSString*)title {
    if (!self.isViewLoaded) {
        [self loadView];
    }
    
    [self.signingButton setTitle:title forState:UIControlStateNormal];
    [self.signingButton setTitle:title forState:UIControlStateHighlighted];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor clearColor];
    
    // Load up blur view, and content view as needed.
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.backgroundView.contentView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.backgroundView];
    
    // Darkening view.
    self.darkeningView = [[UIView alloc] initWithFrame:CGRectZero];
    self.darkeningView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.darkeningView.userInteractionEnabled = NO;
    
    [self.backgroundView.contentView addSubview:self.darkeningView];
    
    // Content view
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 12.5;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.contentView];
    
    [self _setupContentViewComponents];
    
#if TARGET_OS_TV
    
    [self _setupFocusGuide];
    [self updateForMode];
    
#endif
    
}

- (void)_setupContentViewComponents {
    // Load components for the content view, from the application's info.
    
    // Icon
    [self _addApplicationIconComponent];
    
    // Title.
    [self _addApplicationNameComponent];
    
    // Bundle ID.
    [self _addApplicationBundleIdentifierComponent];
    
    // Signing button
    [self _addMajorButtonComponent];
    
    // Version
    [self _addApplicationVersionComponent];
    
    // Installed size
    [self _addApplicationInstalledSizeComponent];
    
    // Calendar
    if ([self.application.class isEqual:[RPVApplication class]])
        [self _addCalendarComponent];
    
    // Progress bar etc
    [self _addProgressComponents];
    
    // Exit controls
    [self _addCloseControls];
}

- (void)_addApplicationNameComponent {
    self.applicationNameLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero];
    self.applicationNameLabel.text = [self.application applicationName];
    self.applicationNameLabel.textColor = [UIColor blackColor];
    self.applicationNameLabel.font = [UIFont systemFontOfSize:18.6*fontMultiplier weight:UIFontWeightBold];
    
    // MarqueeLabel specific
    self.applicationNameLabel.fadeLength = 8.0;
    self.applicationNameLabel.trailingBuffer = 10.0;
    
    [self.contentView addSubview:self.applicationNameLabel];
}

- (void)_addApplicationIconComponent {
    self.applicationIconView = [[UIImageView alloc] initWithImage:[self.application applicationIcon]];
    
    [self.contentView addSubview:self.applicationIconView];
}

- (void)_addApplicationBundleIdentifierComponent {
    self.applicationBundleIdentifierLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero];
    self.applicationBundleIdentifierLabel.text = [self.application bundleIdentifier];
    self.applicationBundleIdentifierLabel.textColor = [UIColor grayColor];
    self.applicationBundleIdentifierLabel.font = [UIFont systemFontOfSize:14*fontMultiplier weight:UIFontWeightMedium];
    
    // MarqueeLabel specific
    self.applicationBundleIdentifierLabel.fadeLength = 8.0;
    self.applicationBundleIdentifierLabel.trailingBuffer = 10.0;
    
    [self.contentView addSubview:self.applicationBundleIdentifierLabel];
}

- (void)_addApplicationVersionComponent {
    self.versionTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.versionTitle.text = @"Version";
    self.versionTitle.textColor = [UIColor grayColor];
    self.versionTitle.textAlignment = NSTextAlignmentCenter;
    self.versionTitle.font = [UIFont systemFontOfSize:14*fontMultiplier];
    
    [self.contentView addSubview:self.versionTitle];
    
    self.applicationVersionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.applicationVersionLabel.text = [self.application applicationVersion];
    self.applicationVersionLabel.textColor = [UIColor blackColor];
    self.applicationVersionLabel.textAlignment = NSTextAlignmentCenter;
    self.applicationVersionLabel.font = [UIFont systemFontOfSize:16*fontMultiplier weight:UIFontWeightSemibold];
    
    [self.contentView addSubview:self.applicationVersionLabel];
}

- (void)_addApplicationInstalledSizeComponent {
    self.installedSizeTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.installedSizeTitle.text = @"Size";
    self.installedSizeTitle.textColor = [UIColor grayColor];
    self.installedSizeTitle.textAlignment = NSTextAlignmentCenter;
    self.installedSizeTitle.font = [UIFont systemFontOfSize:14*fontMultiplier];
    
    [self.contentView addSubview:self.installedSizeTitle];
    
    self.applicationInstalledSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.applicationInstalledSizeLabel.text = [NSString stringWithFormat:@"%.2f MB", [self.application applicationInstalledSize].floatValue / 1024.0 / 1024.0];
    self.applicationInstalledSizeLabel.textColor = [UIColor blackColor];
    self.applicationInstalledSizeLabel.textAlignment = NSTextAlignmentCenter;
    self.applicationInstalledSizeLabel.font = [UIFont systemFontOfSize:16*fontMultiplier weight:UIFontWeightSemibold];
    
    [self.contentView addSubview:self.applicationInstalledSizeLabel];
}

- (void)_addMajorButtonComponent {
#if !TARGET_OS_TV
    self.signingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.signingButton.layer.cornerRadius = 14.0;
    
#else
    self.signingButton = [UIButton buttonWithType:UIButtonTypeSystem];
#endif
    [self.signingButton setTitle:@"BTN" forState:UIControlStateNormal];
    self.signingButton.titleLabel.font = [UIFont boldSystemFontOfSize:14*fontMultiplier];
    
    self.signingButton.backgroundColor = [UIColor whiteColor];
    
    // Add gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.signingButton.bounds;
    gradient.cornerRadius = self.signingButton.layer.cornerRadius;
    
    UIColor *startColor = [UIColor colorWithRed:147.0/255.0 green:99.0/255.0 blue:207.0/255.0 alpha:1.0];
    UIColor *endColor = [UIColor colorWithRed:116.0/255.0 green:158.0/255.0 blue:201.0/255.0 alpha:1.0];
    gradient.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    gradient.startPoint = CGPointMake(1.0, 0.5);
    gradient.endPoint = CGPointMake(0.0, 0.5);
    
    [self.signingButton.layer insertSublayer:gradient atIndex:0];
    
    NSUInteger controlState = UIControlStateHighlighted;
    NSUInteger controlEvent = UIControlEventTouchUpInside;
    
    // Button colouration
    [self.signingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
#if TARGET_OS_TV
    controlState = UIControlStateFocused;
    controlEvent = UIControlEventPrimaryActionTriggered;
    [self.signingButton setTitleColor:[UIColor blackColor] forState:controlState];
#else
    [self.signingButton setTitleColor:[UIColor whiteColor] forState:controlState];

#endif

    [self.signingButton addTarget:self action:@selector(_userDidTapMajorButton:) forControlEvents:controlEvent];
    
    [self.contentView addSubview:self.signingButton];
}

- (void)_addCalendarComponent {
    self.calendarTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.calendarTitle.text = @"Expires";
    self.calendarTitle.textColor = [UIColor grayColor];
    self.calendarTitle.textAlignment = NSTextAlignmentCenter;
    self.calendarTitle.font = [UIFont systemFontOfSize:14*fontMultiplier];
    [self.contentView addSubview:self.calendarTitle];
    
    self.calendarController = [[RPVCalendarController alloc] initWithDate:[self.application applicationExpiryDate]];
    
    [self.contentView addSubview:self.calendarController.view];
}

- (void)_addCloseControls {

    NSUInteger controlEvent = UIControlEventTouchUpInside;
#if !TARGET_OS_TV
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.alpha = 0.5;
    self.closeButton.clipsToBounds = YES;
    
    // Button image (cross)
    [self.closeButton setImage:[UIImage imageNamed:@"buttonClose"] forState:UIControlStateNormal];
#else
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    [self.closeButton setTitle:@"CLOSE" forState:UIControlStateFocused];
    [self.closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateFocused];
    controlEvent = UIControlEventPrimaryActionTriggered;
    self.closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14*fontMultiplier];
    
    //self.closeButton.layer.cornerRadius = 14.0;
    //self.closeButton.backgroundColor = [UIColor whiteColor];
    
    // Add gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.closeButton.bounds;
    gradient.cornerRadius = self.closeButton.layer.cornerRadius;
    
    UIColor *startColor = [UIColor colorWithRed:147.0/255.0 green:99.0/255.0 blue:207.0/255.0 alpha:1.0];
    UIColor *endColor = [UIColor colorWithRed:116.0/255.0 green:158.0/255.0 blue:201.0/255.0 alpha:1.0];
    gradient.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    gradient.startPoint = CGPointMake(1.0, 0.5);
    gradient.endPoint = CGPointMake(0.0, 0.5);
    
    [self.closeButton.layer insertSublayer:gradient atIndex:0];
    
    // Button colouration
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
#endif

    
    [self.closeButton addTarget:self action:@selector(_userDidTapCloseButton:) forControlEvents:controlEvent];
    
    self.closeGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_userDidTapToClose:)];
    [self.backgroundView.contentView addGestureRecognizer:self.closeGestureRecogniser];
#if !TARGET_OS_TV
    [self.view addSubview:self.closeButton];
#else
    [self.contentView addSubview:self.closeButton];
#endif
}

- (void)_addProgressComponents {
    self.percentCompleteLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero];
    self.percentCompleteLabel.text = @"0% complete";
    self.percentCompleteLabel.font = [UIFont systemFontOfSize:14*fontMultiplier weight:UIFontWeightMedium];
    self.percentCompleteLabel.hidden = YES;
    self.percentCompleteLabel.textColor = [UIColor grayColor];
    
    // MarqueeLabel specific
    self.percentCompleteLabel.fadeLength = 8.0;
    self.percentCompleteLabel.trailingBuffer = 10.0;
    
    [self.contentView addSubview:self.percentCompleteLabel];
    #if !TARGET_OS_TV
    self.progressBar = [[MBCircularProgressBarView alloc] initWithFrame:CGRectZero];
    
    self.progressBar.value = 0.0;
    self.progressBar.maxValue = 100.0;
    self.progressBar.showUnitString = NO;
    self.progressBar.showValueString = NO;
    self.progressBar.progressCapType = kCGLineCapRound;
    self.progressBar.emptyCapType = kCGLineCapRound;
    self.progressBar.progressLineWidth = 1.5;
    self.progressBar.progressColor = [UIColor darkGrayColor];
    self.progressBar.progressStrokeColor = [UIColor darkGrayColor];
    self.progressBar.emptyLineColor = [UIColor lightGrayColor];
    self.progressBar.backgroundColor = [UIColor clearColor];
    
    self.progressBar.hidden = YES;
    
    [self.contentView addSubview:self.progressBar];
#endif
}

#if TARGET_OS_TV

- (void)updateForMode {

    if ([self darkMode]){
        self.applicationNameLabel.textColor = [UIColor whiteColor];
        self.percentCompleteLabel.textColor = [UIColor whiteColor];
        self.applicationVersionLabel.textColor = [UIColor whiteColor];
        self.applicationInstalledSizeLabel.textColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor blackColor];
    } else {
        self.applicationNameLabel.textColor = [UIColor blackColor];
        self.percentCompleteLabel.textColor = [UIColor blackColor];
        self.applicationVersionLabel.textColor = [UIColor blackColor];
        self.applicationInstalledSizeLabel.textColor = [UIColor blackColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [self updateForMode];
}

#endif

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Layout blur, content, then the closing box.
    
    self.backgroundView.frame = self.view.bounds;
    self.darkeningView.frame = self.backgroundView.bounds;
    
    CGFloat itemInsetY = 25;
    CGFloat itemInsetX = 15;
    CGFloat innerItemInsetY = 7;
    CGFloat buttonTextMargin = 20;
    
    CGFloat y = itemInsetX; // Ends up being used for contentView height.
    CGFloat contentViewWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIScreen mainScreen].bounds.size.width * 0.5 : [UIScreen mainScreen].bounds.size.width * 0.95;
    
    CGFloat buttonHeight = 28;
    CGFloat titleHeight = 20;
    CGFloat titleAdjustment = 0;
    CGFloat titleBuffer = 0;
    CGFloat calendarOffset = 0;
#if TARGET_OS_TV
    itemInsetY *= 2;
    innerItemInsetY *=2;//400,240
    self.applicationIconView.frame=  CGRectMake(15, y, 200, 120);
    buttonHeight = 40;
    titleHeight = 30;
    titleAdjustment = 10;
    titleBuffer = 5;
    calendarOffset = 15;
#else
    self.applicationIconView.frame = CGRectMake(15, y, 60, 60);
#endif
    
    
    // Signing button.
    [self.signingButton sizeToFit];
    self.signingButton.frame = CGRectMake(contentViewWidth - itemInsetX - self.signingButton.frame.size.width - (buttonTextMargin * 2), (y + self.applicationIconView.frame.size.height/2) - 14, self.signingButton.frame.size.width + (buttonTextMargin * 2), buttonHeight);
    
    for (CALayer *layer in self.signingButton.layer.sublayers) {
        layer.frame = self.signingButton.bounds;
    }
    
#if TARGET_OS_TV
    
    // Close button.
    [self.closeButton sizeToFit];
    CGFloat closeButtonX = self.signingButton.frame.origin.x;
    CGFloat closeButtonY = (y + self.signingButton.frame.size.height + self.applicationIconView.frame.size.height/2);
    self.closeButton.frame = CGRectMake(closeButtonX, closeButtonY, self.signingButton.frame.size.width, buttonHeight);
    
    for (CALayer *layer in self.closeButton.layer.sublayers) {
        layer.frame = self.closeButton.bounds;
    }
    
#endif
    
    // Name and bundle ID are same height?
    CGFloat insetAfterIcon = self.applicationIconView.frame.origin.x + self.applicationIconView.frame.size.width + itemInsetX;
    self.applicationNameLabel.frame = CGRectMake(insetAfterIcon, y + 5, contentViewWidth - insetAfterIcon - itemInsetX*2 - self.signingButton.frame.size.width, titleHeight+titleAdjustment);
    
    // Bundle ID.
    self.applicationBundleIdentifierLabel.frame = CGRectMake(insetAfterIcon, y + 35 + titleBuffer, contentViewWidth - insetAfterIcon - itemInsetX*2 - self.signingButton.frame.size.width, titleHeight);
    
    
#if !TARGET_OS_TV
    // Progress bar and label.
    self.progressBar.frame = CGRectMake(self.applicationBundleIdentifierLabel.frame.origin.x, self.applicationBundleIdentifierLabel.frame.origin.y, 20, 20);
    self.percentCompleteLabel.frame = CGRectMake(self.applicationBundleIdentifierLabel.frame.origin.x + self.progressBar.frame.size.width + 5, self.applicationBundleIdentifierLabel.frame.origin.y, self.applicationBundleIdentifierLabel.frame.size.width - 5 - self.progressBar.frame.size.width, titleHeight);
#else
    self.percentCompleteLabel.frame = CGRectMake(self.applicationBundleIdentifierLabel.frame.origin.x + 20 + 5, self.applicationBundleIdentifierLabel.frame.origin.y, self.applicationBundleIdentifierLabel.frame.size.width - 5 - 20, titleHeight);
#endif
    
    y += 60 + itemInsetY;
    
    // Version label
    
    CGFloat detailItemWidth = contentViewWidth/3 - itemInsetX*2;
    self.versionTitle.frame = CGRectMake(contentViewWidth/2 - detailItemWidth - itemInsetX, y, detailItemWidth, titleHeight);
    self.applicationVersionLabel.frame = CGRectMake(self.versionTitle.frame.origin.x, y + titleHeight + innerItemInsetY, detailItemWidth, titleHeight);
    
    // Installed size
    
    self.installedSizeTitle.frame = CGRectMake(contentViewWidth/2 + itemInsetX, y, detailItemWidth, titleHeight);
    self.applicationInstalledSizeLabel.frame = CGRectMake(self.installedSizeTitle.frame.origin.x, y + titleHeight + innerItemInsetY, detailItemWidth, titleHeight);
    
    y += titleHeight*2 + itemInsetY + innerItemInsetY;
    
    // Calendar, only if not an IPA application
    if ([self.application.class isEqual:[RPVApplication class]]) {
        self.calendarTitle.frame = CGRectMake(itemInsetX, y, contentViewWidth - itemInsetX*2, titleHeight);
        self.calendarController.view.frame = CGRectMake(0, y + titleHeight + innerItemInsetY + calendarOffset, contentViewWidth, [self.calendarController calendarHeight]);
        
        y += titleHeight + [self.calendarController calendarHeight] + itemInsetY + innerItemInsetY;
        
        //NSLog(@"y: %f ch: %f", y, [self.calendarController calendarHeight]);
#if TARGET_OS_TV
        //y+=20;
#endif
        
    }

    self.contentView.frame = CGRectMake(self.view.frame.size.width/2 - contentViewWidth/2, self.view.frame.size.height/2 - y/2, contentViewWidth, y);
    
#if !TARGET_OS_TV
    // Close button.
    self.closeButton.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y - 35, 30, 30);
    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.width/2.0;
#else
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self setNeedsFocusUpdate];
        //[self updateFocusIfNeeded];
    });
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    
}

#if TARGET_OS_TV

- (NSArray<id<UIFocusEnvironment>> *)preferredFocusEnvironments {
    
    if (self.signingButton == nil)
    {
        return @[self.view];
    }
    return @[self.signingButton];
}


- (UIView *)preferredFocusedView {
    
    return self.signingButton;
    
}

#endif

////////////////////////////////////////////////////////////////////////////////
// Animations
////////////////////////////////////////////////////////////////////////////////

- (void)animateForPresentation {
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.view.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.closeButton.frame = CGRectMake(self.closeButton.frame.origin.x, self.view.frame.size.height, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
    self.view.alpha = 0.0;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.765
          initialSpringVelocity:0.15
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.view.alpha = 1.0;
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.view.frame.size.height/2 - self.contentView.frame.size.height/2, self.contentView.frame.size.width, self.contentView.frame.size.height);
        self.closeButton.frame = CGRectMake(self.closeButton.frame.origin.x, self.contentView.frame.origin.y -self.closeButton.frame.size.height - 5, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateForDismissalWithCompletion:(void (^)(void))completionHandler {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.view.alpha = 0.0;
        self.closeButton.frame = CGRectMake(self.closeButton.frame.origin.x, self.view.frame.size.height, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.view.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
            completionHandler();
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////
// Button callbacks
////////////////////////////////////////////////////////////////////////////////

- (void)_userDidTapCloseButton:(id)button {
    // animate out, and hide.
    [self animateForDismissalWithCompletion:^{
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        self.parentViewController.view.userInteractionEnabled = true;
        // Unregister for notifications
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.matchstic.reprovision.ios/reloadFocusAvailability" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

- (void)_userDidTapMajorButton:(id)button {
    if (self.warnUserOnResign) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Warning"
                                     message:[NSString stringWithFormat:@"This will remove the current certificate of '%@', and replaces it with a new certificate from your Apple ID.\n\nAre you sure you want to continue?", [self.application applicationName]]
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* continueButton = [UIAlertAction
                                    actionWithTitle:@"Continue"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        [self _initiateSigningForCurrentApplication];
                                    }];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {

                                   }];
        
        [alert addAction:continueButton];
        [alert addAction:cancelButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self _initiateSigningForCurrentApplication];
    }
}

////////////////////////////////////////////////////////////////////////////////
// UITapGesture callbacks
////////////////////////////////////////////////////////////////////////////////

- (void)_userDidTapToClose:(id)sender {
    
    [self _userDidTapCloseButton:nil];
}

////////////////////////////////////////////////////////////////////////////////
// Application signing callbacks
////////////////////////////////////////////////////////////////////////////////

- (void)_initiateSigningForCurrentApplication {
    // Start signing this one app.
    [[RPVApplicationSigning sharedInstance] resignSpecificApplications:@[self.application]
                                                            withTeamID:[RPVResources getTeamID]
                                                              username:[RPVResources getUsername]
                                                              password:[RPVResources getPassword]];
}

- (void)_onSigningStatusUpdate:(NSNotification*)notification {
    NSString *bundleIdentifier = [[notification userInfo] objectForKey:@"bundleIdentifier"];
    int percent = [[[notification userInfo] objectForKey:@"percent"] intValue];
    
    if ([bundleIdentifier isEqualToString:[self.application bundleIdentifier]]) {
        [self _signingProgressDidUpdate:percent];
    }
}

- (void)_signingProgressDidUpdate:(int)percent {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (percent > 0) {
            self.percentCompleteLabel.hidden = NO;
#if !TARGET_OS_TV
            self.progressBar.hidden = NO;
#endif
            self.signingButton.alpha = 0.5;
            self.signingButton.enabled = NO;
            
            self.applicationBundleIdentifierLabel.hidden = YES;
            
            // If necessary, "lock" user exit controls.
            if (self.lockWhenInstalling) {
                self.closeButton.hidden = YES;
                self.closeGestureRecogniser.enabled = NO;
            }
        }
        
        // Update progess bar!
        [UIView animateWithDuration:percent == 0 ? 0.0 : 0.35 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
#if !TARGET_OS_TV
            self.progressBar.value = percent;
#endif
            self.percentCompleteLabel.text = [NSString stringWithFormat:@"%d%% complete", percent];
        } completion:^(BOOL finished) {
            if (finished && percent == 100) {
                self.percentCompleteLabel.hidden = YES;
#if !TARGET_OS_TV
                self.progressBar.hidden = YES;
#endif
                self.signingButton.alpha = 1.0;
                self.signingButton.enabled = YES;
                
                self.applicationBundleIdentifierLabel.hidden = NO;
                
                // If necessary, "unlock" user exit controls.
                if (self.lockWhenInstalling) {
                    self.closeButton.hidden = NO;
                    self.closeGestureRecogniser.enabled = YES;
                }
            }
        }];
    });
}

#if TARGET_OS_TV

- (void)_setupFocusGuide {
    UIFocusGuide *guide = [[UIFocusGuide alloc] init];
    guide.preferredFocusedView = self.signingButton;
    [self.view addLayoutGuide:guide];
    
    // Constraints
    [self.view addConstraints:@[
                                [guide.topAnchor constraintEqualToAnchor:self.self.view.topAnchor],
                                [guide.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                [guide.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                [guide.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
                                ]];
}

- (BOOL)shouldUpdateFocusInContext:(UIFocusUpdateContext *)context {
    
    static NSString *kUITabBarButtonClassName = @"UITabBar";
    NSString *nextFocusedView = NSStringFromClass([context.nextFocusedView class]);
    if ([nextFocusedView containsString:kUITabBarButtonClassName] || [nextFocusedView isEqualToString:@"RPVInstalledCollectionViewCell"] || [nextFocusedView isEqualToString:@"RPVInstalledTableViewCell"]){
        return FALSE;
    }
    return TRUE;

}

/*
- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    
    
}
 */
#endif


@end
