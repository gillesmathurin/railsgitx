//
//  RailsGitXController.h
//  RailsGitX
//
//  Created by Robert Walker on 11/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RailsGitXController : NSObject {
    IBOutlet NSWindow *window;
    IBOutlet NSTextField *pathLabel;
    IBOutlet NSTextField *projectNameTextField;
    IBOutlet NSScrollView *stdoutScrollView;
    IBOutlet NSTextView *stdoutTextView;
    IBOutlet NSProgressIndicator *progressIndicator;
    
    IBOutlet NSButton *rspecCheckbox;
    IBOutlet NSButton *authCheckbox;
    IBOutlet NSComboBox *dbServerComboBox;
    IBOutlet NSButton *setPathButton;
    IBOutlet NSButton *resetButton;
    IBOutlet NSButton *createProjectButton;
    IBOutlet NSButton *stdoutDisclosureButton;
}

- (IBAction)setFolderPath:(id)sender;
- (IBAction)resetUI:(id)sender;
- (IBAction)executeCommand:(id)sender;
- (IBAction)toggleOutputLogView:(id)sender;

@end
