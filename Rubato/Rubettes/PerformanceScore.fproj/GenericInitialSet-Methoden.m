
/* Condition for performing hit method */
- (BOOL)isProClo:(spaceIndex)aSpace over:(spaceIndex)simplexSpace;
{
    spaceIndex cloSpace = [self hierarchyClosureOf:simplexSpace];
    
    return	subsub(simplexSpace,cloSpace,aSpace);
}



/* here is a C-array for ordering of the 64 hierarchy spaces */
int ord[Hierarchy_Size];
//0-dim:
ord[0] = 0;
//1-dim:
ord[1] = 1;	/*000001*/
ord[2] = 2;	/*000010*/
ord[3] = 4;	/*000100*/
ord[4] = 8;	/*001000*/
ord[5] = 16;	/*010000*/
ord[6] = 32;	/*100000*/
//2-dim:
ord[7] = 3;	/*000011*/
ord[8] = 5;	/*000101*/
ord[9] = 6;	/*000110*/
ord[10] = 9;	/*001001*/
ord[11] = 10;	/*001010*/
ord[12] = 12;	/*001100*/
ord[13] = 17;	/*010001*/
ord[14] = 18;	/*010010*/
ord[15] = 20;	/*010100*/
ord[16] = 24;	/*011000*/
ord[17] = 33;	/*100001*/
ord[18] = 34;	/*100010*/
ord[19] = 36;	/*100100*/
ord[20] = 40;	/*101000*/
ord[21] = 48;	/*110000*/
//3-dim:
ord[22] = 7;	/*000111*/
ord[23] = 11;	/*001011*/
ord[24] = 13;	/*001101*/
ord[25] = 14;	/*001110*/
ord[26] = 19;	/*010011*/
ord[27] = 21;	/*010101*/
ord[28] = 22;	/*010110*/
ord[29] = 25;	/*011001*/
ord[30] = 26;	/*011010*/
ord[31] = 28;	/*011100*/
ord[32] = 35;	/*100011*/
ord[33] = 37;	/*100101*/
ord[34] = 38;	/*100110*/
ord[35] = 41;	/*101001*/
ord[36] = 42;	/*101010*/
ord[37] = 44;	/*101100*/
ord[38] = 49;	/*110001*/
ord[39] = 50;	/*110010*/
ord[40] = 52;	/*110100*/
ord[41] = 56;	/*111000*/
//4-dim:
ord[42] = 15;	/*001111*/
ord[43] = 23;	/*010111*/
ord[44] = 27;	/*011011*/
ord[45] = 29;	/*011101*/
ord[46] = 30;	/*011110*/
ord[47] = 39;	/*100111*/
ord[48] = 43;	/*101011*/
ord[49] = 45;	/*101101*/
ord[50] = 46;	/*101110*/
ord[51] = 51;	/*110011*/
ord[52] = 53;	/*110101*/
ord[53] = 54;	/*110110*/
ord[54] = 57;	/*111001*/
ord[55] = 58;	/*111010*/
ord[56] = 60;	/*111100*/
//5-dim:
ord[57] = 31;	/*011111*/
ord[58] = 47;	/*101111*/
ord[59] = 55;	/*110111*/
ord[60] = 59;	/*111011*/
ord[61] = 61;	/*111101*/
ord[62] = 62;	/*111110*/
//6-dim:
ord[63] = 63;	/*111111*/



/* need a pointer for default success in a C-file*/
double startsuccess[MAX_SPACE_DIMENSION];
startsuccess[0] = -1;
startsuccess[1] = -1;
startsuccess[2] = -1;
startsuccess[3] = -1;
startsuccess[4] = -1;
startsuccess[5] = -1;



/* Now, for the doPerform method, we have to update 
 * the variable myFlatInitialSet
 *by the above flatteing method! 
 */
 
 - doPerform;
{
    int i, c = [myKernel count];
    char text[256];
    id perfEventi;
    id progressPanel = [NSBundle loadNibNamed:@"Progress.nib" owner:self];
 
    myFlatInitialSet = [myinitialSet flatten]; <<<=====
       
    [self invalidate];
    ...
    ...
}

     

/* new GFO-SONY method, here, we know a priori that there is a mother! 
 * See performanceOf:and: method in this file
 * We need the flattened initialSet variable myFlatInitialSet 
 * of this operator. By construction, this is a brute list of InitialSimplexes
 */
- initialSetPerformanceOfEvent:anEvent andInitialSet:anInitialSet;
{
    int 	i, 
    		c = [anInitialSet listCount],
     		dim = [anEvent dimension];
		
    /* initialize the success index to overall failure */
    double successIndex[MAX_SPACE_DIMENSION] = (double *)-1;
 
    id bestInitialSet = nil, projEvent = nil, result=nil, iResult=nil, delta;

    /* We want to get a result within the event space and 
     * start with a clone of the mother©s performance, the "worst case"
     */

    //result = [[myMother performanceOfEvent:anEvent andInitialSet:[myMother initialSet]] clone];
    
    /* Don't quite agree with this approach. The result should be obtained from Mother
     * by a separate method (-performedEventAt:), or retrived from the PerformanceTable.
     * Also, what if Mother's performance is no success? We should then quit right here.
     */

    
    projEvt = [[anEvent projectTo:[anInitialSet space]]ref];
    result = [(id)[myPerformanceTable valueForKey:projEvt]clone];
    [projEvt release];
    
    if(!result) {
	result = [myMother performedEventAt:anEvent];
	/* first, check for very near initial simplices and evaluate them */
	for(i=0; i<c; i++){
	/* check success status */
	    for(j=1;j<=dim && !successIndex[[anEvent indexOfDimension:j]]; j++);
	    if(j<=dim){ 
		if(bestInitialSet = [[anInitialSet initialSetAt:i] veryNearInitialSetTo:anEvent]){
		    /* this implies that projection of anEvent to bestInitialSet is possible ! */ 
		    projEvent = [anEvent projectTo:[bestInitialSet space]];
		    iResult = [self calcInitPerfOfEvent:projEvent atInitialSet:bestInitialSet];
			if(![iResult doubleValue]){
			    /* this success has to be evaluated on the coordinates of this simplex */
			    int dimi = [bestInitialSet dimension];
			    for(j=1; j<=dimi; j++){
				int indexj = [bestInitialSet indexOfDimension:j];
				successIndex[indexj] = 0;
				[result setDoubleValue:[iResult doubleValueAtIndex:indexj] atIndex:indexj];
				}
			    }  
		    [iResult release];
		    [projEvent release];
		}
	    }
	}
    } else
	myHashHits++;


    /* now, try to hit the initial simplices and not SONY */
    for(i=0; i<c; i++){
    /* check success status */
	for(j=1;j<=dim && !successIndex[[anEvent indexOfDimension:j]]; j++);
	if(j<=dim){ 
	    id	iSimplex = [[anInitialSet initialSetAt:i] simplex],
		ihitObject = [self hitPointFromEvent:anEvent onSimplex:iSimplex];
	    int dimi = [iSimplex dimension];
	    double success = successOf(ihitObject);
	
	    if(success || !ihitObject) {/* success bad! */
		success = ihitObject ? success : -1;
    
		[ihitObject freeObjects];
		[ihitObject release];	
	    }
	    else { 
		/* initial performance of hitPoint */
		id initPerf = [self calcInitPerfOfEvent:eventOf(ihitObject) at:iSimplex]
	
		/* no success for initial performance of hitPoint */
		if(success = [initPerf doubleValue]){ 
		    [ihitObject freeObjects];
		    [ihitObject release];	
		} else {
		    delta = [[MatrixEvent alloc] initWithSpace:[anInitialSet space] andValue:1.0];
	
		    /* scale delta by hitParameter */
		    delta = [delta scaleBy:-timeOf(ihitObject)]; 
	
		    iResult = [initPerf shiftBy:delta];
	
		    /* update the new successful coordinates of the performance */
		    for(j=1; j<=dimi; j++){
			int indexj = [iSimplex indexOfDimension:j];
			if(successIndex[indexj])
			    [result setDoubleValue:[iResult doubleValueAt:j-1] atIndex:indexj];
		    }
		    [ihitObject freeObjects];
		    [ihitObject release];	
		}
	    }
	    /* update the success pointer for the ith step*/
	    for(j=1; j<=dimi; j++){
		int indexj = [iSimplex indexOfDimension:j];
		if(successIndex[indexj])
		    successIndex[indexj] = success;
	    }
	}
    }

    /* set the finale success to be the maximum of the non-zero sucess indices if any */
    for(j=1, success = 0; j<=dim; j++){
	double sucj = successIndex[[anEvent indexOfDimension:j]];
	if(0<sucj || 0<success) 
	    success = max(success, sucj);
	else
	    success = min(success, sucj);
	}
	[result setDoubleValue:success];
        
    return result;
}
	
