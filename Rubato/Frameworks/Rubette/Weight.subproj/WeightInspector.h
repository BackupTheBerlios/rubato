
#import <Rubato/NamedObjectInspector.h>

@interface WeightInspector:NamedObjectInspector
{
    id	myToleranceField;
    id	myLowNormField;
    id	myHighNormField;
    id	myInvertSwitch;
    id	myMinField;
    id	myMaxField;
    id	myMeanField;
    id	myNormMeanField;
    id	myFrameMatrix;
    
    id	myWeightParametersText;
    
    id	myWeightView;
    id	myDeformationField;
  IBOutlet NSButton *drawLinesSwitch;
}

- setValue:sender;
- displayPatient:sender;

@end
