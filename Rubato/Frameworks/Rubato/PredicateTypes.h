/* PredicateTypes.h */

// defaultName is used in Interface of NSUserDefaults.
#define predibaseDefaultName "Predicate Name"
#define ns_predibaseDefaultName @"Predicate Name"

// to be removed
#define type_Generic "GENERIC"
#define type_Empty "EMPTY"
#define type_Int "INTEGER"
#define type_Float "FLOATING"
#define type_Fract "FRACTION"
#define type_Bool "BOOLEAN"
#define type_String "STRING"
#define type_Musical "MUSICAL"
#define type_Predicate "PREDICATE"
#define type_Product "PRODUCT"
#define type_Coproduct "COPRODUCT"
#define type_Subset "SUBSET"
#define type_List "LIST"

// replacement
#define ns_type_Generic @"GENERIC"
#define ns_type_Empty @"EMPTY"
#define ns_type_Int @"INTEGER"
#define ns_type_Float @"FLOATING"
#define ns_type_Fract @"FRACTION"
#define ns_type_Bool @"BOOLEAN"
#define ns_type_String @"STRING"
#define ns_type_Musical @"MUSICAL"
#define ns_type_Predicate @"PREDICATE"
#define ns_type_Product @"PRODUCT"
#define ns_type_Coproduct @"COPRODUCT"
#define ns_type_Subset @"SUBSET"
#define ns_type_List @"LIST"

// jg: perhaps more efficient?
#define typeTag_Generic 1
#define typeTag_Empty 2
#define typeTag_Int 3
#define typeTag_Float 4
#define typeTag_Fract 5
#define typeTag_Bool 6
#define typeTag_String 7
#define typeTag_Musical 8
#define typeTag_Predicate 9
#define typeTag_Product 10
#define typeTag_Coproduct 11
#define typeTag_Subset 12
#define typeTag_List 13

#define PRODUCT_OF "Product of "
#define SUBSET_OF "Set of "
#define COPRODUCT_OF "Coproduct of "

#define ALL_LEVELS -2
#define NO_TABS -1

/* definition of file types */
// to be removed
#define PredFileType "pred"
#define FormFileType "form"
#define PListFileType "plist"

// replacement
#define ns_PredFileType @"pred"
#define ns_FormFileType @"form"
#define ns_PListFileType @"plist"
