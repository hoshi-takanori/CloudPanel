//
//  CloudDocument.m
//  CloudPanel
//
//  Created by Hoshi Takanori on 12/02/01.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "CloudDocument.h"
#import "CloudPanelController.h"

@interface CloudDocument ()

@property (nonatomic, retain) NSString *text;

@end

@implementation CloudDocument

@synthesize textView;
@synthesize text;

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSString *)windowNibName
{
    return @"CloudDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];

    if (text != nil) {
        textView.string = text;
    }
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [textView.string dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    self.text = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if (textView != nil) {
        textView.string = text;
    }
    return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(saveToCloudAs:)) {
        return (self.fileURL == nil);
    }
    return [super validateMenuItem:menuItem];
}

- (IBAction)saveToCloudAs:(id)sender
{
    [CloudSaveController openPanelFor:[self.windowControllers objectAtIndex:0]];
}

- (void)dealloc
{
    [textView release];
    [text release];
    [super dealloc];
}

@end
