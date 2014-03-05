//
//  AppDelegate.m
//  InterpretPropertySynthesize
//
//  Created by Shen Yixin on 13-12-30.
//  Copyright (c) 2013年 Shen Yixin. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
}

/*
 uint32 status;
 NSString *_message;
 uint64 _taskId;
 NSString *_url;
 NSString *_taskName;
 NSString *_cid;
 NSString *_gcid;
 uint64 _fileSize;
 uint32 _fileType;
 uint32_t _downloadStatus;
 uint32_t _progress;
 NSString *_lixianUrl;
 */

- (IBAction)btnInterpretClicked:(id)sender
{
    NSString *memberText = self.memberTextView.string;
    NSLog(@"memberText = %@",memberText);
    NSArray *memberItems = [memberText componentsSeparatedByString:@"\n"];
    __block NSString *propertyStr = [[NSString alloc] init];
    __block NSString *synthesizeStr  = [[NSString alloc] init];
    __block NSString *descriptionStr  = [[NSString alloc] init];
    descriptionStr = [descriptionStr stringByAppendingString:@"- (NSString *)description\n"];
    descriptionStr = [descriptionStr stringByAppendingString:@"{\n"];
    descriptionStr = [descriptionStr stringByAppendingString:@"NSString *str = [[[NSString alloc] init] autorelease];\n"];
    descriptionStr = [descriptionStr stringByAppendingString:@"str = [str stringByAppendingFormat:@\"\\n[\\n\"];\n"];

    [memberItems enumerateObjectsUsingBlock:^(NSString *memberLine, NSUInteger idx, BOOL *stop)
    {

        memberLine = [memberLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
       
        //todo:采用有限状态机。去掉单行跟多行注释。
        if ([memberLine rangeOfString:@"//"].location == 0) {
            return;
        }
        
        //ignore interface
        if ([memberLine rangeOfString:@"@interface"].location != NSNotFound) {
            return;
        }
        
        BOOL hasStar = [memberLine rangeOfString:@"*"].location != NSNotFound;
        BOOL hasUnderline = [memberLine rangeOfString:@"_"].location != NSNotFound;
        memberLine = [memberLine stringByReplacingOccurrencesOfString:@"*" withString:@""];
        memberLine = [memberLine stringByReplacingOccurrencesOfString:@"_" withString:@""];
        
        //处理行尾有注释的情况。NSMutableArray *taskList;//array of LXNewBTCommitRespTaskInfo
        if([memberLine rangeOfString:@";"].location != NSNotFound)
        {
            memberLine = [memberLine substringToIndex:[memberLine rangeOfString:@";"].location];
        }
        
        //--generate property string
        NSArray *identifiers = [memberLine componentsSeparatedByString:@" "];
        if (identifiers.count < 2) {
            return;
        }
        NSString *keyWord = [identifiers objectAtIndex:0];
        NSString *var = [identifiers objectAtIndex:1];

        if (hasStar)
        {
            if ([keyWord rangeOfString:@"NSString"].location != NSNotFound)
            {
                propertyStr = [propertyStr stringByAppendingFormat:@"@property (copy) %@ *%@;\n", keyWord, var];

            }
            else
            {
                propertyStr = [propertyStr stringByAppendingFormat:@"@property (retain) %@ *%@;\n", keyWord, var];
            }
        }
        else
        {
            propertyStr = [propertyStr stringByAppendingFormat:@"@property (assign) %@ %@;\n", keyWord, var];
        }
        
        //--generate synthesize string
        //todo:不能仅仅判断有下划线，就对要synthesize的成员变量加下划线。比如这种情况 NSString *user_name。
        synthesizeStr = [synthesizeStr stringByAppendingFormat:@"@synthesize %@ = %@%@;\n", var,hasUnderline ? @"_":@"", var];
        NSString *formatType = nil;

        if ([keyWord isEqualToString:@"int"] || [keyWord isEqualToString:@"int32"])
        {
            formatType = @"%d";
        }
        else if ([keyWord isEqualToString:@"unsigned int"])
        {
            formatType = @"%hh";
        }
        else if ([keyWord isEqualToString:@"uint8"])
        {
            formatType = @"%hhu";
        }
        else if ([keyWord isEqualToString:@"uint16"])
        {
            formatType = @"%hu";
        }
        else if ([keyWord isEqualToString:@"uint32"])
        {
            formatType = @"%u";
        }
        else if ([keyWord isEqualToString:@"uint64"])
        {
            formatType = @"%llu";
        }
        else if ([keyWord isEqualToString:@"char"])
        {
            formatType = @"%c";
        }
        else if ([keyWord isEqualToString:@"long"])
        {
            formatType = @"%ld";
        }
        else if ([keyWord isEqualToString:@"float"])
        {
            formatType = @"%f";
        }
        else if ([keyWord isEqualToString:@"double"])
        {
            formatType = @"%f";
        }
        else
        {
            formatType = @"%@";
        }
        
        descriptionStr = [descriptionStr stringByAppendingFormat:@"\tstr = [str stringByAppendingFormat:@\"%@ = %@\\n\",self.%@];\n",var,formatType,var];

    }];
    
    //--generate description string
    descriptionStr = [descriptionStr stringByAppendingString:@"str = [str stringByAppendingFormat:@\"]\"];\n"];
    descriptionStr = [descriptionStr stringByAppendingFormat:@"return str;\n"];
    descriptionStr = [descriptionStr stringByAppendingString:@"}\n"];

    self.propertyTextView.string = propertyStr;
    self.synthesizeTextView.string = synthesizeStr;
    self.descriptionTextView.string = descriptionStr;
}
@end
