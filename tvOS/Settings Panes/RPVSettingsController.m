//
//  EESettingsController.m
//  Extender Installer
//
//  Created by Matt Clarke on 26/04/2017.
//
//

#import "RPVSettingsController.h"
#import "RPVAdvancedController.h"
#import "RPVResources.h"
#import <objc/runtime.h>



@implementation RPVListItemsController


- (void)viewWillAppear:(bool)arg1 {
 
    [super viewWillAppear:arg1];
    
    //if ([self darkMode]){
     
      //  [self.view printRecursiveDescription];
        UITableView *table = [self table];
        table.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor clearColor];
    //}
    
    
}

@end

@interface PSSpecifier (Private)
- (void)setButtonAction:(SEL)arg1;
@end

@interface PSSubtitleSwitchTableCell : PSTableCell
+ (long long)cellStyle;
- (void)refreshCellContentsWithSpecifier:(id)arg1;
- (_Bool)canReload;
@end

@implementation RPVSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //id object = [RPVListLoader new];
    //DDLogInfo(@"obj: %@", object);
    self.view.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    [[self navigationItem] setTitle:@"Settings"];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [(UITableView*)self.table setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Reload Apple ID stuff
    [self updateSpecifiersForAppleID:[RPVResources getUsername]];
}

-(id)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *testingSpecs = [NSMutableArray array];
        
        // Create specifiers!
        [testingSpecs addObjectsFromArray:[self _appleIDSpecifiers]];
        [testingSpecs addObjectsFromArray:[self _alertSpecifiers]];
        
        _specifiers = testingSpecs;
    }
    
    return _specifiers;
}

- (NSArray*)_appleIDSpecifiers {
    NSMutableArray *loggedIn = [NSMutableArray array];
    NSMutableArray *loggedOut = [NSMutableArray array];
    
    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"Apple ID"];
    [group setProperty:@"Your password is only sent to Apple." forKey:@"footerText"];
    [loggedOut addObject:group];
    [loggedIn addObject:group];
    
    // Logged in
    
    NSString *title = [NSString stringWithFormat:@"Apple ID: %@", [RPVResources getUsername]];;
    _loggedInSpec = [PSSpecifier preferenceSpecifierNamed:title target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
    [_loggedInSpec setProperty:@"appleid" forKey:@"key"];
    
    [loggedIn addObject:_loggedInSpec];
    
    PSSpecifier *signout = [PSSpecifier preferenceSpecifierNamed:@"Sign Out" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [signout setButtonAction:@selector(didClickSignOut:)];
    [signout setProperty:@YES forKey:@"enabled"];
    
    [loggedIn addObject:signout];
    
    // Logged out.
    
    PSSpecifier *signin = [PSSpecifier preferenceSpecifierNamed:@"Sign In" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [signin setButtonAction:@selector(didClickSignIn:)];
    [signin setProperty:@YES forKey:@"enabled"];
    
    [loggedOut addObject:signin];
    
    _loggedInAppleSpecifiers = loggedIn;
    _loggedOutAppleSpecifiers = loggedOut;

    _hasCachedUser = [RPVResources getUsername] != nil;
    return _hasCachedUser ? _loggedInAppleSpecifiers : _loggedOutAppleSpecifiers;
}

- (NSArray*)_alertSpecifiers {
    NSMutableArray *array = [NSMutableArray array];
    
    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"Automated Re-signing"];
    [group setProperty:@"Set how many days away from an application's expiration date a re-sign will occur." forKey:@"footerText"];
    [array addObject:group];
    
    PSSpecifier *resign = [PSSpecifier preferenceSpecifierNamed:@"Automatically Re-sign" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSListItemCell edit:nil];
    [resign setProperty:@"resign" forKey:@"key"];
    [resign setProperty:@1 forKey:@"default"];
    [resign setProperty:NSClassFromString(@"PSSubtitleDisclosureTableCell") forKey:@"cellClass"];
    
    [array addObject:resign];
    
    PSSpecifier *threshold = [PSSpecifier preferenceSpecifierNamed:@"Re-sign Applications When:" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"RPVListItemsController") cell:PSLinkListCell edit:nil];
    [threshold setProperty:@YES forKey:@"enabled"];
    [threshold setProperty:@2 forKey:@"default"];
    threshold.values = [NSArray arrayWithObjects:@1, @2, @3, @4, @5, @6, nil];
    threshold.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1 Day Left", @"2 Days Left", @"3 Days Left", @"4 Days Left", @"5 Days Left", @"6 Days Left", nil] forKeys:threshold.values];
    threshold.shortTitleDictionary = threshold.titleDictionary;
    [threshold setProperty:@"thresholdForResigning" forKey:@"key"];
    [threshold setProperty:@"For example, setting \"2 Days Left\" will cause an application to be re-signed when it is 2 days away from expiring." forKey:@"staticTextMessage"];
    [threshold setProperty:@"com.matchstic.reprovision.ios/resigningThresholdDidChange" forKey:@"PostNotification"];
    
    [array addObject:threshold];
    
    PSSpecifier *group2 = [PSSpecifier groupSpecifierWithName:@"Notifications"];
    [array addObject:group2];
    
    PSSpecifier *showInfoAlerts = [PSSpecifier preferenceSpecifierNamed:@"Show Non-Urgent Alerts" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSListItemCell edit:nil];
    [showInfoAlerts setProperty:@"showNonUrgentAlerts" forKey:@"key"];
    [showInfoAlerts setProperty:@0 forKey:@"default"];
    [showInfoAlerts setProperty:NSClassFromString(@"PSSubtitleDisclosureTableCell") forKey:@"cellClass"];
    
    [array addObject:showInfoAlerts];
    
    PSSpecifier *showDebugAlerts = [PSSpecifier preferenceSpecifierNamed:@"Show Debug Alerts" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSListItemCell edit:nil];
    [showDebugAlerts setProperty:@"showDebugAlerts" forKey:@"key"];
    [showDebugAlerts setProperty:@0 forKey:@"default"];
    [showDebugAlerts setProperty:NSClassFromString(@"PSSubtitleDisclosureTableCell") forKey:@"cellClass"];
    
    [array addObject:showDebugAlerts];
    
    PSSpecifier *group3 = [PSSpecifier groupSpecifierWithName:@""];
    [array addObject:group3];
    
    PSSpecifier* troubleshoot = [PSSpecifier preferenceSpecifierNamed:@"Advanced"
                                                               target:self
                                                                  set:NULL
                                                                  get:NULL
                                                               detail:[RPVAdvancedController class]
                                                                 cell:PSLinkCell
                                                                 edit:Nil];
    [troubleshoot setProperty:@YES forKey:@"enabled"];
    
    [array addObject:troubleshoot];
    
    // Credits
    PSSpecifier *group4 = [PSSpecifier groupSpecifierWithName:@"Credits"];
    [array addObject:group4];
    
    PSSpecifier* author = [PSSpecifier preferenceSpecifierNamed:@"author"
                                                               target:self
                                                                  set:nil
                                                                  get:nil
                                                               detail:nil
                                                                 cell:PSLinkCell
                                                                 edit:nil];
    
    [array addObject:author];
    
    PSSpecifier* designer = [PSSpecifier preferenceSpecifierNamed:@"designer"
                                                         target:self
                                                            set:nil
                                                            get:nil
                                                         detail:nil
                                                           cell:PSLinkCell
                                                           edit:nil];
    
    [array addObject:designer];
    
#if TARGET_OS_TV
    PSSpecifier* nito = [PSSpecifier preferenceSpecifierNamed:@"nito"
                                                           target:self
                                                              set:nil
                                                              get:nil
                                                           detail:nil
                                                             cell:PSLinkCell
                                                             edit:nil];
    
    [array addObject:nito];
    
    
    
#endif
    
    
    PSSpecifier *openSourceLicenses = [PSSpecifier preferenceSpecifierNamed:@"Third-party Licenses"
                                                                     target:self
                                                                        set:nil
                                                                        get:nil
                                                                     detail:NSClassFromString(@"RPVWebViewController")
                                                                       cell:PSLinkCell
                                                                       edit:nil];
    
    [openSourceLicenses setProperty:@"openSourceLicenses" forKey:@"key"];
    
    [array addObject:openSourceLicenses];
    
    return array;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSSpecifier *represented = [self _specifierAtIndexPath:indexPath];
    
    if ([[represented propertyForKey:@"cellClass"] isEqual:NSClassFromString(@"PSSubtitleDisclosureTableCell")]) {
        static NSString *cellIdentifier = @"switch.cell";
        
        PSTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[PSTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier specifier:represented];
        } else {
            [cell setSpecifier:represented];
        }
        
        cell.textLabel.text = [represented name];
        
        // Setup end label.
        NSNumber *value = [self readPreferenceValue:represented];
        
        if (value.intValue == 0) {
            cell.detailTextLabel.text = [NSString localizedStringWithFormat:@"Off"];
        } else {
            cell.detailTextLabel.text = [NSString localizedStringWithFormat:@"On"];
        }
        
        return cell;
    }
    
    if (indexPath.section == 4 && indexPath.row < 3) {
        static NSString *cellIdentifier = @"credits.cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Matchstic";
                cell.detailTextLabel.text = @"Developer";
                cell.imageView.image = [UIImage imageNamed:@"author"];
                break;
                
            case 1:
                cell.textLabel.text =  @"Aesign";
                cell.detailTextLabel.text = @"Designer";
                cell.imageView.image = [UIImage imageNamed:@"designer"];
                break;
                
            case 2:
                cell.textLabel.text =  @"nitoTV";
                cell.detailTextLabel.text = @"tvOS Developer";
                cell.imageView.image = [UIImage imageNamed:@"nito"];
                break;
                
            default:
                break;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else {
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
        // Tint the cell if needed!
        if (represented.cellType == PSButtonCell)
            cell.textLabel.textColor = [UIApplication sharedApplication].delegate.window.tintColor;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 4 && indexPath.row < 2 ? 120.0 : UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4 && indexPath.row < 2) {
        // handle credits tap.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self _openTwitterForUser:indexPath.row == 0 ? @"_Matchstic" : @"aesign_"];
    } else {
        if (![self _handleFakeSwitchForIndexPath:indexPath])
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)_handleFakeSwitchForIndexPath:(NSIndexPath*)indexPath {
    PSSpecifier *specifier = [self _specifierAtIndexPath:indexPath];
    
    if ([[specifier propertyForKey:@"cellClass"] isEqual:NSClassFromString(@"PSSubtitleDisclosureTableCell")]) {
        int currentValue = [[self readPreferenceValue:specifier] intValue];
        currentValue = currentValue == 0 ? 1 : 0;
        
        [self setPreferenceValue:[NSNumber numberWithBool:currentValue] specifier:specifier];
        [self reloadSpecifier:specifier];
        
        return YES;
    } else {
        return NO;
    }
}

- (PSSpecifier*)_specifierAtIndexPath:(NSIndexPath*)indexPath {
    // Find the type of cell this is.
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    
    PSSpecifier *represented;
    NSArray *specifiers = [self specifiers];
    int currentSection = -1;
    int currentRow = 0;
    for (int i = 0; i < specifiers.count; i++) {
        PSSpecifier *spec = [specifiers objectAtIndex:i];
        
        // Update current sections
        if (spec.cellType == PSGroupCell) {
            currentSection++;
            currentRow = 0;
            continue;
        }
        
        // Check if this is the right specifier.
        if (currentRow == row && currentSection == section) {
            represented = spec;
            break;
        } else {
            currentRow++;
        }
    }
    
    return represented;
}

- (void)updateSpecifiersForAppleID:(NSString*)username {
    BOOL hasCachedUser = [RPVResources getUsername] != nil;
    
    if (hasCachedUser == _hasCachedUser) {
        // Do nothing.
        return;
    }
    
    _hasCachedUser = hasCachedUser;
    
    // Update "Apple ID: XXX"
    NSString *title = [NSString stringWithFormat:@"Apple ID: %@", username];
    [_loggedInSpec setName:title];
    [_loggedInSpec setProperty:title forKey:@"label"];
    
    if (hasCachedUser) {
        [self removeContiguousSpecifiers:_loggedOutAppleSpecifiers animated:YES];
        [self insertContiguousSpecifiers:_loggedInAppleSpecifiers atIndex:0];
    } else {
        [self removeContiguousSpecifiers:_loggedInAppleSpecifiers animated:YES];
        [self insertContiguousSpecifiers:_loggedOutAppleSpecifiers atIndex:0];
    }
}

- (void)didClickSignOut:(id)sender {
    [RPVResources userDidRequestAccountSignOut];
    
    [self updateSpecifiersForAppleID:@""];
}

- (void)didClickSignIn:(id)sender {
    [RPVResources userDidRequestAccountSignIn];
}

- (void)_openTwitterForUser:(NSString*)username {
    UIApplication *app = [UIApplication sharedApplication];
    
    NSURL *twitterapp = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:///user?screen_name=%@", username]];
    NSURL *tweetbot = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", username]];
    NSURL *twitterweb = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", username]];
    
    
    if ([app canOpenURL:twitterapp])
        [app openURL:twitterapp];
    else if ([app canOpenURL:tweetbot])
        [app openURL:tweetbot];
    else
        [app openURL:twitterweb];
}

- (id)readPreferenceValue:(PSSpecifier*)value {
    NSString *key = [value propertyForKey:@"key"];
    id val = [RPVResources preferenceValueForKey:key];
    
    if (!val) {
        // Defaults.
        
        if ([key isEqualToString:@"thresholdForResigning"]) {
            return [NSNumber numberWithInt:2];
        } else if ([key isEqualToString:@"showDebugAlerts"]) {
            return [NSNumber numberWithBool:NO];
        } else if ([key isEqualToString:@"showNonUrgentAlerts"]) {
            return [NSNumber numberWithBool:NO];
        } else if ([key isEqualToString:@"resign"]) {
            return [NSNumber numberWithBool:YES];
        }
        
        return nil;
    } else {
        return val;
    }
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSString *notification = specifier.properties[@"PostNotification"];
    
    [RPVResources setPreferenceValue:value forKey:key withNotification:notification];
}

@end
