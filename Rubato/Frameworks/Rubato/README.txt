Files in the main directory do not depend on those in the AppKit and ObjectInspector subprojects and might be linked only against Foundation
Files in AppKit make it necessary to import many Frameworks.

Protocols:
Inspectable.h : <Inspectable>, <Inspector>

NibDrivenRubetteDriver.h: (now in .framework)
@protocol ExtendedRubetteDriver <RubetteDriver>
@protocol RubetteObjectInitialization

MathMatrixProtocols.h
@protocol MatrixAccess
@protocol MatrixEventProtocol


Better file locations:
RubatoTypes -> musical Types, define them, where You use them.
SpaceTypes
FormListProtocol
MathMatrixProtocols
RubetteTypes (#if 0 weightList)
RubatoController (merge with Distributor?)
PredicateTypes -> Predicate-Framework