#import "JgFrameworkNibLoading.h"

BOOL jgLoadNibNamedFu(NSString * nibName, id owner) {
id allFrameworks;
id bundle;
id path;
id table;
int i,count;
static BOOL debug=NO;
if (debug) NSLog(@"Looking for nib %@ with owner %d",nibName, owner);
allFrameworks = [NSBundle allFrameworks];
path=nil;
count=[allFrameworks count];
table=[[NSDictionary alloc] initWithObjectsAndKeys:owner,@"NSOwner",nil]; 
for (i=0;!path && (i<count); i++) {
  bundle=[allFrameworks objectAtIndex:i];
  path=[bundle pathForResource:nibName ofType:@""];
  if (path) {
    BOOL ret=[bundle loadNibFile:path externalNameTable:table withZone:[owner zone]];
    if (debug) NSLog(@"Return %d",ret);
    return ret;
  }
}
[table release];
return NO;
}

@implementation NSBundleJg
+ (BOOL)jgLoadNibNamed:(NSString *)nibName owner:(id)owner;
{
  return jgLoadNibNamedFu(nibName,owner);
}
@end

@implementation NSBundle (JgFrameworkNibLoading)

+ (BOOL)jgLoadNibNamed:(NSString *)nibName owner:(id)owner;
{
  return jgLoadNibNamedFu(nibName,owner);
}

@end