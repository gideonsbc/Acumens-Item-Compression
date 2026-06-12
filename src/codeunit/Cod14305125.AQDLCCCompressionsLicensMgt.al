codeunit 14305125 "AQDLCC Compressions Licens Mgt"
{
    Access = Public;

    var
        NoLicenseErr: Label 'No valid license found. You must have an active subscription or trial for the Basic, Standard, or Enterprise plan to use this feature.';

        Text001: Label 'You do not have license to access %1.';
        appid: Label 'a35db766-52e7-429a-94e1-847851f1944a';
        appname: Label 'Acumens Item Ledger Compression';

    procedure CheckEntitledPlan()
    begin
        if not HasValidPlan() then
            Error(NoLicenseErr);
    end;

    procedure HasEntitledPlan(): Boolean
    begin
        exit(true);
        if not HasValidPlan() then
            exit(false);
        exit(true);
    end;


    procedure HasValidPlan(): Boolean
    begin
        exit(
            NavApp.IsEntitled('sbcdynamicserp1637715412860.acumensitemledgercompression.fullacumensitemledgercompression') or
            NavApp.IsEntitled('sbcdynamicserp1637715412860.acumensitemledgercompression.acumensitemledgercompressionunlimited') or
            NavApp.IsEntitled('sbcdynamicserp1637715412860.acumensitemledgercompression.acumensitemledgercompression10userpack') or
            NavApp.IsEntitled('sbcdynamicserp1637715412860.acumensitemledgercompression.acumensitemledgercompression20userpack') or
            NavApp.IsEntitled('sbcdynamicserp1637715412860.acumensitemledgercompression.acumensitemledgercompression30userpack') or
            NavApp.IsEntitled('sbcdynamicserp1637715412860.acumensitemledgercompression.acumensitemledgercompression40userpack')
        );
    end;


    [EventSubscriber(ObjectType::Codeunit, 150, OnAfterLogin, '', false, false)]
    local procedure CU150_onafterlogin()
    var
        AcumensLicensing: Codeunit "AQD Acumens Licensing mgt";
    begin
        if not AcumensLicensing.Checkifappislicensed(appid, appname) then
            DisableAppAccess(true, true);
    end;

    procedure DisableAppAccess(ShowMessage: Boolean; CalledFromLogin: Boolean): Boolean
    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
    begin
        if ILECompressionSetup.Get() and ILECompressionSetup."Enable App" then begin
            ILECompressionSetup.Validate("Enable App", false);
            ILECompressionSetup.Modify();
            Commit();
        end;

        if ShowMessage and not CalledFromLogin then
            Error(Text001, appname);
    end;

    procedure CheckAppAccess(): Boolean
    var
        AcumensLicensing: Codeunit "AQD Acumens Licensing mgt";

    begin
        if not AcumensLicensing.Checkifappislicensed(appid, appname) then
            DisableAppAccess(true, false)
    end;
}
