//
//  CloudAppDelegate.h
//  CloudPanel
//
//  Created by Hoshi Takanori on 12/02/01.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudAppDelegate : NSObject <NSApplicationDelegate> {
    NSMenu *fileMenu;
}

@property (nonatomic, retain) IBOutlet NSMenu *fileMenu;

- (IBAction)openFromCloud:(id)sender;

@end
