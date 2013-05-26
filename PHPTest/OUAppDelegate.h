//
//  OUAppDelegate.h
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/25/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "OUTaskAsync.h"
#import "OUProfileTableDataSource.h"

@interface OUAppDelegate : NSObject <NSApplicationDelegate>{
    OUTaskAsync *taskAsync;
    BOOL isRunning;
    OUProfileTableDataSource *profileTableDataSource;
}

@property (assign) IBOutlet NSTableView *profileTable;
@property (assign) IBOutlet NSPopUpButton *profileCombobox;

@property (assign) IBOutlet NSToolbar *toolbar;

@property (assign) IBOutlet NSTextField *statusText;
@property (assign) IBOutlet NSView *statusBar;

@property (assign) IBOutlet NSToolbarItem *runButton;
@property (assign) IBOutlet NSToolbarItem *stopButton;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *settingsWindow;
@property (assign) IBOutlet NSWindow *profileWindow;

@property (assign) IBOutlet NSSplitView *splitView;
@property (nonatomic, retain) IBOutlet WebView *webView;
@property (nonatomic, retain) IBOutlet WebView *outputWebView;

@property (assign) IBOutlet NSTextField *profileWindowPath;
@property (assign) IBOutlet NSTextField *profileWindowName;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)execute:(id)sender;
- (IBAction)terminate:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)showSettings:(id)sender;

- (void)dataAvailable:(NSNotification *)notification;
- (void)taskTerminated:(NSNotification *)notification;
- (void)reloadProfileCombobox;

// Settings
- (IBAction)segControlClicked:(id)sender;
- (IBAction)hideSettings:(id)sender;
- (IBAction)hideProfile:(id)sender;
- (IBAction)newProfile:(id)sender;
- (IBAction)openPhpBinPath:(id)sender;

@end
