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

int main(int argc, char *argv[]) {

//  id bundle,table;
#ifdef WITHMUSICKIT
        _MKDisableErrorStream();
#endif
  NSDocumentControllerPatchFor2571388InstallIfNecessary();
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

