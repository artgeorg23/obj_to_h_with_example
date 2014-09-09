//
//  AppDelegate.h
//  obj->h
//
//  Created by artur on 09.09.14.
//  Copyright (c) 2014 Artur. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextView *tv;
    
@private
	NSAttributedString* _attributedString;
    NSString *strr;
    NSURL *lll;
    NSMutableArray*linesOfText1;
    NSMutableString * s2;
    NSMutableString * s;
    
    
    int vn,vt;


}



@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;


@property (copy) NSAttributedString *attributedString;


- (IBAction)writeUsingSavePanel:(id)sender;

- (IBAction)readUsingOpenPanel:(id)sender ;
- (IBAction)obj_to_h:(id)sender;




@end
