/* MeloRubetteDriver.m */

#import "MeloRubetteDriver.h"

#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Predicates/predikit.h>

#import <Rubette/Weight.h>

#import "MeloWeightView.h"
#import "MeloMotifView.h"
#import "MeloWeightView.h"
/*Probably superfluous? I did it by analogy with MetroRUbetteGM*/
#import <Foundation/NSDebug.h>


#define MELO_WEIGHT "MeloWeight"
#define MELO_WEIGHT_LIST "MeloWeight List"
#define MELO_WEIGHT_POINT "MeloWeight Point"
#define NEIGHBOURH_VALUE "Neighbourhood"
#define MLENGTH_VALUE "Motif length"
#define MCARD_VALUE "Motif cardinality"
#define SYMMETRY_VALUE "Symmetry group"
#define GESTALT_VALUE "Gestalt paradigm"

#define MELO_MOTIF_LIST "List of Melodic Motifs"
#define MOTIF_LIST_LAYERS "ML Layer"
#define MOTIF_LAYER "Motif Layer"
#define MOTIF_LIST_SPAN "ML Span"
#define MOTIF_LIST_CARD "ML Card"

#define MELO_MOTIF "Melodic Motif"
#define MELO_POINT_LIST "Melodic Point List"
#define MOTIF_PRESENCE "Motif's Presence"
#define MOTIF_CONTENT "Motif's Content"

#define MELO_POINT "Melodic Point"
#define PARA1 "Parameter 1"
#define PARA2 "Parameter 2"


@class ValuePredicate;

@implementation MeloRubetteDriver

- init;
{
    [super init];
    return self;
}

- (void)closeRubetteWindows1;
{
  [myWeightFunctionPanel performClose:self];
  [myWeightFunctionPanel release]; myWeightFunctionPanel = nil;
  [myWeightViewPanel performClose:self];
  [myWeightViewPanel release]; myWeightViewPanel = nil;
  [myMotifViewPanel performClose:self];
  [myMotifViewPanel release]; myMotifViewPanel = nil;
  [myGraphicPrefsPanel performClose:self];
  [myGraphicPrefsPanel release]; myGraphicPrefsPanel = nil;
  
}
- (void)closeRubetteWindows;
{
  [self closeRubetteWindows1];
  [super closeRubetteWindows];
}

- (void)dealloc;
{
  [self closeRubetteWindows1];
  [super dealloc];
}

- customAwakeFromNib;
{
    [myWeightFunctionPanel setFrameUsingName:[myWeightFunctionPanel title]];
    [myWeightFunctionPanel setBecomesKeyOnlyIfNeeded:YES];

    [myWeightViewPanel setFrameUsingName:[myWeightViewPanel title]];
    [myWeightViewPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myGraphicPrefsPanel setFrameUsingName:[myGraphicPrefsPanel title]];
    [myGraphicPrefsPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myMotifViewPanel setFrameUsingName:[myMotifViewPanel title]];
    [myMotifViewPanel setBecomesKeyOnlyIfNeeded:YES];
    
    return self;
}

/* read & write Rubettes results, defaults etc. from open .pred file */
- (void)readCustomData;
{
    int tag,index;
//    id aMatrix;
  id rubetteData=[self rubetteData];

    [myNeighbourhoodField setFloatValue:[rubetteData floatValueOf:NEIGHBOURH_VALUE]];
    [myMotifSpanField setFloatValue:[rubetteData floatValueOf:MLENGTH_VALUE]];
    [myMotifCardField setIntValue:[rubetteData intValueOf:MCARD_VALUE]];
    
    tag=[rubetteData intValueOf:SYMMETRY_VALUE];
    index=[mySymmetryPopUp indexOfItemWithTag:tag];
    [mySymmetryPopUp selectItemAtIndex:index];
    [mySymmetryPopUp setTitle:[mySymmetryPopUp titleOfSelectedItem]];
    
    tag=[rubetteData intValueOf:GESTALT_VALUE];
    index=[myParadigmPopUp indexOfItemWithTag:tag];
    [myParadigmPopUp selectItemAtIndex:index];
    [myParadigmPopUp setTitle:[myParadigmPopUp titleOfSelectedItem]];

    [self makePredList];
    [self readMotifList];
//    [self readWeightList];
//    [self showWeightText];
    
    browserValid = NO;
    [myBrowser validateVisibleColumns];
    browserValid = YES;

    [self updateFieldsWithBrowser:myBrowser];
//    [myWeightView displayWeightList:myWeightList];
}

- readMotifList;
{
    int i;
    id aPredicate = [[self rubetteData] getFirstPredicateOfNameString:MELO_MOTIF_LIST];
    myMotifList.span = [aPredicate floatValueOf:MOTIF_LIST_SPAN];
    myMotifList.card = [aPredicate intValueOf:MOTIF_LIST_CARD];
    [myMotifSpanField setStringValue:[NSString jgStringWithCString:[aPredicate stringValueOf:MOTIF_LIST_SPAN]]];
    [myMotifCardField setIntValue:myMotifList.card];

    myMotifList.length = [[aPredicate getFirstPredicateOfNameString:MOTIF_LIST_LAYERS] count];
    myMotifList.layer = realloc(myMotifList.layer, myMotifList.length*sizeof(M2D_powcomList));
    myMotifList.layer[0] = (M2D_powcomList){NULL,0};
    for (i=1; i<myMotifList.length;i++) {
	myMotifList.layer[i] = [self readLayer:i ofMotifList:aPredicate] ;
    }
    return self;
}

- (M2D_powcomList) readLayer:(int)index ofMotifList: aList;
{
    int i,j;
    M2D_compList theMotif;
    M2D_powcomList theLayer;
    id aLayer = [[aList getFirstPredicateOfNameString:MOTIF_LIST_LAYERS] getValueAt:index];
    theLayer.length = [aLayer count];
    theLayer.M2D_powcom = calloc(theLayer.length, sizeof(M2D_compList));
    
    for (i=0; i<theLayer.length; i++) {
	id aMotif = [aLayer getValueAt:i];
	theMotif.presence = [aMotif doubleValueOf: MOTIF_PRESENCE];
	theMotif.content = [aMotif doubleValueOf: MOTIF_CONTENT];
	theMotif.weight = theMotif.presence * theMotif.content;

	aMotif = [aMotif getFirstPredicateOfNameString:MELO_POINT_LIST];
	theMotif.length = [aMotif count];
	theMotif.M2D_comp = calloc(theMotif.length, sizeof(M2D_Point));
	for (j=0; j<theMotif.length;j++) {
	    id aPoint = [aMotif getValueAt:j];
	    theMotif.M2D_comp[j].para1 = [aPoint doubleValueOf:PARA1];
	    theMotif.M2D_comp[j].para2 = [aPoint doubleValueOf:PARA2];
	}
	theLayer.M2D_powcom[i] = theMotif;
    }
    return theLayer;
}

- (void)readWeightList;
{
    int i;
    id aPredicate = [[self rubetteData] getFirstPredicateOfNameString:MELO_WEIGHT_LIST];
    myWeightList.length = [aPredicate count];
    myWeightList.M2D_wP = realloc(myWeightList.M2D_wP, myWeightList.length*sizeof(M2D_weightPoint));
    
    for (i=0; i<myWeightList.length; i++) {
	id aPoint = [aPredicate getValueAt:i];
	myWeightList.M2D_wP[i].M2D_Pt.para1 = [aPoint doubleValueOf:PARA1];
	myWeightList.M2D_wP[i].M2D_Pt.para2 = [aPoint doubleValueOf:PARA2];
	myWeightList.M2D_wP[i].weight = [aPoint doubleValueOf:MELO_WEIGHT];
    }
}

- (void)writeCustomData;
{
  id rubetteData=[self rubetteData];
    if (![rubetteData hasPredicateOfNameString:NEIGHBOURH_VALUE]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:NEIGHBOURH_VALUE];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:MLENGTH_VALUE]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:MLENGTH_VALUE];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:MCARD_VALUE]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:MCARD_VALUE];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:SYMMETRY_VALUE]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:SYMMETRY_VALUE];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:GESTALT_VALUE]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:GESTALT_VALUE];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:MELO_WEIGHT_LIST]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]
			    setNameString:MELO_WEIGHT_LIST];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    if (![rubetteData hasPredicateOfNameString:MELO_MOTIF_LIST]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]
			    setNameString:MELO_MOTIF_LIST];
	[rubetteData setValueOf:RSLT_NAME to:aPredicate];
    }

    [rubetteData setStringValueOf:NEIGHBOURH_VALUE to:[[myNeighbourhoodField stringValue] cString]];
    [rubetteData setStringValueOf:MLENGTH_VALUE to:[[myMotifSpanField stringValue] cString]];
    [rubetteData setIntValueOf:MCARD_VALUE to:[myMotifCardField intValue]];
    [rubetteData setIntValueOf:SYMMETRY_VALUE to:[[mySymmetryPopUp selectedItem]tag]];
    [rubetteData setIntValueOf:GESTALT_VALUE to:[[myParadigmPopUp selectedItem]tag]];
    
    [self writeMotifList];
//    [self writeWeightList];
}

- writeMotifList;
{
    int i, j, k;
    id aPoint, aMotif, aPList, aLayer, aList = [[self rubetteData] getFirstPredicateOfNameString:MOTIF_LIST_LAYERS];
    for (;myMotifList.length<[aList count];) {
	aLayer = [aList getValueAt:myMotifList.length];
	for (;[aLayer count];) {
	    aMotif = [aLayer getValueAt:[aLayer count]-1];
	    [aMotif deleteValue:[aMotif getValueOf:MOTIF_PRESENCE]];
	    [aMotif deleteValue:[aMotif getValueOf:MOTIF_CONTENT]];
	    aPList = [aMotif getValueOf:MELO_POINT_LIST];
	    for (;[aPList count];) {
		aPoint = [aPList getValueAt:[aPList count]-1];
		[aPoint deleteValue:[aPoint getValueOf:PARA1]];
		[aPoint deleteValue:[aPoint getValueOf:PARA2]];
		[aPList deleteValue:aPoint];
	    }
	    [aMotif deleteValue:aPList];
	    [aLayer deleteValue:aMotif];
	}
	[aList deleteValue:aLayer];
    }
    
    aList = [[self rubetteData] getFirstPredicateOfNameString:MELO_MOTIF_LIST];
    if (![aList hasPredicateOfNameString:MOTIF_LIST_LAYERS]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]
			    setNameString:MOTIF_LIST_LAYERS];
	[aList setValue:aPredicate];
    }
    if (![aList hasPredicateOfNameString:MOTIF_LIST_SPAN]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:MOTIF_LIST_SPAN];
	[aList setValue:aPredicate];
    }
    [aList setDoubleValueOf:MOTIF_LIST_SPAN to:myMotifList.span];

    if (![aList hasPredicateOfNameString:MOTIF_LIST_CARD]) {
	id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
			    setNameString:MOTIF_LIST_CARD];
	[aList setValue:aPredicate];
    }
    [aList setDoubleValueOf:MOTIF_LIST_CARD to:myMotifList.card];

    for (i=0; i<myMotifList.length; i++) {
	aLayer = [[aList getFirstPredicateOfNameString:MOTIF_LIST_LAYERS] getValueAt:i];
	if (!aLayer) {
	    aLayer = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:MOTIF_LAYER];
	    [[aList getFirstPredicateOfNameString:MOTIF_LIST_LAYERS] setValue:aLayer];
	}
	for (j=0; j<myMotifList.layer[i].length; j++) {
	    aMotif = [aLayer getValueAt:j];
	    if (!aMotif) {
		aMotif = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:MELO_MOTIF];
		[aLayer setValue:aMotif];
	    }
	    if (![aMotif hasPredicateOfNameString:MOTIF_PRESENCE]) {
		id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
				    setNameString:MOTIF_PRESENCE];
		[aMotif setValue:aPredicate];
	    }
	    [aMotif setDoubleValueOf:MOTIF_PRESENCE to:myMotifList.layer[i].M2D_powcom[j].presence];
	    
	    if (![aMotif hasPredicateOfNameString:MOTIF_CONTENT]) {
		id <PredicateProtocol> aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
				    setNameString:MOTIF_CONTENT];
		[aMotif setValue:aPredicate];
	    }
	    [aMotif setDoubleValueOf:MOTIF_CONTENT to:myMotifList.layer[i].M2D_powcom[j].content];
	    
	    aPList = [aMotif getFirstPredicateOfNameString:MELO_POINT_LIST];
	    if (!aPList) {
		aPList = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]
				    setNameString:MELO_POINT_LIST];
		[aMotif setValue:aPList];
	    }
	    
	    for (k=0; k<myMotifList.layer[i].M2D_powcom[j].length;k++) {
		aPoint = [aPList getValueAt:k];
		if (!aPoint) {
	            id tmp;
		    aPoint = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:MELO_POINT];
		    tmp=[[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
                                    setNameString:PARA1];
                    [tmp setDoubleValue:myMotifList.layer[i].M2D_powcom[j].M2D_comp[k].para1];
		    [aPoint setValue:tmp];
		    tmp=[[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
                                    setNameString:PARA2];
                    [tmp setDoubleValue:myMotifList.layer[i].M2D_powcom[j].M2D_comp[k].para2];
		    [aPoint setValue:tmp];
		    
		    [aPList setValue:aPoint];
		} else {
		    [aPoint setDoubleValueOf:PARA1 to:myMotifList.layer[i].M2D_powcom[j].M2D_comp[k].para1];
		    [aPoint setDoubleValueOf:PARA2 to:myMotifList.layer[i].M2D_powcom[j].M2D_comp[k].para2];
		}
	    }
	}
    }
     
    return self;
}

- (void)writeWeightList;
{
    int i;
    id aList = [[self rubetteData] getFirstPredicateOfNameString:MELO_WEIGHT_LIST];
    for (;myWeightList.length<[aList count];) {
	id aValue = [aList getValueAt:myWeightList.length];
	[aValue deleteValue:[aValue getValueOf:PARA1]];
	[aValue deleteValue:[aValue getValueOf:PARA2]];
	[aValue deleteValue:[aValue getValueOf:MELO_WEIGHT]];
	[aList deleteValue:aValue];
    }
    for (i=0; i<myWeightList.length;i++) {
	if (![aList hasPredicateAt:i]) {
	    id tmp;
	    id aValue = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:MELO_WEIGHT_POINT];
	    tmp=[[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
                            setNameString:PARA1];
            [tmp setDoubleValue:myWeightList.M2D_wP[i].M2D_Pt.para1];
	    [aValue setValue:tmp];
	    tmp=[[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
                            setNameString:PARA2];
            [tmp setDoubleValue:myWeightList.M2D_wP[i].M2D_Pt.para2];
	    [aValue setValue:tmp];
	    tmp=[[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
                            setNameString:MELO_WEIGHT];
            [tmp setDoubleValue:myWeightList.M2D_wP[i].weight];
	    [aValue setValue:tmp];
	    
	    [aList setValue:aValue];
	} else {
	    id aValue = [aList getValueAt:i];
	    [aValue setDoubleValueOf:PARA1 to:myWeightList.M2D_wP[i].M2D_Pt.para1];
	    [aValue setDoubleValueOf:PARA2 to:myWeightList.M2D_wP[i].M2D_Pt.para2];
	    [aValue setDoubleValueOf:MELO_WEIGHT to:myWeightList.M2D_wP[i].weight];
	}
    }
}


- (void)readWeight;
{
    [super readWeight];
    [self makeWeightList];
    [self showWeightText];    
    [myWeightView displayWeightList:myWeightList];
}

- (void)readWeightParameters;
{
    int row;
//    id aMatrix;
    
    [super readWeightParameters];
    
    [myNeighbourhoodField setFloatValue:[[self weight] doubleValueOfParameter:NEIGHBOURH_VALUE]];
    [myMotifSpanField setFloatValue:[[self weight] doubleValueOfParameter:MLENGTH_VALUE]];
    [myMotifCardField setIntValue:[[self weight] intValueOfParameter:MCARD_VALUE]];

// jg replaced indexOfItem with indexOfItemWithTitle
    row=[[mySymmetryPopUp target] indexOfItemWithTitle:[NSString jgStringWithCString:[[self weight] stringValueOfParameter:SYMMETRY_VALUE]]];
//#warning PopUpConversion: Consider NSPopUpButton methods instead of using itemMatrix to access items in a pop-up list.
//    aMatrix = [mySymmetryPopUp itemMatrix];
//    [aMatrix selectCellAtRow:row column:0];
    [mySymmetryPopUp selectItemAtIndex:row];
    [mySymmetryPopUp setTitle:[mySymmetryPopUp titleOfSelectedItem]];

    row=[[myParadigmPopUp target] indexOfItemWithTitle:[NSString jgStringWithCString:[[self weight] stringValueOfParameter:GESTALT_VALUE]]];
//#warning PopUpConversion: Consider NSPopUpButton methods instead of using itemMatrix to access items in a pop-up list.
//    aMatrix = [myParadigmPopUp itemMatrix];
//    [aMatrix selectCellAtRow:row column:0];
    [myParadigmPopUp selectItemAtIndex:row];
    [myParadigmPopUp setTitle:[myParadigmPopUp titleOfSelectedItem]];
}

- (void)writeWeightParameters;
{
    [super writeWeightParameters];
    
    [[self weight] setParameter:NEIGHBOURH_VALUE toDoubleValue:[myNeighbourhoodField floatValue]];
    [[self weight] setParameter:MLENGTH_VALUE toDoubleValue:[myMotifSpanField floatValue]];
    [[self weight] setParameter:MCARD_VALUE toIntValue:[myMotifCardField intValue]];
    [[self weight] setParameter:SYMMETRY_VALUE toStringValue:[[[mySymmetryPopUp selectedItem] title] cString]];
    [[self weight] setParameter:GESTALT_VALUE toStringValue:[[[myParadigmPopUp selectedItem] title] cString]];
}

- loadWeight:sender;
{
    [super loadWeight:sender];
    [self makeWeightList];
    [self showWeightText];    
    [myWeightView displayWeightList:myWeightList];
    return self;
}

- makeWeightList;
{
    int i;
    myWeightList.length = [[self weight] count];
    myWeightList.M2D_wP = realloc(myWeightList.M2D_wP, myWeightList.length*sizeof(M2D_weightPoint));
    for (i=0; i<myWeightList.length; i++) {
	myWeightList.M2D_wP[i].M2D_Pt.para1 = [[[self weight] eventAt:i]doubleValueAt:0];
	myWeightList.M2D_wP[i].M2D_Pt.para2 = [[[self weight] eventAt:i]doubleValueAt:1];
	myWeightList.M2D_wP[i].weight = [[[self weight] eventAt:i]doubleValue];
    }
    return self;
}


- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
    browserValid = NO;
  [super doSearchWithFindPredicateSpecification:specification];
    myMotifList.length = 0;
    [self doCalculateWeight:self];
    [myBrowser validateVisibleColumns];
    [myWeightView displayWeightList:myWeightList]; 
    browserValid = YES;
}

- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
    browserValid = NO;
    [super initSearchWithFindPredicateSpecification:specification];
    [self updateFieldsWithBrowser:nil];
    [self makePredList];
    myMotifList.length = 0;
    myMotifList.card = 0;
    [[myBrowser matrixInColumn:0] selectCellAtRow:-1 column:-1];
    [myBrowser loadColumnZero];
    [myBrowser validateVisibleColumns];
    browserValid = YES;
}

/* The real Work */
- (void)makePredList;
{
    id predicate;
    unsigned int i, prediCount = [[self foundPredicates] count];

    /* first clean up the predicates*/
    for (i=0; i<prediCount; i++) {
	predicate = [[self foundPredicates] getValueAt:i];
	if (!([predicate hasPredicateOfNameString:"E"] &&
	    [predicate hasPredicateOfNameString:"H"])) {
	    [[self foundPredicates] removeValue:predicate];
	    prediCount--;
	    i--;
	}
    }

    /* now reallocate the memory for the meloList and fill in the vals*/
    meloList.M2D_comp = realloc(meloList.M2D_comp, prediCount*sizeof(M2D_Point));
    meloList.length = prediCount;
    meloList.presence = 0.0;
    meloList.content = 0.0;
    meloList.weight = 0.0;

    for (i=0; i<prediCount; i++) {
	predicate = [[self foundPredicates] getValueAt:i];
	meloList.M2D_comp[i].para1 = [predicate doubleValueOf:"E"];
	meloList.M2D_comp[i].para2 = [predicate doubleValueOf:"H"];
    }
}

- doCalculateWeight:sender;
{
    [self makePredList];
    [self calculateWeight];
    [myWeightView displayWeightList:myWeightList];
    
    [self showWeightText]; 

    return self;
}

- (void)calculateWeight;
{
    int i;
    free(myWeightList.M2D_wP);
    
    myWeightList = meloWeightList(meloList, myMotifList,
	[myNeighbourhoodField doubleValue],
	[[myParadigmPopUp selectedItem]tag],
	[[mySymmetryPopUp selectedItem]tag],
	[myMotifCardField intValue]);
    
    [self setDataChanged:YES];
    [self newWeight];
    for (i=0; i<myWeightList.length;i++) 
	[[self weight] addWeight:myWeightList.M2D_wP[i].weight 
	    at:myWeightList.M2D_wP[i].M2D_Pt.para1 :myWeightList.M2D_wP[i].M2D_Pt.para2 :0 :0 :0 :0];
    [self writeWeightParameters];
}


- showWeightText;
{
    if (myWeightList.length && myWeightList.M2D_wP) {
	int i;
	NSMutableString *mutableString = [NSMutableString new];
	
	[mutableString appendFormat:@"%s", "Para 1"];
	[mutableString appendFormat:@"%c", '\t'];
	[mutableString appendFormat:@"%s", "Para 2"];
	[mutableString appendFormat:@"%c", '\t'];
	[mutableString appendFormat:@"%s", "Weight"];
	[mutableString appendFormat:@"%c", '\n'];
	for (i=0; i<myWeightList.length; i++) {
	    [mutableString appendFormat:@"%.5f", myWeightList.M2D_wP[i].M2D_Pt.para1];
	    [mutableString appendFormat:@"%c", '\t'];
	    [mutableString appendFormat:@"%.5f", myWeightList.M2D_wP[i].M2D_Pt.para2];
	    [mutableString appendFormat:@"%c", '\t'];
	    [mutableString appendFormat:@"%.5f", myWeightList.M2D_wP[i].weight];
	    [mutableString appendFormat:@"%c", '\n'];
	}

//	[myMeloWeightText setText:data];
        [myMeloWeightText setString:mutableString];

    } else
	[myMeloWeightText setString:@""];    
    return self;
}


- doMakeAllMotifs:sender;
{
    [self makePredList];
    [self makeMotifList];
    return self;
}

- makeMotifList;
{
    int i, len;
    card = [myMotifCardField intValue];
    [myConverter setStringValue:[myMotifSpanField stringValue]];
    span = [myConverter doubleValue];
    len = [myMotifCardField intValue]+1;
    myMotifList.layer = realloc(myMotifList.layer, len*sizeof(M2D_powcomList));
    myMotifList.layer[0] = (M2D_powcomList){NULL,0};
    myMotifList.length = len;
    if (card < myMotifList.card) myMotifList.card = card;
    for (i=1; i<len;i++) {
	genPow(meloList, &myMotifList, span, i);
    }
    browserValid = NO;
    [myBrowser validateVisibleColumns];
    browserValid = YES;
    [self setDataChanged:YES];
    return self;
}

- doCalculateMotifWeights:sender;
{
    [self calculateMotifListWeights];
    return self;
}

- calculateMotifListWeights;
{
    myMotifList = weightedGenMotifList(myMotifList,
		[myNeighbourhoodField doubleValue],
		[[myParadigmPopUp selectedItem]tag],
		[[mySymmetryPopUp selectedItem]tag],
		[myMotifCardField intValue]);
    [self setDataChanged:YES];
    return self;
}



- (void)setSelectedMotif:sender;
{
    if ([sender isKindOfClass:[NSBrowser class]] && [sender selectedColumn]==2) {
	int selMot = [sender selectedRowInColumn:2];//[[sender matrixInColumn:2] selectedRow];
	int selMotList = [sender selectedRowInColumn:1] ;//[[sender matrixInColumn:1] selectedRow];
	
	if (selMotList<myMotifList.length && selMot<myMotifList.layer[selMotList].length)
	    [myMotifView displayMotif:myMotifList.layer[selMotList].M2D_powcom[selMot]];
    } 
}

- (void)updateFieldsWithBrowser:sender;
{
    if ([sender isKindOfClass:[NSBrowser class]] && [sender selectedColumn]!=NSNotFound) 
	selPredIndex = [sender selectedRowInColumn:[sender selectedColumn]];//[[sender matrixInColumn:[sender selectedColumn]] selectedRow];
    else
	selPredIndex = NSNotFound;

    if (selPredIndex!=NSNotFound) {
	[self setSelectedMotif:sender];
	browserValid = NO;
	[myBrowser validateVisibleColumns];
    } else {
    
    }
    browserValid = YES;
}

- (void)setSelectedCell:sender;
{ // called by IB
[self updateFieldsWithBrowser:sender];
}


/* window management */
- (IBAction)showWindow:(id)sender;
{
    [super showWindow:sender];
    [myWeightFunctionPanel orderFront:sender];
    [myWeightViewPanel orderFront:sender];
    [myMotifViewPanel orderFront:sender];
}

- hideWindow:sender;
{
    [myWeightFunctionPanel orderOut:sender];
    [myWeightViewPanel orderOut:sender];
    [myMotifViewPanel orderOut:sender];
    [myGraphicPrefsPanel orderOut:sender];
    [super hideWindow:sender];
    return self;
}

/* methods to be overridden by subclasses */
- insertCustomMenuCells;
{
    [[myMenu addItemWithTitle:@"Weight Function" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myWeightFunctionPanel];
    [[myMenu addItemWithTitle:@"Weight View" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myWeightViewPanel];
    [[myMenu addItemWithTitle:@"Load Weight" action:@selector(loadWeight:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Save Weight As" action:@selector(saveWeightAs:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Melodic Motifs" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myMotifViewPanel];
    [[myMenu addItemWithTitle:@"Graphic Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myGraphicPrefsPanel];
    
    return self;
}


/* class methods to be overridden by subclasses */
+ (NSString *)nibFileName;
{
  return @"MeloRubette.nib";
}

+ (const char *)rubetteName;
{
    return "Melo";
}

+ (const char *)rubetteVersion;
{
    return "1.01 Beta";
}

+ (spaceIndex)rubetteSpace;
{
    return (spaceIndex)3;
}

@end

@implementation MeloRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    int retVal;
    switch(column) {
	case 0:
	    retVal = [[self lastFoundPredicates] count];
	    break;
	case 1:
	{
	    retVal = myMotifList.length;
	    break;
	}
	case 2:
	{
	    int selMotList = [myBrowser selectedRowInColumn:1]; //jg7.12.2001[[myBrowser matrixInColumn:1]selectedRow];
	    if (selMotList>0 && selMotList<myMotifList.length)
		retVal = myMotifList.layer[selMotList].length;
	    else
		retVal = 0;
	    break;
	}
	default:
	    retVal = 0;
	    break;
    }
    return retVal;
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    switch(column) {
	case 0: 
	{
	    id predicate = [[self lastFoundPredicates] getValueAt:row];
	    id image, imageString = [[StringConverter alloc]init];
	    if (predicate) {
		[cell setLoaded:YES];
		[cell setStringValue:[NSString jgStringWithCString:[predicate nameString]]];
		[cell setLeaf:NO];
		[imageString setStringValue:[NSString jgStringWithCString:[predicate typeString]]];
		image = [NSImage imageNamed:[imageString stringValue]];
		if (image) 
		    [cell setImage:[image copy]];
		[imageString concat:"H"];
		image = [NSImage imageNamed:[imageString stringValue]];
		if (image) 
		    [cell setAlternateImage:[image copy]];
	    }
	    [imageString release];
	    break;
	}
	case 1:
	{
	    if (row<=myMotifList.length) {
		id str = [[StringConverter alloc]init];
	        [str setIntValue:row];
		[str concat:"-Motifs ["];
		[str concatInt:myMotifList.layer[row].length];
		[str concat:"]"];
		[cell setLoaded:YES];
		[cell setStringValue:[str stringValue]];
		[cell setLeaf:!myMotifList.layer[row].length];
		[str release];
	    }
            break;
	}
	case 2:
	{
	    int selMotList = [myBrowser selectedRowInColumn:1];//[[myBrowser matrixInColumn:1]selectedRow];
	    if (selMotList>0 && row<myMotifList.layer[selMotList].length && myMotifList.layer[selMotList].M2D_powcom) {
		id str = [[StringConverter alloc]init];
	        [str setIntValue:row+1];
		[str insert:"Motif " at:0];
		[cell setLoaded:YES];
		[cell setStringValue:[str stringValue]];
		[cell setLeaf:YES];
		[str release];
	    }
            break;
	}
        default: if (NSDebugEnabled) NSLog(@"unexpected column=%d",column);
          break;
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    BOOL retVal;
    retVal = ([NSView focusView] == [sender matrixInColumn:column]) ? YES : browserValid;
    return retVal;
}

@end
