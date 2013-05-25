//
//  OUAppDelegate.h
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/25/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface OUAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet WebView *webView;
@property (assign) IBOutlet NSSplitView *splitView;
@property (nonatomic, retain) IBOutlet WebView *outputWebView;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)execute:(id)sender;
- (IBAction)toggleOutput:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
