- (void)dealloc;
{
    [myWeightFunctionPanel performClose:self];
    [myWeightFunctionPanel release]; myWeightFunctionPanel = nil;
    [myWeightViewPanel performClose:self];
    [myWeightViewPanel release]; myWeightViewPanel = nil;
    [myGraphicPrefsPanel performClose:self];
    [myGraphicPrefsPanel release]; myGraphicPrefsPanel = nil;
    [super dealloc];
}
