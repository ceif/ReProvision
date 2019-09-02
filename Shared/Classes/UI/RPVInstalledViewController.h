//
//  RPVInstalledViewController.h
//  iOS
//
//  Created by Matt Clarke on 03/07/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

#if TARGET_OS_TV
#import "RPVInstalledSectionHeaderViewController.h"
#else
#import "RPVInstalledSectionHeaderView.h"
#endif

#import "RPVApplicationSigning.h"

@interface RPVInstalledViewController : UIViewController <RPVInstalledSectionHeaderDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, RPVApplicationSigningProtocol>

#if TARGET_OS_TV
- (void)disableViewAndRefocus;
#endif

@end
