/* ChordInspector.h */
#import <Rubato/GenericObjectInspector.h>

@interface ChordInspector:GenericObjectInspector
{
    id	myPitchClassView;
    id	myPitchCountField;
    id	myRiemannMatrix;
    id	myBestPathLocusField;
    id	myOnsetField;
    id	myThirdStreamNamesMatrix;
    id	myThirdStreamMatrix;
    id	myThirdStreamCountField;
    id	myThirdStreamNumField;
    int curThirdStreamIndex;
}

- init;
- (void)dealloc;

- (void)setValue:(id)sender;
- displayPatient:sender;
- displayNextThirdStream:sender;
- displayThirdStreamAt:(int)index;

@end
