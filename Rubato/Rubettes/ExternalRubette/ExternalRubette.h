// #import <Rubette/RubetteDocument.h>
#import <Foundation/Foundation.h>
#import <Rubette/Rubettes.h>

//#import <JGAppKit/JGTableData.h>
#import "JGTableData.h"

@interface ExternalRubette : RubetteObject
{
  int space;
  JGTableData *tableData;
  int domainFilter;
}
+ (const char *)rubetteVersion;
+ (spaceIndex)rubetteSpace;


- init;
- (void)dealloc;

- (id)tableData;
- (void)setTableData:(JGTableData *)newTableData;

- (int)domainFilter;
- (void)setDomainFilter:(int)newDomainFilter;

/* The real Work */
- (void)makePredList;
- (void)calculateWeight;
@end
