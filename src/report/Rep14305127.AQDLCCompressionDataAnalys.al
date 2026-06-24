report 14305127 "AQDLC Compression Data Analys"
{
    ApplicationArea = All;
    Caption = 'Compression Data Analysis';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    Permissions = tabledata "Item Ledger Entry" = rimd;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := Today;

                if (CompressionScheduleNo <> 0) and SkipCompressedItems then
                    SetFilter("AQDLC Last Compression No.", '<>%1', CompressionScheduleNo);
                StartTime := CurrentDateTime;
                if ShowDialog then begin
                    Window.Open(Text001);
                end;
                //SimulateIssues(false);
            end;

            trigger OnAfterGetRecord()
            var
                ItemLedgers: Record "Item Ledger Entry";
                InvtValue: Decimal;
            begin
                if ShowDialog then begin
                    Counter += 1;
                    if (Counter MOD 100) = 0 then
                        Window.Update(1, "No." + ' => ' + Description + ' (' + Format((Counter DIV 100)) + '00)');
                end;

                DeleteItemPreviousAnalysisResults(Item);

                ItemLedgers.SetCurrentKey("Item No.", "Posting Date");
                ItemLedgers.SetRange("Item No.", "No.");
                ItemLedgers.SetFilter("Posting Date", '<=%1', AsOfDate);
                if ItemLedgers.FindSet() then
                    repeat
                        ItemLedgers.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");//"Sales Amount (Actual)", "Sales Amount (Expected)",
                        if ItemLedgers."Cost Amount (Actual)" <> 0 then
                            InvtValue := ItemLedgers."Cost Amount (Actual)"
                        else
                            InvtValue := ItemLedgers."Cost Amount (Expected)";

                        if not ItemLedgers."Completely Invoiced" then
                            CreateCompressionAnalysisResultEntry(Item, IssueType::"Unvoiced ILE", InvtValue);

                        /*if ItemLedgers.Quantity <> ItemLedgers."Remaining Quantity" then
                            CreateCompressionAnalysisResultEntry(Item, IssueType::"Remaining Qty & ILE Qty Mismatch", InvtValue);*/
                        CreateAndUpdateItemQtyVsRemaining(Item, ItemLedgers, InvtValue);

                        if (ItemLedgers.Quantity = 0) and (InvtValue <> 0) then
                            CreateCompressionAnalysisResultEntry(Item, IssueType::"Zero Quantity Non-Zero Value", InvtValue);

                    until ItemLedgers.Next() = 0;

                CheckItemRemQuantities(Item);
            end;

            trigger OnPostDataItem()
            begin
                //SimulateIssues(true);
                if not ShowDialog then exit;
                Window.Close();
                Message('Compression analysis completed. %1 issue(s) found!\Start Time: %2 End Time: %3\Duration: %4', Format(TotalIssuesFound), StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';

                    field(CompressionScheduleNo; CompressionScheduleNo)
                    {
                        Caption = 'Schedule No.';
                        TableRelation = "AQDLC ILE Compression Schedule";
                        ToolTip = 'The compression schedule to be executed after this analysis';

                        trigger OnValidate()
                        var
                            CompressionSchedule: Record "AQDLC ILE Compression Schedule";
                        begin
                            if CompressionScheduleNo = 0 then exit;

                            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                                AsOfDate := CompressionSchedule."Cut-off Date";
                                SkipCompressedItems := true;
                                CurrReport.RequestOptionsPage.Update(false);
                            end;
                        end;
                    }
                    field(AsOfDate; AsOfDate)
                    {
                        Caption = 'As at Date';
                        ShowMandatory = true;
                        ApplicationArea = All;
                        Editable = (CompressionScheduleNo <> 0);

                        trigger OnValidate()
                        begin
                            if CompressionScheduleNo <> 0 then
                                Error('Date will be picked from the selected schedule!');
                        end;
                    }
                    group(SkipCompressedItemsGrp)
                    {
                        ShowCaption = false;
                        Visible = (CompressionScheduleNo <> 0);
                        field(SkipCompressedItems; SkipCompressedItems)
                        {
                            Caption = 'Skip Compressed Items';
                            ApplicationArea = All;
                            ToolTip = 'Items already compressed in the selected schedule will be skipped';
                        }
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    trigger OnInitReport()
    begin
        if not (ILECompressionSetup.Get() and ILECompressionSetup."Enable App") then
            Error('Acumens Item Ledger Compression App is not enabled');

        if CompressionScheduleNo = 0 then
            GetApplicableCompressionSchedule();

        if CompressionScheduleNo <> 0 then begin
            SkipCompressedItems := true;
            if CompressionSchedule.Get(CompressionScheduleNo) then
                AsOfDate := CompressionSchedule."Cut-off Date";
        end;
        ShowDialog := GuiAllowed;

    end;

    trigger OnPreReport()
    begin
    end;

    trigger OnPostReport()
    var
        vCompressionAnalysisRs: Record "AQDLC Compression Analysis Res";
    begin
        if GuiAllowed then begin
            if TotalIssuesFound = 0 then exit;
            vCompressionAnalysisRs.Reset();
            Page.Run(Page::"AQDLC Compression Analysis Rs", vCompressionAnalysisRs);
        end;
    end;

    procedure SetRunParameters(vCompressionScheduleNo: Integer)
    begin
        CompressionScheduleNo := vCompressionScheduleNo;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        CompressionScheduleNo: Integer;
        SkipCompressedItems: Boolean;
        AsOfDate: Date;
        IssueType: Enum "AQDLC Compression Analysis Iss";
        Window: Dialog;
        Text001: Label 'Processing Item No.  ########1#####';
        ShowDialog: Boolean;
        TotalIssuesFound: Integer;
        TotalCount: Integer;
        Counter: Integer;

    local procedure GetApplicableCompressionSchedule()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
        MaxCutoffDate: Date;
    begin
        MaxCutoffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
        CompressionSchedule.SetCurrentKey("Cut-off Date");
        CompressionSchedule.SetFilter("Cut-off Date", '<=%1', MaxCutoffDate);
        CompressionSchedule.SetAscending("Cut-off Date", false);
        if CompressionSchedule.FindFirst() then
            CompressionScheduleNo := CompressionSchedule."Entry No.";
    end;

    var
        ItemILEQty: Decimal;
        ItemILERemQty: Decimal;
        ItemInvtVal: Decimal;

    local procedure ClearItemQtyValues()
    begin
        ItemILEQty := 0;
        ItemILERemQty := 0;
        ItemInvtVal := 0;
    end;

    local procedure DeleteItemPreviousAnalysisResults(vItem: Record Item)
    var
        CompAnalysisResult: Record "AQDLC Compression Analysis Res";
        ItemQtyvsRemn: Record "AQDLC Item Quantity vs Remn";
    begin
        CompAnalysisResult.SetRange("Item No.", vItem."No.");
        CompAnalysisResult.SetRange("Schedule No.", CompressionScheduleNo);
        CompAnalysisResult.SetRange("As of Date", AsOfDate);
        CompAnalysisResult.DeleteAll();

        ItemQtyvsRemn.SetRange("Item No.", vItem."No.");
        ItemQtyvsRemn.SetRange("Schedule No.", CompressionScheduleNo);
        ItemQtyvsRemn.SetRange("As of Date", AsOfDate);
        ItemQtyvsRemn.DeleteAll();

        ClearItemQtyValues();
    end;

    local procedure CreateCompressionAnalysisResultEntry(vItem: Record Item; vIssueType: Enum "AQDLC Compression Analysis Iss"; InvtValue: Decimal)
    var
        CompAnalysisResult: Record "AQDLC Compression Analysis Res";
    begin
        TotalIssuesFound += 1;
        CompAnalysisResult.SetRange("Item No.", vItem."No.");
        CompAnalysisResult.SetRange("Schedule No.", CompressionScheduleNo);
        CompAnalysisResult.SetRange("As of Date", AsOfDate);
        CompAnalysisResult.SetRange("Issue Type", vIssueType);
        if CompAnalysisResult.Find('-') then begin
            CompAnalysisResult."Total Count" += 1;
            CompAnalysisResult."Total Value" += InvtValue;
            CompAnalysisResult.Modify();
        end else begin
            CompAnalysisResult.Init();
            CompAnalysisResult."Item No." := vItem."No.";
            CompAnalysisResult.Description := vItem.Description;
            CompAnalysisResult."Schedule No." := CompressionScheduleNo;
            CompAnalysisResult."As of Date" := AsOfDate;
            CompAnalysisResult."Issue Type" := vIssueType;
            CompAnalysisResult."Total Count" := 1;
            CompAnalysisResult."Total Value" := InvtValue;
            CompAnalysisResult.Insert(true);
        end;
    end;

    local procedure CreateAndUpdateItemQtyVsRemaining(vitem: Record Item; vitemLedger: Record "Item Ledger Entry"; vInvtValue: Decimal)
    var
        ItemQtyvsRemn: Record "AQDLC Item Quantity vs Remn";
    begin
        ItemILEQty += vitemLedger.Quantity;
        ItemILERemQty += vitemLedger."Remaining Quantity";
        ItemInvtVal += vInvtValue;

        ItemQtyvsRemn.SetCurrentKey("Item No.", "Schedule No.", "Location Code", "Variant Code");
        ItemQtyvsRemn.SetRange("Item No.", vitemLedger."Item No.");
        ItemQtyvsRemn.SetRange("Schedule No.", CompressionScheduleNo);
        if ILECompressionSetup."Group by Location Code" then
            ItemQtyvsRemn.SetRange("Location Code", vitemLedger."Location Code");
        if ILECompressionSetup."Group by Variant Code" then
            ItemQtyvsRemn.SetRange("Variant Code", vitemLedger."Variant Code");
        if ILECompressionSetup."Group by Lot No." then
            ItemQtyvsRemn.SetRange("Lot No.", vitemLedger."Lot No.");
        if ILECompressionSetup."Group by Serial No." then
            ItemQtyvsRemn.SetRange("Serial No.", vitemLedger."Serial No.");
        if ILECompressionSetup."Group by Package No." then
            ItemQtyvsRemn.SetRange("Package No.", vitemLedger."Package No.");
        ItemQtyvsRemn.SetRange("Location Code");
        if ItemQtyvsRemn.Find('-') then begin
            ItemQtyvsRemn.Quantity += vitemLedger.Quantity;
            ItemQtyvsRemn."Remaining Quantity" += vitemLedger."Remaining Quantity";
            ItemQtyvsRemn."Inventory Value" += vInvtValue;
            ItemQtyvsRemn.Difference := ItemQtyvsRemn.Quantity - ItemQtyvsRemn."Remaining Quantity";
            ItemQtyvsRemn.Modify();
        end else begin
            ItemQtyvsRemn.Init();
            ItemQtyvsRemn."Item No." := vitemLedger."Item No.";
            ItemQtyvsRemn."Schedule No." := CompressionScheduleNo;
            ItemQtyvsRemn."As of Date" := AsOfDate;
            if ILECompressionSetup."Group by Location Code" then
                ItemQtyvsRemn."Location Code" := vitemLedger."Location Code";
            if ILECompressionSetup."Group by Variant Code" then
                ItemQtyvsRemn."Variant Code" := vitemLedger."Variant Code";
            if ILECompressionSetup."Group by Lot No." then
                ItemQtyvsRemn."Lot No." := vitemLedger."Lot No.";
            if ILECompressionSetup."Group by Serial No." then
                ItemQtyvsRemn."Serial No." := vitemLedger."Serial No.";
            if ILECompressionSetup."Group by Package No." then
                ItemQtyvsRemn."Package No." := vitemLedger."Package No.";
            ItemQtyvsRemn.Quantity += vitemLedger.Quantity;
            ItemQtyvsRemn."Remaining Quantity" += vitemLedger."Remaining Quantity";
            ItemQtyvsRemn."Inventory Value" += vInvtValue;
            ItemQtyvsRemn.Difference := ItemQtyvsRemn.Quantity - ItemQtyvsRemn."Remaining Quantity";
            ItemQtyvsRemn.Insert(true);
        end;
    end;

    local procedure CheckItemRemQuantities(vItem: Record Item)
    var
        ItemQtyvsRemn: Record "AQDLC Item Quantity vs Remn";
        UnitCost: Decimal;
        Diff: Decimal;
    begin
        if ItemILEQty = ItemILERemQty then begin
            ItemQtyvsRemn.SetRange("Item No.", vItem."No.");
            ItemQtyvsRemn.SetRange("Schedule No.", CompressionScheduleNo);
            ItemQtyvsRemn.SetRange("As of Date", AsOfDate);
            ItemQtyvsRemn.DeleteAll();
        end else begin
            Diff := ItemILEQty - ItemILERemQty;
            if ItemILEQty <> 0 then
                UnitCost := Abs(ItemInvtVal / ItemILEQty)
            else begin
                if ItemILERemQty <> 0 then
                    UnitCost := Abs(ItemInvtVal / ItemILERemQty);
            end;
            if Diff <> 0 then
                ItemInvtVal := Abs(Diff * UnitCost)
            else
                ItemInvtVal := 0;
            CreateCompressionAnalysisResultEntry(vItem, IssueType::"Remaining Qty & ILE Qty Mismatch", ItemInvtVal);
        end;
        ClearItemQtyValues();
    end;

    local procedure SimulateIssues(Revert: Boolean)
    var
        ILE: Record "Item Ledger Entry";
    begin
        if not Revert then begin
            if ILE.Get(3784) then begin
                ILE."Remaining Quantity" -= 1;
                ILE.Modify();
            end;
            if ILE.Get(3785) then begin
                ILE.Quantity := 0;
                ILE.Modify();
            end;
        end;

        if Revert then begin
            if ILE.Get(3784) then begin
                ILE."Remaining Quantity" += 1;
                ILE.Modify();
            end;
            if ILE.Get(3785) then begin
                ILE.Quantity := ILE."Remaining Quantity";
                ILE.Modify();
            end;
        end;
    end;

}
