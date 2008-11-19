//
//  RailsGitXController.m
//  RailsGitX
//
//  Created by Robert Walker on 11/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RailsGitXController.h"

#define RAILS_GIT_COMMAND @"/usr/local/bin/rails-git"
#define RSPEC_ARG @"--rspec"
#define AUTH_ARG @"--auth"
#define DB_ARG @"--database="
#define MyCustomErrorDomain @"com.robertwalker.ErrorDomain"
#define CreatingRailsProjString NSLocalizedString(@"Creating Git version controlled Ruby on Rails project...\n", @"")
#define CompletedProjString NSLocalizedString(@"Completed successfully...\n", @"")

const NSInteger MyCustomErrorCode = 1;
const CGFloat ADDITIONS_HEIGHT = 242.0;

@interface RailsGitXController(Private)

- (void)uiEnabled:(BOOL)flag;
- (void)appendToTextView:(NSTextView *)textView withString:(NSString *)aString;

@end

@implementation RailsGitXController

- (void)awakeFromNib
{
    [stdoutTextView setContinuousSpellCheckingEnabled:NO];
    NSString *lastNAVFolder = [[NSUserDefaults standardUserDefaults] 
                               valueForKey:@"NSNavLastCurrentDirectory"];
    if (lastNAVFolder) {
        [pathLabel setStringValue:lastNAVFolder];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readTaskData:)
                                                 name:@"NSFileHandleDataAvailableNotification"
                                               object:nil];
}

#pragma mark -
#pragma mark Handle file notifications

- (void)readTaskData:(NSNotification *)notification
{
    NSFileHandle *readHandle = [notification object];
    NSData *inData = [readHandle readDataToEndOfFile];
    NSString *log = [[NSString alloc] initWithBytes:[inData bytes] 
                                             length:[inData length] 
                                           encoding:NSASCIIStringEncoding];
    
    [self appendToTextView:stdoutTextView withString:log];
    
    if ([inData length]) {
        [readHandle waitForDataInBackgroundAndNotify];
    }
    else {
        // We've read all the data so log it and enable the UI
        [self appendToTextView:stdoutTextView withString:CompletedProjString];
        
        [progressIndicator stopAnimation:self];
        [self uiEnabled:YES];
    }
}

#pragma mark -

- (void)uiEnabled:(BOOL)flag
{
    [setPathButton setEnabled:flag];
    [resetButton setEnabled:flag];
    [createProjectButton setEnabled:flag];
}

- (void)appendToTextView:(NSTextView *)textView withString:(NSString *)aString
{
    NSRange range = NSMakeRange([[textView textStorage] length], 0);
    [textView replaceCharactersInRange:range withString:aString];
    [stdoutTextView scrollRangeToVisible:range];
}

- (IBAction)setFolderPath:(id)sender
{
    int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseFiles:NO];
    [oPanel setCanChooseDirectories:YES];
    result = [oPanel runModalForDirectory:nil file:nil types:nil];
    if (result == NSOKButton) {
        NSString *fileToOpen = [[oPanel filenames] objectAtIndex:0];
        [pathLabel setStringValue:fileToOpen];
    }
}

- (IBAction)resetUI:(id)sender
{
    NSRange range;
    NSString *lastNAVFolder = [[NSUserDefaults standardUserDefaults] 
                               valueForKey:@"NSNavLastCurrentDirectory"];
    if (!lastNAVFolder) lastNAVFolder = @"~/Desktop";
    [pathLabel setStringValue:lastNAVFolder];
    [projectNameTextField setStringValue:@""];
    [rspecCheckbox setState:NSOffState];
    [authCheckbox setState:NSOffState];
    [dbServerComboBox setStringValue:@"sqlite3"];
    range = NSMakeRange(0, [[stdoutTextView textStorage] length]);
    [stdoutTextView replaceCharactersInRange:range withString:@""];
}

- (IBAction)executeCommand:(id)sender
{
    NSTask *aTask = [[NSTask alloc] init];
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    NSString *sourceFolderPath = [[pathLabel stringValue] stringByExpandingTildeInPath];
    NSString *fullPath = [sourceFolderPath stringByAppendingPathComponent:[projectNameTextField stringValue]];
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:1];
    
    // Disable the UI until we're finished
    [self uiEnabled:NO];

    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath] == NO &&
        [[[projectNameTextField stringValue] 
          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [progressIndicator startAnimation:self];
        
        [args addObject:fullPath];
        if (![[dbServerComboBox stringValue] isEqualToString:@"sqlite3"])
            [args addObject:[DB_ARG stringByAppendingString:[dbServerComboBox stringValue]]];
        if ([rspecCheckbox state] == NSOnState)
            [args addObject:RSPEC_ARG];
        if ([authCheckbox state] == NSOnState)
            [args addObject:AUTH_ARG];
        
        if ([sourceFolderPath length] > 0 && [[projectNameTextField stringValue] length] > 0) {
            [aTask setLaunchPath:RAILS_GIT_COMMAND];
            [aTask setArguments:args];
            [aTask setStandardOutput:newPipe];
            
            [self appendToTextView:stdoutTextView withString:CreatingRailsProjString];
            
            [aTask launch];
            [readHandle waitForDataInBackgroundAndNotify];
        }
    }
    else {
        // TODO: Find out how to handle presenting the error to the user
        NSLog(@"Some error occurred we need to deal with...");
        
        [self uiEnabled:YES];
    }
    
    [aTask release];
}

- (IBAction)toggleOutputLogView:(id)sender;
{
    NSRect frame = [window frame];
    
    if ([stdoutDisclosureButton state] == NSOnState) {
        frame.size.height += ADDITIONS_HEIGHT;
        frame.origin.y -= ADDITIONS_HEIGHT;
    }
    else {
        frame.size.height -= ADDITIONS_HEIGHT;
        frame.origin.y += ADDITIONS_HEIGHT;
    }
    
    [window setFrame:frame display:YES animate:YES];
}

@end
