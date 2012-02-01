//
//  CloudAppDelegate.m
//  CloudPanel
//
//  Created by Hoshi Takanori on 12/02/01.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "CloudAppDelegate.h"
#import "CloudPanelController.h"

#define TAG_SEPARATOR 1000
#define TAG_OPENCLOUD 1001
#define TAG_SAVECLOUD 1002

@implementation CloudAppDelegate

@synthesize fileMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([CloudPanelController isCloudAvailable]) {
        [fileMenu itemWithTag:TAG_SEPARATOR].hidden = NO;
        [fileMenu itemWithTag:TAG_OPENCLOUD].hidden = NO;
        [fileMenu itemWithTag:TAG_SAVECLOUD].hidden = NO;
    }
}

- (IBAction)openFromCloud:(id)sender
{
    [CloudOpenController openPanel];
}

- (void)dealloc
{
    [fileMenu release];
    [super dealloc];
}

@end
