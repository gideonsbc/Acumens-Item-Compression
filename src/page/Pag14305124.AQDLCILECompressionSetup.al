page 14305124 "AQDLC ILE Compression Setup"
{
    ApplicationArea = All;
    Caption = 'Acumens Item Ledger Compression Setup';
    PageType = Card;
    SourceTable = "AQDLC ILE Compression Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable App"; Rec."Enable App")
                { }

                field("Cut-off Period"; Rec."Cut-off Period")
                {
                    ToolTip = 'Specifies the value of the Cut-off Period field.', Comment = '%';
                }
            }
            group(CompressionGroupFields)
            {
                Caption = 'Compression Group Fields';
                field("Group by Item"; Rec."Group by Item")
                {
                    Editable = false;
                }
                field("Group by Location Code"; Rec."Group by Location Code")
                { }
                field("Group by Variant Code"; Rec."Group by Variant Code")
                { }
                field("Group by Lot No."; Rec."Group by Lot No.")
                { }
                field("Group by Serial No."; Rec."Group by Serial No.")
                { }
                field("Group by Package No."; Rec."Group by Package No.")
                { }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("Initialize App")
            {
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Performs init operations';
                Caption = 'Initialize App';
                trigger OnAction()
                begin
                    InitializeApp(true);
                end;
            }
            /*action("About App")
            {
                Image = Info;
                ApplicationArea = All;
                ToolTip = 'Shows more information about the Acumens Freight, Duties & Tariffs App';
                Caption = 'About the App';
                RunObject = page "AQD About Acumens Tariff App";
            }*/
            group(CompressResults1)
            {
                Caption = '&Compress Results';
                Image = Compress;
                action("&Run Item Selection")
                {
                    ApplicationArea = All;
                    Caption = 'Run Item Selection';
                    Image = SelectReport;
                    RunObject = Report "AQDLC Compress Item Selection";
                    ToolTip = 'Run Compression Item Selection';
                }
                action("&Item Selection")
                {
                    ApplicationArea = All;
                    Caption = 'Item Selection';
                    Image = List;
                    RunObject = Page "AQDLC Compression Item Selectn";
                    ToolTip = 'View Compression Item Selection';
                }
                action("&Run Compression")
                {
                    ApplicationArea = All;
                    Caption = 'Run Compression';
                    Image = Compress;
                    RunObject = Report "AQDLC Date Compress Item Ledg";
                    ToolTip = 'Run Date Compress Item Ledger';
                }
                action("&Compression Registers")
                {
                    ApplicationArea = All;
                    Caption = 'Compression Registers';
                    Image = List;
                    RunObject = Page "AQDLC ILE Compression Regs";
                    ToolTip = 'View ILE Compression Registers';
                }
                action("&Quantity on Hand")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity on Hand';
                    Image = List;
                    RunObject = Page "AQDLC Quantity on Hand";
                    ToolTip = 'View Quantity on Hand';
                }
                action("&Valuation Comparison")
                {
                    ApplicationArea = All;
                    Caption = 'Valuation Comparison';
                    Image = List;
                    RunObject = Page "AQDLC Item Valuation Comparisn";
                    ToolTip = 'View Item Valuation Comparison';
                }
            }
            group(ItemCostAdjustment)
            {
                Caption = '&Item Cost Adjustment';
                Image = Compress;
                action("&Adjust Cost - Item Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Adjust Cost - Item Entries';
                    Image = AdjustItemCost;
                    RunObject = Report "Adjust Cost - Item Entries";
                    ToolTip = 'Run Adjust Cost - Item Entries';
                }
                action("&Post Inventory Cost to G/L")
                {
                    ApplicationArea = All;
                    Caption = 'Post Inventory Cost to G/L';
                    Image = PostDocument;
                    RunObject = Report "Post Inventory Cost to G/L";
                    ToolTip = 'Run Post Inventory Cost to G/L';
                }
                action("&Inventory Valuation")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Valuation Report';
                    Image = PostDocument;
                    RunObject = Report "Inventory Valuation";
                    ToolTip = 'Run Inventory Valuation Report';
                }
            }
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(InitializeApp_Home; "Initialize App")
                {
                }
                separator("ItemSelection") { }
                actionref(RunItemSelection_Promoted; "&Run Item Selection")
                {
                }
                actionref(ItemSelection_Promoted; "&Item Selection")
                { }
                separator("Compression") { }
                actionref(RunCompression_Promoted; "&Run Compression")
                {
                }
                actionref(CompressionRegisters_Promoted; "&Compression Registers")
                {
                }
                actionref(ValuationComparison_Promoted; "&Valuation Comparison")
                {
                }
                actionref(QoH_Promoted; "&Quantity on Hand")
                {
                }
                separator("CostAdjustment") { }
                actionref(AdjustCost_ItemEntries_Promoted; "&Adjust Cost - Item Entries")
                {
                }
                actionref(PostInventoryCosttoGL_Promoted; "&Post Inventory Cost to G/L")
                {
                }
                actionref(InventoryValuation_Promoted; "&Inventory Valuation")
                {
                }
            }
            group(About)
            {
                Caption = 'About', Comment = 'Generated from the PromotedActionCategories property index 5.';

                /*actionref(Aboutapp_About; "About App")
                {
                }*/
            }
        }
    }

    trigger OnOpenPage()
    var
        //TariffsLicenseMgt: Codeunit "AQD Tariffs License Mgt";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            Error('Access denied. This page is restricted to system administrators.');

        //TariffsLicenseMgt.CheckAppAccess();
        if not Rec.Get() then begin
            Rec.Init();
            Evaluate(Rec."Cut-off Period", '-7Y');
            Rec.Insert();
        end;
        if Format(Rec."Cut-off Period") = '' then
            Evaluate(Rec."Cut-off Period", '-7Y');
        Rec."Group by Item" := true;
    end;

    local procedure getAppId(): Guid
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        exit(ModuleInfo.Id);
    end;

    procedure InitializeApp(ShowMessage: Boolean)
    var
        CFBaseEvents: Codeunit "AQD Acumens Base Events";
        AppId: Guid;
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert(true);
        end;

        AppId := getAppId();
        CFBaseEvents.AssignAppPermissionSetToAllUsers(AppId, 'AQDLC ILE Compress', true);

        if ShowMessage then
            Message('Initialization completed successfully!');
    end;

}
