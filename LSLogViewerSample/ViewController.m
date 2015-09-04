//
//  ViewController.m
//  LSLogViewerSample
//
//  Created by Leszek S on 04.09.2015.
//  Copyright (c) 2015 Leszek S. All rights reserved.
//

#import "ViewController.h"
#import "LSLogViewer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"This is a log from sample application!");
    NSLog(@"Have a nice day!");
}

- (IBAction)showLogsAction:(id)sender
{
    NSLog(@"Show logs!");
    
    [LSLogViewer showViewer];
}

@end
