// To compile under a version previous to mac os X, define PRE_MAC_OS_X.
// this will include the EO-Version of Key-Value-coding instead of NS-Version, which was moved there in
// Version 1.0 of Mac OS X.

// old:
// You must #define one of the following macros to compile conditionally: 
// JG_MAC_OS_X, JG_MAC_OS_X_SERVER
// needed for key value coding!


Planned:
KVDictOfPlistWrapper
- initWithDict:d
- attributeKeys; 
  [dict "allKeysWithStringOrDataValue"]
- toOneRelationshipKeys
  [dict "allKeysWithDictValue"]
- toManyRelationshipKeys
  [dict "keysWithArrayValue"] (muessen diese wiederum vom Typ Dict sein?)

