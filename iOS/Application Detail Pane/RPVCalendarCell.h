//
//  RPVCalendarCell.h
//  iOS
//
//  Created by Matt Clarke on 16/07/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

#if !TARGET_OS_TV

#define CELL_WIDTH 40
#define CELL_HEIGHT 65

#else

#define CELL_WIDTH 60
#define CELL_HEIGHT 85

#endif



@interface RPVCalendarCell : UIView

- (void)setSelected:(BOOL)selected;
- (void)setDate:(NSDate*)date;

@end
