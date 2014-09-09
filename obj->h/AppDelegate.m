//
//  AppDelegate.m
//  obj->h
//
//  Created by artur on 09.09.14.
//  Copyright (c) 2014 Artur. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize attributedString = _attributedString;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    
    tv.string=@"";
    linesOfText1 = [[NSMutableArray alloc] initWithCapacity:10];
    s2=[[NSMutableString alloc] initWithCapacity:1];
    
     NSLog(@"tv.string=%@",tv.string);
    s=[[NSMutableString alloc] initWithCapacity:10];
  
  
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Gevorkyan.obj__h" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Gevorkyan.obj__h"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"obj__h" withExtension:@"momd"];
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
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"obj__h.storedata"];
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





- (void)dealloc
{
    self.attributedString = nil;
    
    
}






-(IBAction)writeUsingSavePanel:(id)sender {
    // create the string to be written
    NSString * zStr = [[NSString alloc]init];
    //  NSInteger i;
    /* for (i = 0; i < 5; i++) {
     zStr = [zStr stringByAppendingFormat:@"i=%d\n",i];
     }*/
    zStr=tv.string;
    
    
    // get the file url
    NSSavePanel * zSavePanel = [NSSavePanel savePanel];
    NSInteger zResult = [zSavePanel runModal];
    if (zResult == NSFileHandlingPanelCancelButton) {
        NSLog(@"writeUsingSavePanel cancelled");
        return;
    }
    NSURL *zUrl = [zSavePanel URL];
    
    //write
    BOOL zBoolResult = [zStr writeToURL:zUrl
                             atomically:YES
                               encoding:NSASCIIStringEncoding
                                  error:NULL];
    if (! zBoolResult) {
        NSLog(@"writeUsingSavePanel failed");
    }
}

- (IBAction)readUsingOpenPanel:(id)sender {
    // get the url of a .txt file
    NSOpenPanel * zOpenPanel = [NSOpenPanel openPanel];
    NSArray * zAryOfExtensions = [NSArray arrayWithObject:@"obj"];
    [zOpenPanel setAllowedFileTypes:zAryOfExtensions];
    NSInteger zIntResult = [zOpenPanel runModal];
    if (zIntResult == NSFileHandlingPanelCancelButton) {
        NSLog(@"readUsingOpenPanel cancelled");
        
        
        return;
    }
    NSURL *zUrl = [zOpenPanel URL];
    
    lll=zUrl;
    // read the file
    /*  NSString * zStr = [NSString stringWithContentsOfURL:zUrl
     encoding:NSASCIIStringEncoding
     error:NULL];*/
    
    NSArray   *linesOfText = [[NSString stringWithContentsOfURL:zUrl
                                                       encoding:NSUTF8StringEncoding/*NSASCIIStringEncoding*/                                                        error:NULL]
                              componentsSeparatedByString:@"\n"];
    
    [linesOfText1 removeAllObjects];
    
    
    NSMutableString *rkkk= [NSMutableString stringWithCapacity:10];
    for(int i=0;i<linesOfText.count;i++)
    {
        [rkkk appendString:[linesOfText objectAtIndex:i]];
        [rkkk appendString:@"\n"];
        [linesOfText1 addObject:[linesOfText objectAtIndex:i]];
        
    }
    
    
    
    tv.string=rkkk;
    
    
    
}
- (IBAction)obj_to_h:(id)sender
{
    int i1=0;
    vt=0;vn=0;
    
    
    NSMutableArray *vertexcoord = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *vertexcoordrez = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *vertexindex = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *vertexindex1 = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *normalcoordrez = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *normalcoord = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *normalindex1 = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *textureindex1 = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *texturecoord = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *texturecoordrez = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableString *s22 = [NSMutableString stringWithCapacity:10];
    NSMutableString *rezultstring = [NSMutableString stringWithCapacity:10];
    
    [s2 setString:@""];
    
    
    
    
    for (int oo=0;oo<linesOfText1.count;oo++)
    {
        
        
        
        if ([[linesOfText1 objectAtIndex:oo] hasPrefix:@"v "])
        {
            NSMutableString * s1=[[NSMutableString alloc] initWithCapacity:1];
            
            
            
            [s1 appendString:[linesOfText1 objectAtIndex:oo]];
            [s1 appendString:@"},"];
            
            if ([[s1 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@"v"])
            {
                
                [s1 replaceCharactersInRange:NSMakeRange(i1, 2) withString:@"{{"];
                
            }
            for(int i1=0;i1<s1.length;i1++)
            {
                if ([[s1 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@" "])
                {
                    
                    [s1 replaceCharactersInRange:NSMakeRange(i1, 1) withString:@","];
                    
                }
            }
            [s1 appendString:@" "];
            
            
            
            
            [vertexcoord addObject:s1];
            
            
            
            
        }
        
        
        if ([[linesOfText1 objectAtIndex:oo] hasPrefix:@"vn"])
        {
            vn++;
            
            NSMutableString * s1=[[NSMutableString alloc] initWithCapacity:1];
            
            
            [s1 appendString:[linesOfText1 objectAtIndex:oo]];
            
            
            if ([[s1 substringWithRange:NSMakeRange(i1, 2)] isEqualToString:@"vn"])
            {
                
                [s1 replaceCharactersInRange:NSMakeRange(i1, 2) withString:@" {"];
                
            }
            for(int i1=3;i1<s1.length;i1++)
            {
                if ([[s1 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@" "])
                {
                    
                    [s1 replaceCharactersInRange:NSMakeRange(i1, 1) withString:@","];
                    
                }
            }
            [s1 appendString:@" }"];
            
            
            
            
            [normalcoord addObject:s1];
            
            
            
            
        }
        
        
        
        if ([[linesOfText1 objectAtIndex:oo] hasPrefix:@"vt"])
        {
            vt++;
            
            NSMutableString * s1=[[NSMutableString alloc] initWithCapacity:1];
            
            
            [s1 appendString:[linesOfText1 objectAtIndex:oo]];
            
            
            if ([[s1 substringWithRange:NSMakeRange(i1, 2)] isEqualToString:@"vt"])
            {
                
                [s1 replaceCharactersInRange:NSMakeRange(i1, 2) withString:@" {"];
                
            }
            for(int i1=3;i1<s1.length;i1++)
            {
                if ([[s1 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@" "])
                {
                    
                    [s1 replaceCharactersInRange:NSMakeRange(i1, 1) withString:@","];
                    
                }
            }
            [s1 appendString:@" }},"];
            
            [texturecoord addObject:s1];
            
            
            
            
        }
        
        
        
        
        if ([[linesOfText1 objectAtIndex:oo] hasPrefix:@"f"])
        {
            
            NSLog(@"vt===%i",vt);
            
            
            if ((vt>0)&&(vn>0))
                
            {
                [s22 setString:[linesOfText1 objectAtIndex:oo]];
                [s22 deleteCharactersInRange:NSMakeRange(0, 2)];
                
                
                NSMutableString * s11=[[NSMutableString alloc] initWithCapacity:1];
                
                for (int i1=0;i1<s22.length;i1++)
                {
                    
                    
                    if (![[s22 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@"/"])
                    {
                        
                        
                        [s11 appendString:[s22 substringWithRange: NSMakeRange(i1, 1)]];
                        
                    }
                    
                    
                    else
                    {
                        [s11 appendString:@" "];
                        
                        
                    }
                    
                    
                }
                
                
                
                
                
                [s11 appendString:@" "];
                
                
                
                
                
                for (int i1=0;i1<s11.length;i1++)
                {
                    
                    
                    if (![[s11 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@" "])
                    {
                        
                        
                        [s2 appendString:[s11 substringWithRange: NSMakeRange(i1, 1)]];
                        
                    }
                    
                    
                    else
                        
                        
                    {
                        
                        NSMutableString * s3=[[NSMutableString alloc] initWithCapacity:1];
                        [s3 setString:s2 ];
                        [vertexindex addObject:s3];
                        [s2 setString:@""];
                    }
                }
            }
            
            if ((vt==0)&&(vn>0))
                
            {
                
                
                [s22 setString:[linesOfText1 objectAtIndex:oo]];
                [s22 deleteCharactersInRange:NSMakeRange(0, 2)];
                
                
                
                NSMutableString * s11=[[NSMutableString alloc] initWithCapacity:1];
                int k=0;
                for (int i1=0;i1<s22.length;i1++)
                {
                    
                    
                    if (![[s22 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@"/"])
                    {
                        
                        
                        [s11 appendString:[s22 substringWithRange: NSMakeRange(i1, 1)]];
                        
                    }
                    
                    
                    else
                    {
                        
                        
                        if (k<1)
                        {
                            k++;
                        }
                        else
                        {
                            k=0;
                            [s11 appendString:@" a "];
                        }
                        
                        
                    }
                    
                    
                }
                
                
                
                
                
                [s11 appendString:@" "];
                
                
                
                
                
                
                
                
                
                for (int i1=0;i1<s11.length;i1++)
                {
                    
                    
                    if (![[s11 substringWithRange:NSMakeRange(i1, 1)] isEqualToString:@" "])
                    {
                        
                        
                        [s2 appendString:[s11 substringWithRange: NSMakeRange(i1, 1)]];
                        
                    }
                    
                    
                    else
                        
                        
                    {
                        
                        NSMutableString * s3=[[NSMutableString alloc] initWithCapacity:1];
                        [s3 setString:s2 ];
                        [vertexindex addObject:s3];
                        [s2 setString:@""];
                    }
                }
                
                
                
            }
            
            
            
            
            
            
            
            
            
            
            
            
        }
        
        
        
        
    }
    
    
    
    if ((vt>0)&&(vn>0))
        
    {
        
        
        [rezultstring appendString:@"#import <GLKit/GLKit.h>\n"];
        [rezultstring appendString:@"struct vertexDataTextured\n"];
        [rezultstring appendString:@"{\n"];
        [rezultstring appendString:@"GLKVector3		vertex;"];
        [rezultstring appendString:@"\nGLKVector3		normal;"];
        [rezultstring appendString:@"\nGLKVector2     texCoord;\n"];
        [rezultstring appendString:@"};\n"];
        [rezultstring appendString:@"typedef struct vertexDataTextured vertexDataTextured;\n"];
        [rezultstring appendString:@"typedef vertexDataTextured* vertexDataTexturedPtr;\n"];
        [rezultstring appendString:@"static const vertexDataTextured MeshVertexDataTextured[] = {\n"];
        
        
        
        for (int i=11;i<vertexindex.count;i=i+12)
        {
            
            
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-11]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-8]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-5]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-11]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-5]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-2]];
            
            
            
            [textureindex1 addObject:[vertexindex objectAtIndex:i-10]];
            [textureindex1 addObject:[vertexindex objectAtIndex:i-7]];
            [textureindex1 addObject:[vertexindex objectAtIndex:i-4]];
            [textureindex1 addObject:[vertexindex objectAtIndex:i-10]];
            [textureindex1 addObject:[vertexindex objectAtIndex:i-4]];
            [textureindex1 addObject:[vertexindex objectAtIndex:i-1]];
            
            
            
            
            [normalindex1 addObject:[vertexindex objectAtIndex:i-9]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-6]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-3]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-9]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-3]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i]];
            
            
            
            
            
        }
        
        
        for (int i=0;i<vertexindex1.count;i++)
        {
            [  vertexcoordrez addObject:[vertexcoord objectAtIndex:[[vertexindex1 objectAtIndex:i]intValue]-1]];
        }
        
        for (int i=0;i<normalindex1.count;i++)
        {
            [  normalcoordrez addObject:[normalcoord objectAtIndex:[[normalindex1 objectAtIndex:i]intValue]-1]];
        }
        
        for (int i=0;i<textureindex1.count;i++)
        {
            [  texturecoordrez addObject:[texturecoord objectAtIndex:[[textureindex1 objectAtIndex:i]intValue]-1]];
        }
        
        
        NSMutableArray *vXn_coordrez = [[NSMutableArray alloc] initWithCapacity:10];
        
        for (int i=0;i<normalindex1.count;i++)
        {
            NSString  *filePath1 = [NSString stringWithFormat:@"%@%@%@%@", [vertexcoordrez objectAtIndex:i],[normalcoordrez objectAtIndex:i],@",",[texturecoordrez objectAtIndex:i]];
            [vXn_coordrez addObject:filePath1];
            
            
        }
        
        
        for (int e=0;e<vXn_coordrez.count;e++)
        {
            [rezultstring appendString:[vXn_coordrez objectAtIndex:e]];
            [rezultstring appendString:@"\n"];
        }
        
        
        
        [rezultstring appendString:@"};"];
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    if ((vt==0)&&(vn>0))
        
    {
        
        
        [rezultstring appendString:@"#import <GLKit/GLKit.h>\n"];
        [rezultstring appendString:@"struct vertexData \n"];
        [rezultstring appendString:@"{\n"];
        [rezultstring appendString:@"GLKVector3		vertex;"];
        [rezultstring appendString:@"\nGLKVector3		normal;"];
        [rezultstring appendString:@"};\n"];
        [rezultstring appendString:@"typedef struct vertexData vertexData;\n"];
        [rezultstring appendString:@"typedef vertexData* vertexDataPtr;\n"];
        [rezultstring appendString:@"static const vertexData  MeshVertexData[] = {\n"];
        
        
        for (int i=11;i<vertexindex.count;i=i+12)
        {
            
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-11]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-8]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-5]];
            
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-11]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-5]];
            [vertexindex1 addObject:[vertexindex objectAtIndex:i-2]];
            
            
            [normalindex1 addObject:[vertexindex objectAtIndex:i-9]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-6]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-3]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-9]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i-3]];
            [normalindex1 addObject:[vertexindex objectAtIndex:i]];
            
            
        }
        
        
        for (int i=0;i<vertexindex1.count;i++)
        {
            [  vertexcoordrez addObject:[vertexcoord objectAtIndex:[[vertexindex1 objectAtIndex:i]intValue]-1]];
            // NSLog(@"vertexindex_int=%i",[[vertexindex1 objectAtIndex:i]intValue]);
            
        }
        
        for (int i=0;i<normalindex1.count;i++)
        {
            [  normalcoordrez addObject:[normalcoord objectAtIndex:[[normalindex1 objectAtIndex:i]intValue]-1]];
            //  NSLog(@"normalindex_int=%i",[[normalindex1 objectAtIndex:i]intValue]);
            
        }
        
        
        
        
        NSMutableArray *vXn_coordrez = [[NSMutableArray alloc] initWithCapacity:10];
        
        for (int i=0;i<normalindex1.count;i++)
        {
            NSString  *filePath1 = [NSString stringWithFormat:@"%@%@%@", [vertexcoordrez objectAtIndex:i],[normalcoordrez objectAtIndex:i],@"},"];
            [vXn_coordrez addObject:filePath1];
            
            
        }
        
        for (int e=0;e<vXn_coordrez.count;e++)
        {
            [rezultstring appendString:[vXn_coordrez objectAtIndex:e]];
            [rezultstring appendString:@"\n"];
        }
        
        
        
        [rezultstring appendString:@"};"];
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    tv.string=rezultstring;
    
    
    
}





















@end
