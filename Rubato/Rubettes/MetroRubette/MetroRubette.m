
#import "MetroRubette.h"
#import <Predicates/PredicateProtocol.h>
#import <Predicates/GenericForm.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubette/Weight.h>
#import "MetroWeightView.h"


@implementation MetroRubette

+ (const char *)rubetteVersion;
{
    return "1.02 Beta";
}

+ (spaceIndex)rubetteSpace;
{
    return (spaceIndex)1;
}

- init;
{
    [super init];
    metricalProfile=0;
    lowerLengthLimit=2;
    automaticMesh=0;

    predList=NULL; 	
    distValues=NULL;		
    gridValues=NULL;		
    prediCount=0;				
    myWeightList = (weightList){NULL, 0};
    return self;
}

- (void)dealloc;
{
  [super dealloc];
}

- (double)metricalProfile;
{
  return metricalProfile;
}
- (void)setMetricalProfile:(double)val;
{
  [extendedRubetteDriver setDataChanged:YES];
  metricalProfile=val;
}
- (int)lowerLengthLimit;
{
  return lowerLengthLimit;
}
- (void)setLowerLengthLimit:(int)val;
{
  [extendedRubetteDriver setDataChanged:YES];
  lowerLengthLimit=val;
} 
- (int)automaticMesh;
{
  return automaticMesh;
}
- (void)setAutomaticMesh:(int)val;
{
  [extendedRubetteDriver setDataChanged:YES];
  automaticMesh=val;
} 


- (int)prediCount;
{
  return prediCount;
}

- (weightList)weightList;
{
  return myWeightList;
}

- (double *)distValues;
{
  return distValues;
}

- (grid *)gridValues;
{
  return gridValues;
}

- (void)readCustomData;
{
    int i;
//jg    id aPredicate;
/*
    id rubetteData=[self rubetteData];
    double *distValues=[[self metroObject] distValues];
    grid *gridValues=[[self metroObject] gridValues];
*/
  id rubetteData=[self rubetteData];
   [self setMetricalProfile:[rubetteData doubleValueOf:METRO_PROFILE]];
   [self setLowerLengthLimit:[rubetteData intValueOf:METRO_CARD]];
   [self setAutomaticMesh:[rubetteData intValueOf:METRO_QUANT_AUTO_MESH]];
   [self makePredList];

    for (i=0; i<prediCount; i++) {
        distValues[i]=[[rubetteData getValueOf:METRO_DIST]doubleValueAt:i];
        gridValues[i].origin=[[rubetteData getValueOf:METRO_QUANT_ORIGIN]doubleValueAt:i];
        gridValues[i].mesh=[[rubetteData getValueOf:METRO_QUANT_MESH]fractValueAt:i];
    }
}

- (void)writeCustomData;
{
    int i;
    id aValue;

    id rubetteData=[self rubetteData];
    if (![rubetteData hasPredicateOfNameString:METRO_PROFILE]) {
        id <PredicateProtocol> aPredicate = [[[self valueForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_PROFILE];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_CARD]) {
        id <PredicateProtocol> aPredicate = [[[self valueForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_CARD];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_QUANT_MESH]) {
        id <PredicateProtocol> aPredicate = [[[self listForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_QUANT_MESH];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_QUANT_ORIGIN]) {
        id <PredicateProtocol> aPredicate = [[[self listForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_QUANT_ORIGIN];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_QUANT_AUTO_MESH]) {
        id <PredicateProtocol> aPredicate = [[[self valueForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_QUANT_AUTO_MESH];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_DIST]) {
        id <PredicateProtocol> aPredicate = [[[self listForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_DIST];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_WEIGHT_ONSETS]) {
        id <PredicateProtocol> aPredicate = [[[self listForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_WEIGHT_ONSETS];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:METRO_WEIGHT_VALUES]) {
        id <PredicateProtocol> aPredicate = [[[self listForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_WEIGHT_VALUES];
        [rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    [rubetteData setDoubleValueOf:METRO_PROFILE to:metricalProfile];
    [rubetteData setIntValueOf:METRO_CARD to:(lowerLengthLimit>0 ? lowerLengthLimit : 2)];
    [rubetteData setBoolValueOf:METRO_QUANT_AUTO_MESH to:automaticMesh];

    aValue = [rubetteData getValueOf:METRO_DIST];

    for (;prediCount<[aValue count];) {
        [aValue deleteValue:[aValue getValueAt:prediCount]];
    }
    for (i=0; i<prediCount;i++) {
        if (![aValue hasPredicateAt:i])
            [aValue setValue:[[[self valueForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_DIST_VAL]];
        [aValue setDoubleValueAt:i to:distValues[i]];
    }

    aValue = [rubetteData getValueOf:METRO_QUANT_MESH];
    for (;prediCount<[aValue count];) {
        [aValue deleteValue:[aValue getValueAt:prediCount]];
    }
    for (i=0; i<prediCount;i++) {
        if (![aValue hasPredicateAt:i])
            [aValue setValue:[[[self valueForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_QUANT_MESH_VAL]];
        [aValue setFractValueAt:i to:gridValues[i].mesh];
    }

    aValue = [rubetteData getValueOf:METRO_QUANT_ORIGIN];
    for (;prediCount<[aValue count];) {
        [aValue deleteValue:[aValue getValueAt:prediCount]];
    }
    for (i=0; i<prediCount;i++) {
        if (![aValue hasPredicateAt:i])
            [aValue setValue:[[[self valueForm] makePredicateFromZone:[self zone]]
                            setNameString:METRO_QUANT_ORIGIN_VAL]];
        [aValue setDoubleValueAt:i to:gridValues[i].origin];
    }
}
  


- (void)makePredList;
{
    int i, j, count, oldPrediCount;
    RubatoFract theVal;

    oldPrediCount = prediCount;

    /* first clean up the predicates*/
    for (i=0; i<[[self lastFoundPredicates] count]; i++) {
        id predicatesAtI = [[self lastFoundPredicates] getValueAt:i];
        count = [predicatesAtI count];
        for (j=0; j<count; j++) {
            id predicateAtJ = [predicatesAtI getValueAt:j];
            theVal = [predicateAtJ fractValueOf:"E"];
            if (![predicateAtJ hasPredicateOfNameString:"E"] || (theVal.isFraction && !theVal.denominator)) {
                [predicatesAtI removeValue:predicateAtJ];
                count--;
                j--;
            }
        }
        if (![predicatesAtI count]) {
            [[self lastFoundPredicates] removeValue:predicatesAtI];
            predicatesAtI==[self foundPredicates] ? [self setFoundPredicates:nil] : nil;
            predicatesAtI = nil;
            i--;
        }
    }

    /* now reallocate the memory for the predList and fill in the vals*/
    for (i=0;i<prediCount;i++)
        free(predList[i].Fronsets);

    prediCount = [[self lastFoundPredicates] count];
    predList = realloc(predList, prediCount*sizeof(FractList));

    for (i=0; i<prediCount; i++) {
            count = [[[self lastFoundPredicates] getValueAt:i]count];
            predList[i].length = count;
            predList[i].Fronsets = calloc(count, sizeof(RubatoFract));
            for (j=0; j<count; j++) {
              predList[i].Fronsets[j] = [[[[self lastFoundPredicates] getValueAt:i] getValueAt:j] fractValueOf:"E"]; // jg: is this the place to fill the JGTableData?
            }

    }

    distValues = realloc(distValues, prediCount*sizeof(double));
    for (i=oldPrediCount; i<prediCount; i++)
        distValues[i] = 1.0;
    gridValues = realloc(gridValues, prediCount*sizeof(grid));
    for (i=oldPrediCount; i<prediCount; i++)
        gridValues[i] = (grid){1,{1,8,YES}};

}


- (void)calculateWeight;
{
    int i;
    free(myWeightList.wP);
    if (prediCount) {
        preDisGrid *BigList;
        scaList *BigScaList;
        distributorList LL = {NULL,0};
        BigList = calloc(prediCount, sizeof(preDisGrid));

        for(i=0; i<prediCount; i++) {
            (BigList+i)->PRE = *(predList+i);
            (BigList+i)->DIS = *(distValues+i);
            (BigList+i)->GRD = *(gridValues+i);
        }

        BigScaList = calloc(prediCount, sizeof(scaList));

        for(i=0; i<prediCount; i++) {
            *(BigScaList+i) = makescaList(makequantList(
                    (BigList+i)->PRE,
                    (BigList+i)->GRD.origin,
                    (BigList+i)->GRD.mesh,
                    automaticMesh),
                (BigList+i)->DIS,
                lowerLengthLimit,
                metricalProfile);
        }

        LL.distributor = BigScaList;
        LL.length = prediCount;

        myWeightList = UniDistributor(LL);
    }
    else
        myWeightList = (weightList){NULL, 0};

    [[self extendedRubetteDriver] setDataChanged:YES];
    [self newWeight];
    for (i=0; i<myWeightList.length;i++)
        [[self weight] addWeight:myWeightList.wP[i].weight at:myWeightList.wP[i].param :0 :0 :0 :0 :0];
}


- (NSString *)weightText;
{
    if (myWeightList.length && myWeightList.wP) {
        int i;
        NSMutableString *mutableString = [NSMutableString new];

        [mutableString appendFormat:@"%s", "Onset"];
        [mutableString appendFormat:@"%c", '\t'];
        [mutableString appendFormat:@"%s", "Weight"];
        [mutableString appendFormat:@"%c", '\n'];
        for (i=0; i<myWeightList.length; i++) {
            [mutableString appendFormat:@"%.5f", myWeightList.wP[i].param];
            [mutableString appendFormat:@"%c", '\t'];
            [mutableString appendFormat:@"%.5f", myWeightList.wP[i].weight];
            [mutableString appendFormat:@"%c", '\n'];
        }
        return mutableString;
    } else
        return @"";
}

- (void)makeWeightList;
{
    int i;
    myWeightList.length = [[self weight] count];
    myWeightList.wP = realloc(myWeightList.wP, myWeightList.length*sizeof(weightPoint));
    for (i=0; i<myWeightList.length; i++) {
        myWeightList.wP[i].param = [[[self weight] eventAt:i]doubleValueAt:0];
        myWeightList.wP[i].weight = [[[self weight] eventAt:i]doubleValue];
    }
}

@end