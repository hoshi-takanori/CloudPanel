//
//  CloudPanelController.h
//  CloudPanel
//
//  Created by Hoshi Takanori on 12/02/01.
//  Copyright (c) 2012 -. All rights reserved.
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
