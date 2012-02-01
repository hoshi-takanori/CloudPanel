//
//  CloudPanelController.m
//  CloudPanel
//
//  Created by Hoshi Takanori on 12/02/01.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "CloudPanelController.h"

#define EXT_TXT  @"txt"

#define DOC_DIR  @"Documents"
#define DOC_TYPE @"DocumentType"

@implementation CloudPanelController

@synthesize panel;
@synthesize okButton;

+ (BOOL)isCloudAvailable
{
    return [[NSFileManager defaultManager] respondsToSelector:@selector(URLForUbiquityContainerIdentifier:)] &&
           [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] != nil;
}

- (id)initWithNibNamed:(NSString *)nibName
{
    self = [super init];
    if (self != nil) {
        if ([NSBundle loadNibNamed:nibName owner:self]) {
            [panel release];
        }
    }
    return self;
}

- (void)dealloc
{
    [panel release];
    [okButton release];
    [super dealloc];
}

@end

@interface CloudOpenController ()

@property (nonatomic, retain) NSMutableArray *items;

- (void)show;

@end

@implementation CloudOpenController

@synthesize tableView;
@synthesize removeButton;
@synthesize items;

static CloudOpenController *sharedController;

+ (void)openPanel
{
    if (sharedController == nil) {
        sharedController = [[CloudOpenController alloc] initWithNibNamed:@"CloudOpenPanel"];
        sharedController.tableView.target = sharedController;
        sharedController.tableView.doubleAction = @selector(handleOK:);
    }

    [sharedController show];
}

- (void)show
{
    if (query == nil) {
        query = [[NSMetadataQuery alloc] init];
        query.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
        NSString *format = [NSString stringWithFormat:@"%%K like '*.%@'", EXT_TXT];
        query.predicate = [NSPredicate predicateWithFormat:format, NSMetadataItemFSNameKey];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateQueryResult:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateQueryResult:)
                                                     name:NSMetadataQueryDidUpdateNotification
                                                   object:nil];
    }

    if (! query.isStarted || query.isStopped) {
        self.items = nil;
        [tableView reloadData];
        [self tableViewSelectionDidChange:nil];

        [query startQuery];
    }

    [self.panel makeKeyAndOrderFront:nil];
}

- (void)dismiss
{
    [query stopQuery];
    [self.panel orderOut:nil];
}

static NSString *get_name(id obj)
{
    if ([obj isKindOfClass:[NSURL class]]) {
        obj = [obj path];
    }
    return [[obj lastPathComponent] stringByDeletingPathExtension];
}

static NSInteger compare(id obj1, id obj2, void *context)
{
    NSString *str1 = get_name(obj1);
    NSString *str2 = get_name(obj2);
    if ([str1 respondsToSelector:@selector(localizedStandardCompare:)]) {
        return [str1 localizedStandardCompare:str2];
    } else {
        return [str1 compare:str2
                     options:NSCaseInsensitiveSearch | NSNumericSearch | NSForcedOrderingSearch
                       range:NSMakeRange(0, str1.length)
                      locale:[NSLocale currentLocale]];
    }
}

- (void)updateQueryResult:(NSNotification *)notification
{
    [query disableUpdates];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSMetadataItem *item in query.results) {
        [array addObject:[item valueForAttribute:NSMetadataItemURLKey]];
    }
    [array sortUsingFunction:compare context:NULL];
    if (! [items isEqualToArray:array]) {
        [tableView deselectAll:nil];
        self.items = array;
        [tableView reloadData];
    }
    [array release];

    [query enableUpdates];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return items.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return get_name([items objectAtIndex:row]);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    self.okButton.enabled = (tableView.selectedRow >= 0);
    removeButton.enabled = (tableView.selectedRow >= 0);
}

- (IBAction)handleOK:(id)sender
{
    if (tableView.selectedRow >= 0) {
        NSURL *url = [items objectAtIndex:tableView.selectedRow];
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES error:NULL];
        [self dismiss];
    }
}

- (IBAction)handleCancel:(id)sender
{
    [self dismiss];
}

- (IBAction)handleRemove:(id)sender
{
    if (tableView.selectedRow >= 0) {
        NSURL *url = [[items objectAtIndex:tableView.selectedRow] retain];
        NSString *message = [NSString stringWithFormat:@"Are you sure to remove \"%@\"?", get_name(url)];
        NSAlert *alert = [NSAlert alertWithMessageText:message
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:@"Cancel"
                             informativeTextWithFormat:@"It will be removed from all your devices parmanently."];
        [alert beginSheetModalForWindow:self.panel
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:url];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSURL *url = (NSURL *) contextInfo;

    if (returnCode == NSAlertDefaultReturn) {
        [tableView deselectAll:nil];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:NULL byAccessor:^(NSURL *newURL) {
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                [fileManager removeItemAtURL:newURL error:NULL];
                [fileManager release];
            }];
            [coordinator release];
        });
    }

    [url release];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [tableView release];
    [removeButton release];
    [items release];
    [query release];
    [super dealloc];
}

@end

@interface CloudSaveController ()

@property (nonatomic, retain) NSWindowController *windowController;

#if __has_feature(attribute_ns_consumes_self)
- (void)show __attribute__((ns_consumes_self));
#else
- (void)show;
#endif

@end

@implementation CloudSaveController

@synthesize textField;
@synthesize windowController;

+ (void)openPanelFor:(NSWindowController *)windowController
{
    CloudSaveController *saveController = [[CloudSaveController alloc] initWithNibNamed:@"CloudSavePanel"];
    saveController.okButton.enabled = NO;
    saveController.windowController = windowController;

    [saveController show];
}

- (void)show
{
    [NSApp beginSheet:self.panel
       modalForWindow:windowController.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (NSString *)filename
{
    NSString *filename = textField.stringValue;
    filename = [filename stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    filename = [filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return filename;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    self.okButton.enabled = (self.filename.length > 0);
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton) {
        NSString *filename = self.filename;
        NSURL *url = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        url = [[url URLByAppendingPathComponent:DOC_DIR] URLByAppendingPathComponent:filename];

        NSString *ext = [filename pathExtension];
        if (! [ext isEqualToString:EXT_TXT]) {
            url = [url URLByAppendingPathExtension:EXT_TXT];
        }

        if ([[NSFileManager defaultManager] isUbiquitousItemAtURL:url]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"File already exists in the cloud."
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:@"Cancel"
                                 informativeTextWithFormat:@"Are you sure to overwrite \"%@\"?", filename];
            [alert beginSheetModalForWindow:self.panel
                              modalDelegate:self
                             didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:[url retain]];
            return;
        } else {
            [windowController.document saveToURL:url ofType:DOC_TYPE forSaveOperation:NSSaveAsOperation error:NULL];
        }
    }

    [self.panel orderOut:nil];
    [self release];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSURL *url = (NSURL *) contextInfo;

    if (returnCode == NSAlertDefaultReturn) {
        [windowController.document saveToURL:url ofType:DOC_TYPE forSaveOperation:NSSaveAsOperation error:NULL];
    }

    [url release];
    [self.panel orderOut:nil];
    [self release];
}

- (IBAction)handleOK:(id)sender
{
    [NSApp endSheet:self.panel returnCode:NSOKButton];
}

- (IBAction)handleCancel:(id)sender
{
    [NSApp endSheet:self.panel returnCode:NSCancelButton];
}

- (void)dealloc
{
    [textField release];
    [windowController release];
    [super dealloc];
}

@end
