
#import "ExternalRubette.h"
#import <Predicates/PredicateProtocol.h>
#import <Predicates/GenericForm.h>
#import <Rubette/Weight.h>

@implementation ExternalRubette

+ (const char *)rubetteVersion;
{
    return "0.01";
}

+ (spaceIndex)rubetteSpace;
{
    return (spaceIndex)1+2+4+8+16+32; // all 
}

// used for making Weights. Flexible!
- (spaceIndex)rubetteSpace;
{
  return space;
}

- init;
{
    [super init];
    tableData=nil;
    domainFilter=1;
    return self;
}

- (void)dealloc;
{
  [tableData release];
  [super dealloc];
}
- (int)domainFilter;
{
  return domainFilter;
}
- (void)setDomainFilter:(int)newDomainFilter;
{
  domainFilter=newDomainFilter;
}
- (id)tableData;
{
  return tableData;
}
- (void)setTableData:(JGTableData *)newTableData;
{
  [newTableData retain];
  [tableData release];
  tableData=newTableData;
}

- (void)makePredList;
{
    int i, j, count;
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSArray *titles=[tableData titles];

    /* first clean up the predicates*/
    for (i=0; i<[[self lastFoundPredicates] count]; i++) {
        id predicatesAtI = [[self lastFoundPredicates] getValueAt:i];
        count = [predicatesAtI count];
        for (j=0; j<count; j++) {
            NSString *koord;
            id predicateAtJ = [predicatesAtI getValueAt:j];
            NSEnumerator *e=[titles objectEnumerator];
            [dict removeAllObjects];
            while (koord=[e nextObject]) {
              id val;
              if ([predicateAtJ hasPredicateOfName:koord]) {
                val=[predicateAtJ stringValueOfPredicateWithName:koord];
                if (val)
                  [dict setObject:val forKey:koord];
              }
            }
            if ([dict count])
              [tableData addRecord:dict];
        }
    }
}

- (void)calculateWeight;
{
    int i,j,tc,fc,rc;
    NSArray *parsArray=[NSArray arrayWithObjects:@"E",@"H",@"L",@"D",@"G",@"C",@"W",nil];
    int sourceInds[7],destInds[7];
    int indsCount=0;
    int wSourceInd=-1;
    NSArray *titles=[tableData titles];
    NSArray *fields=[tableData fields];
    tc=[titles count];
    fc=[fields count];
    rc=fc/tc; // row count
    // read "WEHLDGC" from tableData

    space=0;
    j=1;
    for (i=0;i<7;i++) {
      if ((i==6) || (domainFilter & j)) {
        int titleIndex=[titles indexOfObject:[parsArray objectAtIndex:i]];
        if (titleIndex!=NSNotFound) {
          if (i!=6) {
            space+=j;
            destInds[indsCount]=i;
            sourceInds[indsCount]=titleIndex;
            indsCount++;            
          } else
            wSourceInd=titleIndex;
        }
      }
      j*=2;
    }
    // jg?? if there are no columns left, what should we do? create a weight without domain? why not...!

    if (wSourceInd<0) {
      // it must have a W-Column!
      NSBeep();
      return;
    }
    [self newWeight];

    for (i=0;i<rc; i++) {
      NSString *wVal=[fields objectAtIndex:(i*tc+wSourceInd)];
      if (![wVal isEqualToString:@"."]) {
        id anEvent = [[MatrixEvent alloc]init];
        double d=[wVal doubleValue];
        [anEvent setSpaceTo:space];
        [anEvent setDoubleValue:d];
        for (j=0;j<indsCount;j++) {
          NSString *val=[fields objectAtIndex:(i*tc+sourceInds[j])];
          d=[val doubleValue];
          [anEvent setDoubleValue:d atIndex:destInds[j]];
        }
        [[self weight] addEvent:anEvent];        
      }
    }
}

@end