//
//  CloudDocument.m
//  CloudPanel
//
//  Copyright (c) 2012 Hoshi Takanori
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

    if ([self respondsToSelector:@selector(isInViewingMode)] && self.isInViewingMode) {
        textView.editable = NO;
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

- (void)windowWillEnterVersionBrowser:(NSNotification *)notification
{
    textView.editable = NO;
}

- (void)windowDidExitVersionBrowser:(NSNotification *)notification
{
    textView.editable = YES;
}

- (void)dealloc
{
    [textView release];
    [text release];
    [super dealloc];
}

@end
