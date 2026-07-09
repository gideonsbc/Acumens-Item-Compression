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
                {
                    trigger OnValidate()
                    begin
                        if Rec."Enable App" then
                            InitializeApp(false);
                    end;
                }

                field("Cut-off Period"; Rec."Cut-off Period")
                {
                    ToolTip = 'Specifies the value of the Cut-off Period field.', Comment = '%';
                }
                field("Maximum Runtime (Hours)"; Rec."Maximum Runtime (Hours)")
                {
                    ToolTip = 'No. of Hours the compression runs per setup, before breaking to continue later';
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
                field(PlaceHolder1; '')
                {
                    ShowCaption = false;
                }
                field(PlaceHolder2; '')
                {
                    ShowCaption = false;
                }
                field(PlaceHolder3; '')
                {
                    ShowCaption = false;
                }
                field("Group by Lot No."; Rec."Group by Lot No.")
                {
                    Visible = false;
                }
                field("Group by Serial No."; Rec."Group by Serial No.")
                {
                    Visible = false;
                }
                field("Group by Package No."; Rec."Group by Package No.")
                {
                    Visible = false;
                }
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
            action("About App")
            {
                Image = AboutNav;
                ApplicationArea = All;
                ToolTip = 'Shows more information about the Acumens Item Ledger Compression App';
                Caption = 'About ILE Compression';
                RunObject = page "AQDLC About ILE Compression";
            }
            group(CompressResults1)
            {
                Caption = '&Compress Results';
                Image = Compress;
                action("&Compression Schedules")
                {
                    ApplicationArea = All;
                    Caption = 'Compression Schedules';
                    Image = List;
                    RunObject = Page "AQDLC ILE Compression Schedule";
                    ToolTip = 'View Item Compression Schedules';
                }
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
                action("&Run Compression Data Analysis")
                {
                    ApplicationArea = All;
                    Caption = 'Run Compression Data Analysis';
                    Image = Process;
                    RunObject = Report "AQDLC Compression Data Analys";
                    ToolTip = 'Analyzes inventory data prior to compression and identifies potential data integrity issues that may affect compression results.';
                }
                action("&Compression Analysis")
                {
                    ApplicationArea = All;
                    Caption = 'Compression Analysis';
                    Image = AnalysisView;
                    RunObject = Page "AQDLC Compression Analysis Rs";
                    ToolTip = 'Analyzes inventory data prior to compression and identifies potential data integrity issues that may affect compression results.';
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
            action("&Run Posted Documents Compression")
            {
                ApplicationArea = All;
                Caption = 'Run Posted Documents Compression';
                Image = Compress;
                RunObject = Report "AQDLC Posted Documents Compres";
                ToolTip = 'Date-Compresses Posted Documents';
            }
            action("&PostedDocsCompLog")
            {
                ApplicationArea = All;
                Caption = 'Posted Documents Compression Logs';
                Image = ListPage;
                RunObject = Page "AQDLC Posted Docs Compress Log";
                ToolTip = 'Posted Documents Compression Results';
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
                actionref(CompressionSchedules_Promoted; "&Compression Schedules")
                {
                }
                actionref(RunItemSelection_Promoted; "&Run Item Selection")
                {
                }
                actionref(ItemSelection_Promoted; "&Item Selection")
                { }
                actionref(RunCompressionDataAnalysis_Promoted; "&Run Compression Data Analysis")
                {
                }
                actionref(CompressionAnalysis_Promoted; "&Compression Analysis")
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
                actionref(RunPostedDocumentsCompression_Promoted; "&Run Posted Documents Compression")
                {
                }
                actionref(PostedDocsCompLog_Promoted; "&PostedDocsCompLog")
                {
                }
            }
            actionref(Aboutapp_About; "About App")
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        CompressionLicenseMgt: Codeunit "AQDLCC Compressions Licens Mgt";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            Error('Access denied. This page is restricted to system administrators.');

        CompressionLicenseMgt.CheckAppAccess();
        if not Rec.Get() then begin
            Rec.Init();
            if Confirm('Do you want to activate Acumens Item Ledger Compression Defaults?' + '\' + 'This may cause errors if the setup is not completed.') then
                InitializeApp(true)
            else begin
                Evaluate(Rec."Cut-off Period", '-7Y');
                Rec.Validate("Cut-off Period");
                Rec.Insert();
            end;
        end;
        if Format(Rec."Cut-off Period") = '' then begin
            Evaluate(Rec."Cut-off Period", '-7Y');
            Rec.Validate("Cut-off Period");
        end;
        Rec."Group by Item" := true;
    end;

    local procedure getAppId(): Guid
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        exit(ModuleInfo.Id);
    end;

    var
        Text000Txt: Label 'Initializing app...\\';
        Text001Txt: Label 'Assigning Permission sets:    #1#############\\';
        Text002Txt: Label 'Creating default parameters:    #2#############\\';
        Text003Txt: Label 'Creating compression schedule:    #3#############\\';
        Window: Dialog;

    procedure InitializeApp(ShowMessage: Boolean)
    var
        CFBaseEvents: Codeunit "AQD Acumens Base Events";
        AppId: Guid;
    begin
        Window.Open(Text000Txt + Text001Txt + Text002Txt + Text003Txt);
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec."Enable App" := true;
            Rec.Insert(true);
        end;
        Rec."Enable App" := true;

        Window.Update(1, 'AQDLC ILE Comprs Usr & AQDLC ILE Compress');
        AppId := getAppId();
        CFBaseEvents.AssignAppPermissionSetToAllUsers(AppId, 'AQDLC ILE Comprs Usr', true);
        CFBaseEvents.AssignAppPermissionSetToAllSuperUsers(AppId, 'AQDLC ILE Compress', true);

        Window.Update(2, 'Cut-off Period');
        UpdateDefaultParameters();
        Rec.Modify(true);

        Window.Update(3, '1');
        CreateInitialCompressionSchedule();

        if ShowMessage then
            Message('Initialization completed successfully!');
    end;

    local procedure UpdateDefaultParameters()
    begin
        Evaluate(Rec."Cut-off Period", '-7Y');
        Rec.Validate("Cut-off Period");
        Rec."Group by Item" := true;
        Rec."Group by Location Code" := true;
        Rec."Group by Variant Code" := true;
        Rec."Maximum Runtime (Hours)" := 10;
    end;

    local procedure CreateInitialCompressionSchedule()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        if CompressionSchedule.FindFirst() then exit;

        CompressionSchedule.Init();
        CompressionSchedule."Entry No." := 1;
        CompressionSchedule.Validate(Year, Date2DMY(Rec."Latest Valid December 31", 3));
        //CompressionSchedule.Validate("Cut-off Date", Rec."Latest Valid December 31");
        CompressionSchedule.Insert(true);
    end;

}
