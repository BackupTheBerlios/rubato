/* General purpose macro definitions */

// jg: It should be sufficient, to insert here the talkative names. Possible would also be exceptionUserInfo.
#define LOAD_HANDLER NSRunAlertPanel([localException name], \
                                        [localException reason],\
                                        @"", nil, nil);\
                     returnValue = nil;
