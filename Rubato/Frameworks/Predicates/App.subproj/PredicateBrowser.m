#import "PredicateBrowser.h"

#ifdef WITHMUSICKIT
#import <MusicKit/MusicKit.h>
#endif

#import <Rubato/Distributor.h>
#import <Predicates/predikit.h>
#import <Predicates/MKScoreReader.h>

#import <Predicates/JgPrediBase.h>
#import <JgKit/MyUnArchiver.h>
//#import <JgAppKit/StickyNXImage.h>

#import "PredicateManager.h"
#import "PredicateInspector.h"
#import "FormManager.h"

#define jgShowPredibaseVal 0

@implementation PredicateBrowser
/* copy & paste methods */
// siehe auch FormManager.m
- copyToPasteboard:pboard;
{
//    char *dataBuffer;
    NSData *dataBuffer;
//    int dataLen;
//    NXAtom typeList [2];
//    typeList [0] = PredFileType;
//    typeList [1] = [NSStringPboardType cString];
    NSArray *typeList = [NSArray arrayWithObjects:[NSString jgStringWithCString:PredFileType],NSStringPboardType,nil];

    [pboard declareTypes:typeList owner:self];

//    dataBuffer = NXWriteRootObjectToBuffer(selected, &dataLen);
//    [pboard setData:[NSData dataWithBytes:dataBuffer length:dataLen] forType:[NSString stringWithCString:PredFileType]];
    dataBuffer= [NSArchiver archivedDataWithRootObject:selected];
    [pboard setData:dataBuffer forType:[NSString jgStringWithCString:PredFileType]];	
//    NXFreeObjectBuffer(dataBuffer, dataLen);

    return self;
}

- (void)copy:(id)sender;
{
    if (selected) {
        [self copyToPasteboard:[NSPasteboard generalPasteboard]];
    } else
        NSBeep();
}

// for String-Representations
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
{
    if ([type isEqualToString:NSStringPboardType]) {
        NSString *firstType;
        const char *data;
        NSData *dataBuffer;
        int length, maxlen;
        id predicate;

// first the binary representation (produced by self) is got
        firstType = [sender availableTypeFromArray:[NSArray arrayWithObject:[NSString jgStringWithCString:PredFileType]]];
        if (firstType) {
            dataBuffer = [sender dataForType:firstType];
            if (dataBuffer) {
                predicate = [MyUnArchiver unarchiveObjectWithData:dataBuffer];
                if (predicate) {
// then it is written as ASCII.
                    JGStream *stream = JGOpenMemory(NULL,0,NX_READWRITE);
                    [predicate writeToMathStream:stream andTabs:0];
                    JGFlush(stream);
                    JGSeek(stream, 0L, NX_FROMSTART);
                    JGGetMemoryBuffer(stream, &data, &length, &maxlen);
                    [sender setString:stream forType:NSStringPboardType];
                    JGCloseMemory(stream, NX_FREEBUFFER);
//		    return self;
                }
            }
        }
    }
// jg: return nil is no longer meaningfull in Openstep classes 
}

- (void)cut:(id)sender;
{
    if (selected) {
        [self copyToPasteboard:[NSPasteboard generalPasteboard]];
        [self removePredicate:selected];
    } else
        NSBeep();
}

- (void)paste:(id)sender;
{
/* alt
    id pboard, predicate;
    char *dataBuffer;
    const char *firstType;
    int dataLen;
    NXAtom typeList [1];

    typeList [0] = PredFileType;

    pboard = [NSPasteboard generalPasteboard];
    firstType = [[pboard availableTypeFromArray:[NSArray arrayWithObject:[NSString stringWithCString:*typeList]]] cString];
    if (firstType) {
#error StreamConversion: 'dataForType:' (used to be 'readType:data:length:') returns an NSData instance
        if (&dataBuffer = [pboard dataForType:[NSString stringWithCString:firstType]]) {
#error ArchiverConversion: uses of typed streams should be converted to use NSArchiver and NSUnarchiver instead
            predicate = NXReadObjectFromBuffer(dataBuffer, dataLen);
            [self addPredicate:predicate];

        } else
            NSBeep();
    } else
        NSBeep();
    return self;
*/
// new, see FormManager.m
id pboard, predicate;
NSData *dataBuffer;
NSString *firstType;

pboard = [NSPasteboard generalPasteboard];
firstType = [pboard availableTypeFromArray:[NSArray arrayWithObject:[NSString jgStringWithCString:PredFileType]]];
if (firstType) {
    if (dataBuffer = [pboard dataForType:firstType]) {
        predicate = [MyUnArchiver unarchiveObjectWithData:dataBuffer];
        [self addPredicate:predicate];

    } else
        NSBeep();
} else
    NSBeep();
}

/* browser management */
#if 0
- row:(int *)aRow andColumn:(int *)aCol ofPredicate:aPredicate;
{/* This method tries to find the coordinates of aPredicate in the
  * currently selected tree. If aPredicate is not in this tree, no
  * further searching is done.
  */

    int row, col, column=-1, selCol;
    id predicate = myPredicateList;
    selCol = [browser selectedColumn];
    selCol = selCol>-1 ? selCol : 0;

        for (row=NSNotFound, col=0; col<=selCol+1; col++) {
            row = [predicate indexOfValue:aPredicate];
            column = col;
            if (row!=NSNotFound)
                break;
            predicate = [predicate getValueAt:[[browser matrixInColumn:col] selectedRow]];
        }

    column = row==NSNotFound ? -1 : column;
    row = row==NSNotFound ? -1 : row;
    *aRow = row;
    *aCol = column;

    return self;
}
#endif

- row:(int *)aRow andColumn:(int *)aCol ofPredicate:aPredicate;
{/* This method tries to find the coordinates of aPredicate in the
  * predicate tree. If aPredicate is not in this tree, no
  * further searching is done.
  */

    int row=-1, column=-1;
    id rowPred, predicate = [[self document] predicateList];

    for (column=-1; [predicate hasPredicate:aPredicate] && (predicate!=aPredicate); column++) {
        for (row=0; row<[predicate count]; row++) {
            rowPred = [predicate getValueAt:row];
            if (rowPred==aPredicate || [rowPred hasPredicate:aPredicate]) {
                predicate = rowPred;
                break;
            }
        }
    };
    column = predicate==[[self document] predicateList] ? -1 : column;

    if (column>-1) {	
        column = row==NSNotFound ? -1 : column;
        row = row==NSNotFound ? -1 : row;
    }
    *aRow = row;
    *aCol = column;

    return self;
}


- setSelected: aPredicate;
{
    id obj;
    int oldRow=-1, oldCol=-1, newRow = -1, newCol = -1;

    if (aPredicate) {/* only try to get row and col if not nil*/
        [self row:&newRow andColumn:&newCol ofPredicate:aPredicate];
    }
    if (selected) {/* only try to get row and col if not nil*/
        [self row:&oldRow andColumn:&oldCol ofPredicate:selected];
    }

    if ([obj=[self selectedInColumn:oldCol-1] hasPredicate:selected]&&[obj hasPredicate:aPredicate]) {
        [[browser matrixInColumn:newCol] selectCellAtRow:newRow column:0];
        [[browser matrixInColumn:newCol] sendAction];
    }
    else if (newRow>-1 && newCol>-1) {
        int row, col, cols, *rowList = NULL;
        id colMatrix, rowPred, predicate = [[self document] predicateList];

        /* get the row for every column, i.e. path to aPredicate */
        for (cols=0; [predicate hasPredicate:aPredicate]  && (predicate!=aPredicate); cols++) {
            rowList = realloc(rowList, cols+1*sizeof(int));
            rowList[cols] = -1;
            for (row=0; row<[predicate count]; row++) {
                rowPred = [predicate getValueAt:row];
                if (rowPred==aPredicate || [rowPred hasPredicate:aPredicate]) {
                    predicate = rowPred;
                    rowList[cols] = row;
                    break;
                }
            }
        };

        //[browser loadColumnZero];

        for (col=0; col<cols; col++) {
            colMatrix = [browser matrixInColumn:col];
            if ([colMatrix selectedRow]!=rowList[col]) {
                [colMatrix selectCellAtRow:rowList[col] column:0];
                [colMatrix sendAction];
            }
        }
    } else
        [browser loadColumnZero];

    selectedCell = [[browser matrixInColumn:newCol] selectedCell];

    selected = ((newRow>-1) ? aPredicate : nil);
    browserIsValid = browserIsValid && (newCol<=oldCol);
    [self invalidate];
    [[[self document] inspector] setSelected:selected];

    return self;
}

- setSelectedFrom:sender;
{
    int oldRow, oldCol, newCol = [sender selectedColumn];

    [self row:&oldRow andColumn:&oldCol ofPredicate:selected];
    selected = [self browser:sender selectedInColumn:[sender selectedColumn]];
    selectedCell = [sender selectedCell];
    browserIsValid = browserIsValid && (newCol<=oldCol);
//    if ([inspector manager]=self)
    [[[self document] inspector] setSelected: selected];
    return self;
}

- selected;
{
    return selected;
}

- setSelectedCell:sender;
{
    selectedCell = [sender selectedCell];
    return self;
}
- selectedCell;
{
    return selectedCell;
}

- jgRootPredicateAtRow:(int)row;
{
  switch (row) {
   case 0: return [[self document] predicateList]; break;
   case 1: return [[self document] formList]; break;
   case 2: return [[self document] rubetteList]; break;
   // case 3: return myWeightList; break; ist Refcountlist
   default: return nil;
  }
}


- selectedInColumn:(int)column;
 {
    int col;
    id predicate;

    if (!(column<0)) { /* if column is negativ there is nothing selected */
     if (jgShowPredibaseVal) {
        predicate = [self jgRootPredicateAtRow:[[browser matrixInColumn:0] selectedRow]];
        if (column==0) return predicate;
     } else {
       predicate=[[self document] predicateList];
     }
     for (col=0+jgShowPredibaseVal; col<=column; col++) {
            predicate = [predicate getValueAt:[[browser matrixInColumn:col] selectedRow]];
        }
        return predicate;
    }
    return nil;
 }

 - browser:sender selectedInColumn:(int)column;
{
    return [self browser:sender predicateAtRow:[[sender matrixInColumn:column] selectedRow] inColumn:column];
}


- browser:sender predicateAtRow:(int)row inColumn:(int)column;
{
   int col, selRow, i;
   id predicate;
    if (!(column<0)) { /* if column is negativ there is nothing selected */
     if(jgShowPredibaseVal) {
        selRow=[[sender matrixInColumn:0] selectedRow];
        if (column==0) return [self jgRootPredicateAtRow:row];
        predicate = [self jgRootPredicateAtRow:selRow];
     } else {
       predicate = [[self document] predicateList];
     }
        for (col=0+jgShowPredibaseVal; col<column; col++) {
            selRow = [[sender matrixInColumn:col] selectedRow];
            for (i=0; i<=selRow && [predicate hasPredicateAt:i]; i++);
            predicate = [predicate getValueAt:i-1];
        }

        for (i=0; i<=row && [predicate hasPredicateAt:i]; i++);
        return [predicate getValueAt:i-1];
    }
    return nil;
}

- (void)invalidate;
{
    [browser validateVisibleColumns];
}

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (jgShowPredibaseVal && (column==0)) {
      return 3;
    } else {
      if (column)
        return [[self browser:sender selectedInColumn:column-1] count];
      else
        return [[[self document]predicateList] count]; // old code
    }
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    GenericPredicate *predicate;
    NSString *str;
    NSString *role;
    id image, imageString = [[String alloc]init];
    int	index=0, i;
    predicate = [self browser:sender predicateAtRow:row inColumn: column];
    if (predicate) {
        if (column>0) {
          int fatherCol=column-1;
          int fatherRow=[[sender matrixInColumn:fatherCol] selectedRow];
          CompoundPredicate *father=[self browser:sender predicateAtRow:fatherRow inColumn:fatherCol];
          role=[[father form] roleAtIndex:row];
        } else
          role=[CompoundForm roleWithoutFather];

        if ([predicate isKindOfClass:[SimplePredicate class]]) {
/*	    const char *pnam=[predicate nameString], *pval=[[predicate stringValue] cString],
                                *delim = ": ";
            char * str = malloc(strlen(pnam)+strlen(pval)+strlen(delim)+1);
            strcpy(str, pnam);
            strcat(str, delim);
            strcat(str, pval);
*/
            str=[NSString stringWithFormat:@"%@:%@:%@: %@",role,[predicate name],[[predicate form] name], [predicate stringValue]];
            [cell setLoaded:YES];
            [cell setStringValue:str];  //[NSString jgStringWithCString:str]];
            [cell setLeaf:YES];
//	    free(str);
        } else {
          id theName;
            str=[NSString stringWithFormat:@"%@:%@:%@",    role,[predicate name],[[predicate form] name] ];
            [cell setLoaded:YES];
            [cell setStringValue:str];
            [cell setLeaf:NO];
            [imageString setStringValue:[NSString jgStringWithCString:[predicate typeString]]];
            theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageString stringValue]];
            image = [[NSImage alloc]initByReferencingFile:theName];
            if (image) {
                [cell setImage:image];
                [image release];
            }
            [imageString concat:"H"];
            theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageString stringValue]];
            image = [[NSImage alloc]initByReferencingFile:theName];
            if (image) {
                [cell setAlternateImage:image];
                [image release];
            }
        }
    } else { // jg?: is this case possible?
        if (!(row<0)) {
            /* don't call for negative rows */
            predicate = [self browser:sender selectedInColumn: column-1];
            if (predicate) {
                for (i=0, index=0; i<=row; index++)
                    if ([predicate hasPredicateAt:index])
                        i++;
                [cell setStringValue:[[predicate cellAtIndex:index-1] stringValue]];
                [cell setLoaded:YES];
                [cell setLeaf:YES];
            }
        }
    }
    [imageString release];
}

//- (const char *)browser:sender titleOfColumn:(int)column;
- (BOOL)browser:sender selectCellWithString:(NSString *)title inColumn:(int)column;
{
    int row=-1;
    id	matrix = [sender matrixInColumn:column];

    /*predicate = [self selectedInColumn:column];
    if (predicate) {
        if (column>0)
            row = [[self selectedInColumn:column-1] indexOfValue:predicate];
        else
            row = [myPredicateList indexOfValue:predicate];
    }
    */

    if ([matrix getRow:&row column:&column ofCell:selectedCell]) {
        [matrix selectCellAtRow:row column:0];
        return YES;
    } else
        return NO;
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
/* browserIsValid doesn't work to simply invalidate columns, because
*  if a column is invalidated, its selection is cleared.
*  This results in erratic browser behaviour, if all the
*  columns are invalidated every time some predicate was changed.
*/
    int selCol = [sender selectedColumn];
//#error ViewConversion: '-focusView' in NSApplication has been replaced by '+focusView' in NSView
    if (([NSView focusView] == [sender matrixInColumn:column]) || column<selCol || browserIsValid)
        return YES;
    else {
        if (column>selCol) {
            browserIsValid = YES;
        }
        return NO;
    }
}

//- browserWillScroll:sender;
//- browserDidScroll:sender;

@end
