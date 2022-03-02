//
//  LSLogViewer.h
//  LSLogViewer
//
//  Created by Leszek S on 04.09.2015.
//  Copyright (c) 2015 Leszek S. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LSLog(fmt, ...) LSLogf((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

void LSLogf(NSString *format, ...);
void LSLogl(NSString *line);

@interface LSLogViewer : UIViewController

+ (void)showViewer;

+ (void)hideViewer;

+ (void)registerThreeFingerTripleTapGesture;

@end
