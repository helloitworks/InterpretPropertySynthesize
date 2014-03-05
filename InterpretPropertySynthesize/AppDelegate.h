//
//  AppDelegate.h
//  InterpretPropertySynthesize
//
//  Created by Shen Yixin on 13-12-30.
//  Copyright (c) 2013年 Shen Yixin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *memberTextView;
@property (unsafe_unretained) IBOutlet NSTextView *propertyTextView;
@property (unsafe_unretained) IBOutlet NSTextView *synthesizeTextView;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionTextView;

- (IBAction)btnInterpretClicked:(id)sender;

@end
