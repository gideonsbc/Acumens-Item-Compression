report 14305135 "AQDLC Date Compress Item Ledg"
{
    ApplicationArea = All;
    Caption = 'Date Compress Item Ledger';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    Permissions = tabledata "Item Ledger Entry" = rimd,
                    tabledata "Avg. Cost Adjmt. Entry Point" = rimd,
                    tabledata "Post Value Entry to G/L" = rimd,
                    tabledata "Value Entry" = rimd,
                    tabledata "Item Application Entry" = rimd;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if EndingDate = 0D then
                    Error('Ending Date must be set!');

                CreateILECompressionLog(GetFilters);
                StartTime := Time;
                Window.Open(Txt000);
                if StartingDate <> 0D then
                    Window.Update(1, Format(StartingDate) + '..' + Format(EndingDate))
                else
                    Window.Update(1, '..' + Format(EndingDate));
            end;

            trigger OnAfterGetRecord()
            begin
                Window.Update(2, Item."No." + ' - ' + Item.Description);
                Window.Update(3, 'Checking cost adjustments (1/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Check cost adjustment', '', 0);
                //Check and confirm that adjustment has been run for items in the set range
                AvgCostAdjustmentEntryPoints.SetRange("Item No.", Item."No.");
                AvgCostAdjustmentEntryPoints.SetRange("Valuation Date", StartingDate, EndingDate);
                AvgCostAdjustmentEntryPoints.SetRange("Cost Is Adjusted", false);
                if AvgCostAdjustmentEntryPoints.Find('-') then
                    Error('Please run cost adjustment for item %1', Item."No.");

                PostValueEntryToGl.SetRange("Item No.", Item."No.");
                PostValueEntryToGl.SetRange("Posting Date", StartingDate, EndingDate);
                PostValueEntryToGl.SetRange("AQDLC Skipped", false);
                if PostValueEntryToGl.Find('-') then
                    Error('Please run "Post Inventory Costs to G/L" for item %1 to and including date %2', Item."No.", EndingDate);
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Check cost adjustment', '', 2);

                StartingILENumber := 0;
                StartingVENumber := 0;
                ILE.SetCurrentKey("Entry No.");
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                if ILE.FindFirst() then
                    StartingILENumber := ILE."Entry No.";

                VE.SetCurrentKey("Entry No.");
                VE.SetRange("Item No.", Item."No.");
                VE.SetFilter("Posting Date", '<=%1', EndingDate);
                if VE.FindFirst() then
                    StartingVENumber := VE."Entry No.";

                Window.Update(3, 'Generating Quantity on Hand (2/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Generate Quantity on Hand', '', 0);
                Clear(GenerateQoHRpt);
                GenerateQoHRpt.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                GenerateQoHRpt.SetTableView(ILE);
                GenerateQoHRpt.SetRunParameters(EndingDate, RegNo, false);
                GenerateQoHRpt.UseRequestPage := false;
                GenerateQoHRpt.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Generate Quantity on Hand', '', 2);

                Window.Update(3, 'Deleting Item Ledger and Value Entries (3/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Delete Item Ledger and Value Entries', '', 0);
                Clear(RptDeleteILEandVLE);
                RptDeleteILEandVLE.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                RptDeleteILEandVLE.SetTableView(ILE);
                RptDeleteILEandVLE.SetRunParameters(EndingDate, RegNo, PostingDateRunNo, false);
                RptDeleteILEandVLE.UseRequestPage := false;
                RptDeleteILEandVLE.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Delete Item Ledger and Value Entries', '', 2);

                /*Window.Update(3, 'Create Missing Item Ledger Entries (4/8)');
                Clear(RptCreateMissingILEs);
                RptCreateMissingILEs.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                RptCreateMissingILEs.SetTableView(ILE);
                RptCreateMissingILEs.SetRunParameters(EndingDate,RegNo,  false);
                RptCreateMissingILEs.UseRequestPage := false;
                RptCreateMissingILEs.RunModal();//to review*/

                Window.Update(3, 'Create Item Ledger Entries using Quantity on Hand (5/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Create Item Ledger Entries using Quantity on Hand', '', 0);
                Clear(RptCrateILEEntriesUsingQoH);
                QoH.SetRange("Item No.", Item."No.");
                QoH.SetRange("Posting Date", EndingDate);
                QoH.SetRange("Register No.", RegNo);
                RptCrateILEEntriesUsingQoH.SetTableView(QoH);
                RptCrateILEEntriesUsingQoH.SetRunParameters(StartingILENumber, StartingVENumber, EndingDate, RegNo, PostingDateRunNo, false);
                RptCrateILEEntriesUsingQoH.UseRequestPage := false;
                RptCrateILEEntriesUsingQoH.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Create Item Ledger Entries using Quantity on Hand', '', 2);

                Window.Update(3, 'Delete Orphan Item Application Entries (6/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Delete Orphan Item Application Entries', '', 0);
                Clear(RptDeleteOrphanItemApplEntry);
                ItemApplicationEntry.SetRange("Item No.", Item."No.");
                ItemApplicationEntry.SetFilter("Posting Date", '<=%1', EndingDate);
                RptDeleteOrphanItemApplEntry.SetTableView(ItemApplicationEntry);
                RptDeleteOrphanItemApplEntry.SetRunParameters(EndingDate, RegNo, false);
                RptDeleteOrphanItemApplEntry.UseRequestPage := false;
                RptDeleteOrphanItemApplEntry.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Delete Orphan Item Application Entries', '', 2);

                /*Window.Update(3, 'Create Item Application (7/8)');
                Clear(RptCreateItemApplication);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                RptCreateItemApplication.SetTableView(ILE);
                RptCreateItemApplication.SetRunParameters(EndingDate,RegNo,  false);
                RptCreateItemApplication.UseRequestPage := false;
                RptCreateItemApplication.RunModal();*/

                Window.Update(3, 'Running Post-Compression Inventory Valuation (5/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Run Post-Compression Inventory Valuation', '', 0);
                Clear(RptPostCompressionInvtValuation);
                QoH.SetRange("Item No.", Item."No.");
                QoH.SetRange("Posting Date", EndingDate);
                QoH.SetRange("Register No.", RegNo);
                RptPostCompressionInvtValuation.SetTableView(QoH);
                //RptPostCompressionInvtValuation.SetRunParameters(EndingDate,RegNo,  false);
                RptPostCompressionInvtValuation.UseRequestPage := false;
                RptPostCompressionInvtValuation.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Run Post-Compression Inventory Valuation', '', 2);

                Item."Cost is Adjusted" := false;
                Item.Modify();
            end;

            trigger OnPostDataItem()
            begin
                Window.Update(1, '');

                Window.Update(3, 'Compress Related Tables (8/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Compress Related Tables', '', 0);
                RptCompressAdditionalTablesRec.SetRunParameters(EndingDate, RegNo, false);
                RptCompressAdditionalTablesRec.UseRequestPage := false;
                RptCompressAdditionalTablesRec.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Compress Related Tables', '', 2);

                CloseILECompressionLog();

                Message('Item Ledger Compression Completed Successfully!\Start Time: %1 End Time: %2', StartTime, TIME);
                Window.Close();
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
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
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
        if ILECompressionSetup.Get() and (Format(ILECompressionSetup."Cut-off Period") <> '') then
            EndingDate := CalcDate(ILECompressionSetup."Cut-off Period", Today)
        else
            EndingDate := CalcDate('-7Y', Today);
    end;

    trigger OnPostReport()
    var
        QoH: Record "AQDLC Qty on Hand"; //should call compression logs
    begin
        //if Confirm('Do you want to open the Compression Results page?') then begin
        QoH.Reset();
        QoH.SetRange("Register No.", RegNo);
        if QoH.Find('-') then
            Page.Run(Page::"AQDLC Quantity on Hand", QoH);
        //end;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        StartingILENumber: Integer;
        StartingVENumber: Integer;
        ILE: Record "Item Ledger Entry";
        VE: Record "Value Entry";
        GenerateQoHRpt: Report "AQDLC Generate Qty On Hand";
        AvgCostAdjustmentEntryPoints: Record "Avg. Cost Adjmt. Entry Point";
        PostValueEntryToGl: Record "Post Value Entry to G/L";
        RptDeleteILEandVLE: Report "AQDLC Delete ILE and VLE";
        RptCreateMissingILEs: Report "AQDLC Create Missing ILEs";
        RptCrateILEEntriesUsingQoH: Report "AQDLC Create ILE Entrs frm QoH";
        RptDeleteOrphanItemApplEntry: Report "AQDLC Dlt Orphn Itm Apl Entry";
        RptCompressAdditionalTablesRec: Report "AQDLC Compress Add. Tables Rec";
        RptCreateItemApplication: Report "AQDLC Create Item Application";
        RptOpenAllItemsForAdjustment: Report "AQDLC Open All Items for Adj";
        RptPostCompressionInvtValuation: Report "AQDLC Post-Compress Invt. Val";
        StartTime: Time;
        QoH: Record "AQDLC Qty on Hand";
        ItemApplicationEntry: Record "Item Application Entry";
        StartingDate: Date;
        EndingDate: Date;
        Window: Dialog;
        Txt000: Label 'Compressing Item Ledger Entries\Period: #1#####\Processing Item: #2#####\Status: #3#####';
        CalledFromRegisterNo: Integer;
        RegNo: Integer;
        PostingDateRunNo: Integer;
        LogLineNo: Integer;

    procedure SetCalledFromEntryNo(vCalledFromRegisterNo: Integer)
    begin
        CalledFromRegisterNo := vCalledFromRegisterNo;
        RegNo := CalledFromRegisterNo;
    end;

    local procedure CreateILECompressionLog(ItemFilters: Text)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        if CalledFromRegisterNo <> 0 then exit;

        PostingDateRunNo := GetPostingDateRunNo();
        ;
        IleCompressionReg.Init();
        IleCompressionReg."Item Filter" := CopyStr(ItemFilters, 1, 200);
        IleCompressionReg."Executed On" := CurrentDateTime;
        IleCompressionReg."Executed By" := UserId;
        IleCompressionReg."Start Date/Time" := CurrentDateTime;
        IleCompressionReg.Status := IleCompressionReg.Status::Incomplete;
        IleCompressionReg."Posting Date" := EndingDate;
        IleCompressionReg."Posting Date Run No." := PostingDateRunNo;
        IleCompressionReg.Insert(true);
        RegNo := IleCompressionReg."Entry No.";
    end;

    local procedure GetPostingDateRunNo(): Integer
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        IleCompressionReg.SetCurrentKey("Posting Date", "Posting Date Run No.");
        IleCompressionReg.SetRange("Posting Date", EndingDate);
        IleCompressionReg.SetAscending("Posting Date Run No.", false);
        if IleCompressionReg.FindFirst() then
            exit(IleCompressionReg."Posting Date Run No." + 1);
        exit(1);
    end;

    local procedure CloseILECompressionLog()
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        if RegNo = 0 then exit;

        if IleCompressionReg.Get(RegNo) then begin
            IleCompressionReg."End Date/Time" := CurrentDateTime;
            IleCompressionReg.Status := IleCompressionReg.Status::Completed;
            IleCompressionReg.Modify();
        end;
    end;

    local procedure UpdateCompressionLogEntry(vAction: Option Create,Update; var IleLogLineNo: Integer; ItemNo: Code[20]; Descr: Text; ErrorMessage: Text; vStatus: Option Pending,Failed,Successful)
    var
        IleCompressionEntry: Record "AQDLC ILE Compress Log Entry";
    begin
        if RegNo = 0 then exit;
        if (IleLogLineNo = 0) and (vAction = vAction::Update) then
            vAction := vAction::Create;

        if vAction = vAction::Create then begin
            IleCompressionEntry.Init();
            IleCompressionEntry."Log No." := RegNo;
            IleCompressionEntry."Item No." := ItemNo;
            IleCompressionEntry.Description := Descr;
            IleCompressionEntry.Status := vStatus;
            IleCompressionEntry."Start Date/Time" := CurrentDateTime;
            if vStatus <> vStatus::Pending then
                IleCompressionEntry."End Date/Time" := CurrentDateTime;
            IleCompressionEntry.Insert(true);
            IleLogLineNo := IleCompressionEntry."Line No.";
        end;

        if vAction = vAction::Update then begin
            IleCompressionEntry.SetRange("Log No.", RegNo);
            IleCompressionEntry.SetRange("Line No.", IleLogLineNo);
            if IleCompressionEntry.FindFirst() then begin
                IleCompressionEntry."End Date/Time" := CurrentDateTime;
                IleCompressionEntry."Error Message" := CopyStr(ErrorMessage, 1, 2000);
                IleCompressionEntry.Status := vStatus;
                IleCompressionEntry.Modify();
            end;
        end;
    end;
}
