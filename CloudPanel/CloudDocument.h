//
//  CloudDocument.h
//  CloudPanel
//
//  Created by Hoshi Takanori on 12/02/01.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CloudDocument : NSDocument <NSWindowDelegate> {
    NSTextView *textView;
    NSString *text;
}

@property (nonatomic, retain) IBOutlet NSTextView *textView;

@end
