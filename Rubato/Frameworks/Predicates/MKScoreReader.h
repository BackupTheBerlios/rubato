/* MKScoreReader.h */

#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/FormListProtocol.h>

//#ifdef WITHMUSICKIT
//#import <MusicKit/MusicKit.h> // imports Object.h, so only use classes in interface
//#endif
@class MKScore;
@class MKPart;
@class MKNote;

@interface MKScoreReader:JgObject
{
    id owner;
    id	myListForm;
    id	myValueForm;
}

- init;
- (void)dealloc;
- (void)awakeFromNib;

- (void)setFormManager:(id<FormListProtocol>)aFormManager;
#ifdef WITHMUSICKIT
/* MusicKit to PrediKit object translation */
- makePredFromMKScore:(MKScore *)aScore withName:(const char *)aName;
- makePredFromMKPart:(MKPart *)aPart withName:(const char *)aName;
- makePredFromMKNote:(MKNote *)aNote withName:(const char *)aName;
#endif
@end