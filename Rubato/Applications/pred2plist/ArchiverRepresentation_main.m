
#import <Foundation/Foundation.h>
#import <Predicates/JgPrediBase.h>
#import <RubatoDeprecatedCommonKit/StringConverter.h>
#import <RubatoDeprecatedCommonKit/JGNXCompatibleUnarchiver.h>


void preditest(NSString *predfilename)
{
  NSString *plistfilename=[predfilename stringByAppendingString:@".plist"];
  JgPrediBase *pb=[JgPrediBase new];

  [pb readPred:predfilename];
  [pb predsToPlist];
  [pb writePlist:plistfilename];
}


int main (int argc, const char *argv[])
{
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   NSString *filename;
   id obj;
   // load Code
   [NSClassFromString(@"Weight") class];
   [NSClassFromString(@"LocalPerformanceScore") class];
   if (argc>1)
     filename=[NSString stringWithCString:argv[1]];
   else
     filename=@"/tmp/test.pred";
   if ([[filename pathExtension] isEqualToString:@"pred"])
     preditest(filename);
   else {
     obj=[JGNXCompatibleUnarchiver unarchiveObjectWithFile:filename];
   }
//   [pool release]; // jg? any more problems. Too bad
   exit(0);       // insure the process exit status is 0
   return 0;      // ...and make main fit the ANSI spec.
}
