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
                    Error('Cut-off Date must be set!');
                ValidateCutoffDate();

                if CompressionScheduleNo = 0 then
                    GetApplicableCompressionSchedule();
                CreateILECompressionLog(GetFilters);
                StartTime := Time;
                Window.Open(Txt000);
                if StartingDate <> 0D then
                    Window.Update(1, Format(StartingDate) + '..' + Format(EndingDate))
                else
                    Window.Update(1, '..' + Format(EndingDate));

                SomethingCompressed := false;
            end;

            trigger OnAfterGetRecord()
            var
                ErrorMsg: Text;
            begin
                Window.Update(2, Item."No." + ' - ' + Item.Description);
                Window.Update(3, 'Checking cost adjustments (1/8)');
                LogLineNo := 0;
                ClearRecordsCount();
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Check cost adjustment', '', 0, 0, 0, 0, 0);
                if not CheckItemCostAdjustment(Item, ErrorMsg) then begin
                    UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Check cost adjustment', ErrorMsg, 1, 0, 0, 0, 0);
                    UpdateExecutionSummary(ErrorMsg);
                    CurrReport.Skip();
                end else
                    UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Check cost adjustment', '', 2, 0, 0, 0, 0);

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
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Generate Quantity on Hand', '', 0, 0, 0, 0, 0);
                Clear(GenerateQoHRpt);
                GenerateQoHRpt.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                ILE.SetRange("Completely Invoiced", true);
                GenerateQoHRpt.SetTableView(ILE);
                GenerateQoHRpt.SetRunParameters(EndingDate, RegNo, false);
                GenerateQoHRpt.UseRequestPage := false;
                GenerateQoHRpt.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Generate Quantity on Hand', '', 2, 0, 0, 0, 0);

                Window.Update(3, 'Deleting Item Ledger and Value Entries (3/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Delete Item Ledger and Value Entries', '', 0, 0, 0, 0, 0);
                Clear(RptDeleteILEandVLE);
                RptDeleteILEandVLE.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                ILE.SetRange("Completely Invoiced", true);
                RptDeleteILEandVLE.SetTableView(ILE);
                RptDeleteILEandVLE.SetRunParameters(EndingDate, RegNo, PostingDateRunNo, false);
                RptDeleteILEandVLE.UseRequestPage := false;
                RptDeleteILEandVLE.RunModal();
                RptDeleteILEandVLE.GetDeleteCount(DeletedILEs, DeletedVEs);
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Delete Item Ledger and Value Entries', '', 2, DeletedILEs, DeletedVEs, 0, 0);

                Window.Update(3, 'Delete Orphan Item Application Entries (4/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Delete Orphan Item Application Entries', '', 0, 0, 0, 0, 0);
                Clear(RptDeleteOrphanItemApplEntry);
                ItemApplicationEntry.SetRange("Item No.", Item."No.");
                ItemApplicationEntry.SetFilter("Posting Date", '<=%1', EndingDate);
                RptDeleteOrphanItemApplEntry.SetTableView(ItemApplicationEntry);
                RptDeleteOrphanItemApplEntry.SetRunParameters(EndingDate, RegNo, false);
                RptDeleteOrphanItemApplEntry.UseRequestPage := false;
                RptDeleteOrphanItemApplEntry.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Delete Orphan Item Application Entries', '', 2, 0, 0, 0, 0);

                Window.Update(3, 'Create Item Ledger Entries using Quantity on Hand (5/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Create Item Ledger Entries using Quantity on Hand', '', 0, 0, 0, 0, 0);
                Clear(RptCrateILEEntriesUsingQoH);
                QoH.SetRange("Item No.", Item."No.");
                QoH.SetRange("Posting Date", EndingDate);
                QoH.SetRange("Register No.", RegNo);
                RptCrateILEEntriesUsingQoH.SetTableView(QoH);
                RptCrateILEEntriesUsingQoH.SetRunParameters(StartingILENumber, StartingVENumber, EndingDate, RegNo, PostingDateRunNo, false);
                RptCrateILEEntriesUsingQoH.UseRequestPage := false;
                RptCrateILEEntriesUsingQoH.RunModal();
                RptCrateILEEntriesUsingQoH.GetCreatedCount(CreatedILEs, CreatedVEs);
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Create Item Ledger Entries using Quantity on Hand', '', 2, 0, 0, CreatedILEs, CreatedVEs);

                Window.Update(3, 'Create Item Application Entries (6/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Create Item Application Entries', '', 0, 0, 0, 0, 0);
                Clear(RptCreateItemApplication);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                ILE.SetRange("Completely Invoiced", true);
                RptCreateItemApplication.SetTableView(ILE);
                RptCreateItemApplication.SetRunParameters(EndingDate, RegNo, false);
                RptCreateItemApplication.UseRequestPage := false;
                RptCreateItemApplication.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Create Item Application Entries', '', 2, 0, 0, 0, 0);

                Window.Update(3, 'Running Post-Compression Inventory Valuation (7/8)');
                LogLineNo := 0;
                UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Run Post-Compression Inventory Valuation', '', 0, 0, 0, 0, 0);
                Clear(RptPostCompressionInvtValuation);
                ItemValuationComparison.SetRange("Item No.", Item."No.");
                ItemValuationComparison.SetRange("Cut-off Date", EndingDate);
                ItemValuationComparison.SetRange("Register No.", RegNo);
                RptPostCompressionInvtValuation.SetTableView(ItemValuationComparison);
                RptPostCompressionInvtValuation.SetRunParameters(EndingDate, RegNo, false);
                RptPostCompressionInvtValuation.UseRequestPage := false;
                RptPostCompressionInvtValuation.RunModal();
                UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Run Post-Compression Inventory Valuation', '', 2, 0, 0, 0, 0);

                Item."Cost is Adjusted" := false;
                if CompressionScheduleNo <> 0 then begin
                    Item."AQDLC Last Compression No." := CompressionScheduleNo;
                    Item."AQDLC Last Compression Date" := EndingDate;
                    MarkScheduleAsProcessed();
                end;
                Item.Modify();
                SomethingCompressed := true;
            end;

            trigger OnPostDataItem()
            begin
                Window.Update(1, '');
                if SomethingCompressed then begin
                    Window.Update(3, 'Compress Related Tables (8/8)');
                    LogLineNo := 0;
                    UpdateCompressionLogEntry(0, LogLineNo, "No.", 'Compress Related Tables', '', 0, 0, 0, 0, 0);
                    RptCompressAdditionalTablesRec.SetRunParameters(EndingDate, RegNo, false);
                    RptCompressAdditionalTablesRec.UseRequestPage := false;
                    RptCompressAdditionalTablesRec.RunModal();
                    UpdateCompressionLogEntry(1, LogLineNo, "No.", 'Compress Related Tables', '', 2, 0, 0, 0, 0);
                    CloseILECompressionLog(2);
                end else
                    CloseILECompressionLog(1);

                if ExecutionSummaryTxt <> '' then
                    ExecutionSummaryTxt := '\\' + 'Errors Encountered:\' + ExecutionSummaryTxt;

                Message('Item Ledger Compression Ended! Please review logs for details.\Start Time: %1 End Time: %2' + ExecutionSummaryTxt, StartTime, TIME);
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
                    field(CompressionScheduleNo; CompressionScheduleNo)
                    {
                        Caption = 'Schedule No.';
                        TableRelation = "AQDLC ILE Compression Schedule";
                        ToolTip = 'The compression schedule to be executed after this selection';

                        trigger OnValidate()
                        var
                            CompressionSchedule: Record "AQDLC ILE Compression Schedule";
                        begin
                            if CompressionScheduleNo = 0 then exit;

                            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                                EndingDate := CompressionSchedule."Cut-off Date";
                                ValidateCutoffDate();
                            end;
                        end;
                    }
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Cut-off Date';
                        ApplicationArea = All;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            if CompressionScheduleNo <> 0 then
                                Error('When a Schedule No. is selected as above, the Cut-off date is picked from the schedule!');
                            ValidateCutoffDate();
                        end;
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
        ILECompressionSetup.TestField("Cut-off Period");
        EndingDate := ILECompressionSetup."Latest Valid December 31";
        if EndingDate = 0D then
            EndingDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
    end;

    trigger OnPostReport()
    var
        CompressionRegister: Record "AQDLC ILE Compression Register";
    begin
        CompressionRegister.Reset();
        CompressionRegister.SetRange("Entry No.", RegNo);
        if CompressionRegister.Find('-') then
            Page.Run(Page::"AQDLC ILE Compression Register", CompressionRegister);
    end;

    procedure SetRunParameters(vCompressionScheduleNo: Integer)
    begin
        CompressionScheduleNo := vCompressionScheduleNo;
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
        //RptCreateMissingILEs: Report "AQDLC Create Missing ILEs";
        RptCrateILEEntriesUsingQoH: Report "AQDLC Create ILE Entrs frm QoH";
        RptDeleteOrphanItemApplEntry: Report "AQDLC Dlt Orphn Itm Apl Entry";
        RptCompressAdditionalTablesRec: Report "AQDLC Compress Add. Tables Rec";
        RptCreateItemApplication: Report "AQDLC Create Item Application";
        RptPostCompressionInvtValuation: Report "AQDLC Post-Compress Invt. Val";
        StartTime: Time;
        QoH: Record "AQDLC Qty on Hand";
        ItemApplicationEntry: Record "Item Application Entry";
        ItemValuationComparison: Record "AQDLC Item Valuation Comparisn";
        StartingDate: Date;
        EndingDate: Date;
        Window: Dialog;
        Txt000: Label 'Compressing Item Ledger Entries\Period: #1#####\Processing Item: #2#####\Status: #3#####';
        CalledFromRegisterNo: Integer;
        RegNo: Integer;
        PostingDateRunNo: Integer;
        LogLineNo: Integer;

        DeletedILEs: Integer;
        DeletedVEs: Integer;
        CreatedILEs: Integer;
        CreatedVEs: Integer;
        ExecutionSummaryTxt: Text;
        SomethingCompressed: Boolean;

    local procedure CheckItemCostAdjustment(vItem: Record Item; var vErrorMsg: Text): Boolean
    begin
        AvgCostAdjustmentEntryPoints.SetRange("Item No.", vItem."No.");
        AvgCostAdjustmentEntryPoints.SetRange("Valuation Date", StartingDate, EndingDate);
        AvgCostAdjustmentEntryPoints.SetRange("Cost Is Adjusted", false);
        if AvgCostAdjustmentEntryPoints.Find('-') then begin
            vErrorMsg := StrSubstNo('Please run cost adjustment for item %1', Item."No.");
            exit(false);
        end;

        PostValueEntryToGl.SetRange("Item No.", vItem."No.");
        PostValueEntryToGl.SetRange("Posting Date", StartingDate, EndingDate);
        PostValueEntryToGl.SetRange("AQDLC Skipped", false);
        if PostValueEntryToGl.Find('-') then begin
            vErrorMsg := StrSubstNo('Please run "Post Inventory Costs to G/L" for item %1 to and including date %2', Item."No.", EndingDate);
            exit(false);
        end;
        exit(true);
    end;

    local procedure ClearRecordsCount()
    begin
        DeletedILEs := 0;
        DeletedVEs := 0;
        CreatedILEs := 0;
        CreatedVEs := 0;
    end;

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
        IleCompressionReg.Init();
        IleCompressionReg."Item Filter" := CopyStr(ItemFilters, 1, 200);
        IleCompressionReg."Executed On" := CurrentDateTime;
        IleCompressionReg."Executed By" := UserId;
        IleCompressionReg."Start Date/Time" := CurrentDateTime;
        IleCompressionReg.Status := IleCompressionReg.Status::Incomplete;
        IleCompressionReg."Cut-off Date" := EndingDate;
        IleCompressionReg."Cut-off Date Run No." := PostingDateRunNo;
        IleCompressionReg."Schedule No." := CompressionScheduleNo;
        IleCompressionReg.Insert(true);
        RegNo := IleCompressionReg."Entry No.";
    end;

    local procedure GetPostingDateRunNo(): Integer
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        IleCompressionReg.SetCurrentKey("Cut-off Date", "Cut-off Date Run No.");
        IleCompressionReg.SetRange("Cut-off Date", EndingDate);
        IleCompressionReg.SetAscending("Cut-off Date Run No.", false);
        if IleCompressionReg.FindFirst() then
            exit(IleCompressionReg."Cut-off Date Run No." + 1);
        exit(1);
    end;

    local procedure CloseILECompressionLog(vStatus: Option Incomplete,Failed,Completed)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        if RegNo = 0 then exit;

        if IleCompressionReg.Get(RegNo) then begin
            IleCompressionReg."End Date/Time" := CurrentDateTime;
            IleCompressionReg.Status := vStatus;
            IleCompressionReg.Modify();
        end;
    end;

    local procedure UpdateCompressionLogEntry(vAction: Option Create,Update; var IleLogLineNo: Integer; ItemNo: Code[20]; Descr: Text; ErrorMessage: Text; vStatus: Option Pending,Failed,Successful; vDeletedILEs: Integer; vDeletedVEs: Integer; vCreatedILEs: Integer; vCreatedVEs: Integer)
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
            IleCompressionEntry."No. of ILEs Deleted" := vDeletedILEs;
            IleCompressionEntry."No. of VEs Deleted" := vDeletedVEs;
            IleCompressionEntry."No. of ILEs Created" := vCreatedILEs;
            IleCompressionEntry."No. of VEs Created" := vCreatedVEs;
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
                IleCompressionEntry."No. of ILEs Deleted" := vDeletedILEs;
                IleCompressionEntry."No. of VEs Deleted" := vDeletedVEs;
                IleCompressionEntry."No. of ILEs Created" := vCreatedILEs;
                IleCompressionEntry."No. of VEs Created" := vCreatedVEs;
                IleCompressionEntry.Modify();
            end;
        end;
    end;

    var
        SummaryTxtFull: Boolean;

    local procedure UpdateExecutionSummary(Msg: Text)
    begin
        if SummaryTxtFull then exit;
        if (StrLen(ExecutionSummaryTxt + Msg) > 500) then begin
            SummaryTxtFull := true;
            exit;
        end;

        if ExecutionSummaryTxt = '' then
            ExecutionSummaryTxt := '- ' + Msg
        else
            ExecutionSummaryTxt += '\ - ' + Msg;
    end;

    local procedure ValidateCutoffDate()
    var
        CutOffDate: Date;
    begin
        if EndingDate = 0D then exit;
        CutOffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
        if EndingDate > CutOffDate then
            Error('The cut-off date %1 is not valid. The latest allowed cut-off date is %2.', EndingDate, CutOffDate);
    end;

    var
        CompressionScheduleNo: Integer;

    local procedure GetApplicableCompressionSchedule()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        CompressionSchedule.SetCurrentKey("Cut-off Date");
        CompressionSchedule.SetFilter("Cut-off Date", '<=%1', EndingDate);
        CompressionSchedule.SetAscending("Cut-off Date", false);
        if CompressionSchedule.FindFirst() then
            CompressionScheduleNo := CompressionSchedule."Entry No.";
    end;

    local procedure MarkScheduleAsProcessed()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        if CompressionScheduleNo = 0 then exit;
        if CompressionSchedule.Get(CompressionScheduleNo) and (not CompressionSchedule.Processed) then begin
            CompressionSchedule.Processed := true;
            CompressionSchedule.Modify();
        end;
    end;
}
