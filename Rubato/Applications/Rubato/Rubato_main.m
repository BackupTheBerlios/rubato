#import <AppKit/AppKit.h>
#import <JGAppKit/JGAppKitPatches.h>

//#ifdef WITH_MPWXmlKit
//#import <MPWXmlKit/MPWXmlArchiver.h>
//#import <MPWXmlKit/MPWXmlUnarchiver.h>
//#endif

//@class Distributor;

#ifdef WITHMUSICKIT
extern void _MKDisableErrorStream(void);
#endif

void LoadMainRubatoPatch()
{
  id pool=[[NSAutoreleasePool alloc] init];
  NSBundle *bundle=[NSBundle mainBundle];
  [bundle load];
  if (bundle) {
    NSString *patchPath=[[bundle bundlePath] stringByAppendingString:@".patch"];
    NSBundle *patchBundle=[NSBundle bundleWithPath:patchPath];
    if (patchBundle)
      [patchBundle principalClass];
    else {
      NSString *lastComponent=[patchPath lastPathComponent];
      patchPath=[[bundle builtInPlugInsPath] stringByAppendingPathComponent:lastComponent];
      patchBundle=[NSBundle bundleWithPath:patchPath];
      if (patchBundle)
        [patchBundle principalClass];
    }
  }
  [pool release];
}

int main(int argc, char *argv[]) {

//  id bundle,table;
#ifdef WITHMUSICKIT
        _MKDisableErrorStream();
#endif
  NSDocumentControllerPatchFor2571388InstallIfNecessary();
  LoadMainRubatoPatch();
  return NSApplicationMain(argc, argv); 
/*
  [NSApplication sharedApplication];
  bundle=[NSBundle bundleForClass:[Distributor class]];
  table=[NSDictionary dictionaryWithObject:NSApp forKey:@"NSOwner"];
  if ([bundle loadNibFile:@"Rubato.nib" externalNameTable:table withZone:[NSApp zone]]) {
            [NSApp run];
  }	
  [NSApp release];
  exit(0);
*/
}

