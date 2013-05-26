//
//  OUAppDelegate.m
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/25/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import "OUAppDelegate.h"
#import "OUTaskAsync.h"
#import "OUProfileTableDataSource.h"

@implementation OUAppDelegate

@synthesize profileWindow;
@synthesize profileTable;
@synthesize settingsWindow;
@synthesize profileCombobox;
@synthesize toolbar;
@synthesize statusText;
@synthesize statusBar;
@synthesize runButton;
@synthesize stopButton;
@synthesize webView;
@synthesize splitView;
@synthesize outputWebView;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    isRunning = NO;

    taskAsync = [[OUTaskAsync alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) name:OUTaskAsyncDataAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) name:OUTaskAsyncTaskTerminatedNotification object:nil];

    profileTableDataSource = [[OUProfileTableDataSource alloc] init:[self managedObjectContext]];
    [profileTable setDataSource:profileTableDataSource];
    [self reloadProfileCombobox];
}

- (void)reloadProfileCombobox{
    [profileCombobox removeAllItems];

    for(NSString *info in [profileTableDataSource getItems])
        [profileCombobox addItemWithTitle:info];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem{
    BOOL enable = YES;

    if ([[theItem itemIdentifier] isEqualToString:@"run"]){
        enable = isRunning ? NO : YES;
    }else if([[theItem itemIdentifier] isEqualToString:@"stop"]){
        enable = isRunning ? YES : NO;
    }

    return enable;
}

- (void)dealloc{
    [taskAsync stop];
}

- (void)awakeFromNib{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcePath stringByAppendingString:@"/index.html"];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];

    [[outputWebView preferences] setDefaultFontSize:15];
    [[outputWebView preferences] setStandardFontFamily:@"Lucida Grande"];
}

- (void)execute:(id)sender{
    if ([profileTableDataSource hasItem] == NO)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please add a profile."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [self showSettings:nil];
        return;
    }

    NSManagedObject *profile = [profileTableDataSource getItem:[[profileCombobox selectedItem] title]];
    if (profile == nil)
    {
        return;
    }

    isRunning = YES;
    [toolbar validateVisibleItems];
    [statusText setStringValue:@"Running..."];
    [splitView setPosition:splitView.bounds.size.height/2 ofDividerAtIndex:0];

    NSString *response = [webView stringByEvaluatingJavaScriptFromString:@"getContent();"];

    NSString *sourceFilePath = @"/tmp/php_test_source_code.php";
    [response writeToFile:sourceFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];

    if (response == nil)
    {
        [runButton setEnabled:YES];
        [stopButton setEnabled:NO];
        return;
    }

    [taskAsync launch:[profile valueForKey:@"bin"] properties:[[NSArray alloc] initWithObjects:@"-d", @"display_errors=stderr", @"-d", @"html_errors=1", @"-f", sourceFilePath, nil]];
}

- (void)terminate:(id)sender{
    [statusText setStringValue:[NSString stringWithFormat:@"Run completed in %f second", [taskAsync getCompletedTime]]];
    [taskAsync stop];
    isRunning = NO;
    [toolbar validateVisibleItems];
}

- (void)dataAvailable:(NSNotification *)notification{
    NSMutableString *content = (NSMutableString *)[notification object];
    [[outputWebView mainFrame] loadHTMLString:content baseURL:nil];
}

- (void)taskTerminated:(NSNotification *)notification{
    [statusText setStringValue:[NSString stringWithFormat:@"Run completed in %f second", [taskAsync getCompletedTime]]];
    isRunning = NO;
    [toolbar validateVisibleItems];
}

- (void)showSettings:(id)sender{
    [profileTable reloadData];
    [NSApp beginSheet:settingsWindow modalForWindow:_window modalDelegate:self didEndSelector:@selector(didEndSettings:returnCode:contextInfo:) contextInfo:nil];
}

- (void)hideSettings:(id)sender{
    [NSApp endSheet:settingsWindow];
}

- (void)hideProfile:(id)sender{
    [NSApp endSheet:profileWindow];
}

- (void)didEndSettings:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:self];
}

- (void)didEndProfile:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:settingsWindow];
}

- (IBAction)segControlClicked:(id)sender{
    NSInteger clickedSegment = [sender selectedSegment];
    NSInteger selectedRow = [profileTable selectedRow];

    if (clickedSegment == 0)
    {
        // Add
        [NSApp beginSheet:profileWindow modalForWindow:settingsWindow modalDelegate:self didEndSelector:@selector(didEndProfile:returnCode:contextInfo:) contextInfo:nil];
    }else if(clickedSegment == 1){
        // Edit
        if (selectedRow == -1){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Please select at least one profile."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }else if(clickedSegment == 2){
        // Remove
        NSAlert *alert = [[NSAlert alloc] init];
        if (selectedRow == -1){
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Please select at least one profile."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }else{
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            [alert setMessageText:@"Selected profile will be deleted immediately. Are you sure?"];
            [alert setAlertStyle:NSWarningAlertStyle];

            if ([alert runModal] == NSAlertFirstButtonReturn)
            {
                [profileTableDataSource remove:selectedRow];
                [profileTable reloadData];
                [self reloadProfileCombobox];
            }
        }
    }
}

- (IBAction)newProfile:(id)sender{
    if ([[_profileWindowName stringValue] length] == 0)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please input a profile name."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }else{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        if ([fileManager isExecutableFileAtPath:[_profileWindowPath stringValue]])
        {
            [profileTableDataSource create:[_profileWindowName stringValue] version:@"" bin:[_profileWindowPath stringValue]];
            [profileTable reloadData];
            [self reloadProfileCombobox];
            [NSApp endSheet:profileWindow];
        }else{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Please select a executable file."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }
}

- (IBAction)openPhpBinPath:(id)sender{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanCreateDirectories:NO];
    [openDlg setShowsHiddenFiles:YES];

    if ([openDlg runModal] == NSOKButton)
    {
        NSURL *filename = [openDlg URL];
        NSFileManager *fileManager = [[NSFileManager alloc] init];

        if ([fileManager isExecutableFileAtPath:[filename path]])
        {
            [_profileWindowPath setStringValue:[filename path]];
        }else{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Please select a executable file."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.omerucel.PHPTest" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.omerucel.PHPTest"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Model.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
