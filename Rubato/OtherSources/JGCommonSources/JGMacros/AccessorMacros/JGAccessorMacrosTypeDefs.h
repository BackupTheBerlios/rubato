typedef enum accessor_keyKind_enum
{
  noKey=0,
  attributeKey,
  toOneRelationShipKey,
  toManyRelationShipKey
} accessor_keyKind;

typedef struct accessor_info_struct
{
  int transient;
  accessor_keyKind keyKind;
  // ...
} accessor_info;

