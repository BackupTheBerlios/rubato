#import "JGAppKitPatches.h"
#import <Foundation/NSString.h>

@implementation NSControl (JGAppKitPatchesNSControl)
- (double)doubleValue;
{
  return [[self stringValue] doubleValue];
}
- (float)floatValue;
{
  return [[self stringValue] floatValue];
}

@end

#ifdef JG_MAC_OS_X
/* NSDocumentControllerPatchFor2571388.m
Copyright (c) 2001, Apple Computer, Inc.  All rights reserved.

At the time of the release of Mac OS X, version 10.0, the Mac OS X
Cocoa AppKit Release Notes at
<http://developer.apple.com/techpubs/macosx/ReleaseNotes/AppKit.html>
claimed that:
"NSDocumentController's -fileExtensionsFromType: now returns an
array of file type strings that may contain encoded HFS file types as
well as file name extensions.
-runModalOpenPanel:forTypes: and -typeFromFileExtension: behave as they
always have, but will now accept file type strings that contain encoded
HFS file types as well as file name extensions.
-openDocumentWithContentsOfFile:display: and
-openDocumentWithContentsOfURL:display: now take the HFS file type of
files into consideration when deciding what subclass of NSDocument
should be instantiated."

This was not true.  None of the NSDocumentController methods named in
the release note, except for -runModalOpenPanel:forTypes:, handle HFS
file types correctly.  (The rest of the release notes dealing with HFS
file types are accurate.)

This descrepancy between Cocoa's implementation and the current
documentation has been recorded as bug in Apple's bug tracking
database (r. 2571388) and will be provided in a future release of
Mac OS.

To fix this problem, on a per-application basis, add this source
code to your application's project, and arrange for
NSDocumentControllerPatchFor2571388InstallIfNecessary to be called
during your application's startup. Adding a call to your
application's main function, before the standard call to
NSApplicationMain, should work fine.  When running in a
version of Mac OS where the fix is not available, this
routine will automatically install the substitution for
NSDocumentController defined in this file.

IMPORTANT:  This Apple software is supplied to you by Apple Computer,
Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or redistribution
of this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.  In consideration of your agreement to
abide by the following terms, and subject to these terms, Apple grants you
a personal, non-exclusive license, under Appleâs copyrights in
this original Apple software (the "Apple Software"), to use,
reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you
redistribute the Apple Software in its entirety and without modifications,
you must retain this notice and the following text and disclaimers in all
such redistributions of the Apple Software.  Neither the name,
trademarks, service marks or logos of Apple Computer, Inc. may be used
to endorse or promote products derived from the Apple Software without
specific prior written permission from Apple.  Except as expressly
stated in this notice, no other rights or licenses, express or implied,
are granted by Apple herein, including but not limited to any patent
rights that may be infringed by your derivative works or by other works
in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.
APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT
LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE
SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR
PRODUCTS.  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT,
INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND
WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT
LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>

extern double NSAppKitVersionNumber;
@interface NSDocumentControllerPatchedFor2571388 : NSDocumentController
@end
@implementation NSDocumentControllerPatchedFor2571388

// Reimplement a method that is invoked by both -fileExtensionsFromType:
// and -typeFromFileExtension:, effectively fixing them both.
// Warning: Even though this method appears in this patch file, don't
// consider it public.  Do not make assumptions about when this method
// will be invoked.  It may not be invoked at all in versions of AppKit in
// which 2571388 is fixed.

- (NSArray *)extensionsFromTypeDict:(NSDictionary *)inDocumentTypeInfo {
    NSArray *extensions;
    NSArray *osTypes;
    NSArray *extensionsAndHFSTypes;

    // Get the array that contains the file name extensions that are
    // allowable for the document type.

    extensions = [inDocumentTypeInfo
                  objectForKey:@"CFBundleTypeExtensions"];
    // Add entries for HFS file types if the passed-in dictionary has a
    // CFBundleTypeOSTypes entry.
    osTypes = [inDocumentTypeInfo
               objectForKey:@"CFBundleTypeOSTypes"];
    if (osTypes) {
        // For each entry in the CFBundleTypeOSTypes array, wrap what
        // should be a four-character string with apostrophes.
        int osTypeIndex;
        int osTypeCount = [osTypes count];
        NSMutableArray *hfsTypes = [NSMutableArray
                                    arrayWithCapacity:osTypeCount];
        for (osTypeIndex = 0; osTypeIndex<osTypeCount; osTypeIndex++) {
            NSString *osTypeAsFourCharString = [osTypes
                                                objectAtIndex:osTypeIndex];
            NSString *hfsType = [NSString
                                 stringWithFormat:@"\'%@\'",
                                 osTypeAsFourCharString];
            [hfsTypes addObject:hfsType];
        }
        // Add the array of HFS file types to the array being returned.
        extensionsAndHFSTypes = extensions ?
             [extensions arrayByAddingObjectsFromArray:hfsTypes] : hfsTypes;
    } else {
        // There are no HFS file types associated with this document file
        // type.  Just return the file name extensions, if there are any.
        extensionsAndHFSTypes = extensions;
    }
    // Done.
    return extensionsAndHFSTypes;
}


// Reimplement -openDocumentWithContentsOfFile:display: so that it no
// longer suffers from 2571388.

- (id)openDocumentWithContentsOfFile:(NSString *)inDocumentFilePath
                                            display:(BOOL)inDisplayDocument {
    // Try to open the document, using the already-existing Cocoa code,
    // which determines document type from file name extension.
    NSDocument *document = [super
                            openDocumentWithContentsOfFile:inDocumentFilePath
                            display:inDisplayDocument];
    // If that didn't work, try another way.
    if (!document && [[NSFileManager defaultManager]
                              fileExistsAtPath:inDocumentFilePath]) {
        // Try to figure out what kind of document we're opening, based on
        // the HFS file type.
    NSString *hfsFileType = NSHFSTypeOfFile(inDocumentFilePath);
    NSString *documentTypeName = [self typeFromFileExtension:hfsFileType];
        // If we were successful in determining the document type, try to
        // open the document.
        if (documentTypeName) {
            document = [self
                        makeDocumentWithContentsOfFile:inDocumentFilePath
                        ofType:documentTypeName];
            if (document) {
                [self addDocument:document];
                if ([self shouldCreateUI]) {
                    [document makeWindowControllers];
                    if (inDisplayDocument) {
                        [document showWindows];
                    }
                }
            }
        }
    }
    // Successful or not, done.
    return document;
}


// Reimplement -openDocumentWithContentsOfURL:display: so that it no
// longer suffers from 2571388.
- (id)openDocumentWithContentsOfURL:(NSURL *)inDocumentURL
                                     display:(BOOL)inDisplayDocument {
    NSDocument *document = nil;
    if ([inDocumentURL isFileURL]) {
        NSString *documentPath = [inDocumentURL path];
        document = [self openDocumentWithContentsOfFile:documentPath
                    display:inDisplayDocument];
    }
    return document;
}

@end
void NSDocumentControllerPatchFor2571388InstallIfNecessary(void) {
    // If the current version of AppKit is earlier than the first one in
    // which 2571388 is known to be fixed, replace the
    // NSDocumentController class with
    // NSDocumentControllerPatchedFor2571388.
    // Warning: The AppKit version for Mac OS 10.0, 10.0.1, 10.0.2, and
    // 10.0.3 is 577.0.  It's not safe however to test
    // NSAppKitVersionNumber>577.0, because Apple may or may not
    // release a product in which AppKit's version number is greater than
    // 577, but in which 2571388 is nonetheless not fixed.
    if (NSAppKitVersionNumber<588.0) {
        [NSDocumentControllerPatchedFor2571388
         poseAsClass:[NSDocumentController class]];
    }
}
#else
void NSDocumentControllerPatchFor2571388InstallIfNecessary(void) {
}
#endif
