//
//  CloudPanelController.h
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

#import <Foundation/Foundation.h>

@interface CloudPanelController : NSObject {
    NSPanel *panel;
    NSButton *okButton;
}

@property (nonatomic, retain) IBOutlet NSPanel *panel;
@property (nonatomic, retain) IBOutlet NSButton *okButton;

+ (BOOL)isCloudAvailable;

@end

@interface CloudOpenController : CloudPanelController <NSTableViewDataSource, NSTableViewDelegate> {
    NSTableView *tableView;
    NSButton *removeButton;

    NSMetadataQuery *query;
    NSMutableArray *items;
}

@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet NSButton *removeButton;

+ (void)openPanel;

- (IBAction)handleOK:(id)sender;
- (IBAction)handleCancel:(id)sender;
- (IBAction)handleRemove:(id)sender;

@end

@interface CloudSaveController : CloudPanelController <NSTextFieldDelegate> {
    NSTextField *textField;
    NSWindowController *windowController;
}

@property (nonatomic, retain) IBOutlet NSTextField *textField;

+ (void)openPanelFor:(NSWindowController *)windowController;

- (IBAction)handleOK:(id)sender;
- (IBAction)handleCancel:(id)sender;

@end
