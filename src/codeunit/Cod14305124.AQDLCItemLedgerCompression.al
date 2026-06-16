codeunit 14305124 "AQDLC Item Ledger Compression"
{
    TableNo = Item;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        ILECompressionSingleInst: Codeunit "AQDLC ILE Compress Single Inst";
        ILECompressionTask: Text;
        //Params
        RegNo: Integer;
        EndingDate: Date;
        CalledFromRegisterNo: Integer;
        ScheduleDescription: Text;
        //
        PostingDateRunNo: Integer;
        Txt000: Label 'Compressing Item Ledger Entries\Period: #1#####\Processing Item: #2#####\Status: #3#####';

    trigger OnRun()
    begin
        GetParams();
        ILECompressionSingleInst.GetILECompressionTask(ILECompressionTask);
        if ILECompressionTask = 'CompressAdditionalRecs' then
            CompressAdditionalRecs()
        else
            RunCompression(Rec);
    end;

    var
        Window: Dialog;
        LogLineNo: Integer;
        StartingILENumber: Integer;
        StartingVENumber: Integer;
        ILE: Record "Item Ledger Entry";
        VE: Record "Value Entry";
        RptDeleteILEandVLE: Report "AQDLC Delete ILE and VLE";
        //RptCreateMissingILEs: Report "AQDLC Create Missing ILEs";
        RptCrateILEEntriesUsingQoH: Report "AQDLC Create ILE Entrs frm QoH";
        RptDeleteOrphanItemApplEntry: Report "AQDLC Dlt Orphn Itm Apl Entry";
        RptCompressAdditionalTablesRec: Report "AQDLC Compress Add. Tables Rec";
        RptCreateItemApplication: Report "AQDLC Create Item Application";
        RptPostCompressionInvtValuation: Report "AQDLC Post-Compress Invt. Val";
        GenerateQoHRpt: Report "AQDLC Generate Qty On Hand";
        QoH: Record "AQDLC Qty on Hand";
        ItemApplicationEntry: Record "Item Application Entry";
        ItemValuationComparison: Record "AQDLC Item Valuation Comparisn";

    local procedure RunCompression(vItem: Record Item)
    var
        ErrorMsg: Text;
        ItemRec: Record Item;
    begin
        OpenWindow();
        UpdateWindow(2, vItem."No." + ' - ' + vItem.Description);
        UpdateWindow(3, 'Checking cost adjustments (1/8)');
        LogLineNo := 0;
        ClearRecordsCount();
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Check cost adjustment', '', 0, 0, 0, 0, 0);
        if not CheckItemCostAdjustment(vItem, ErrorMsg) then begin
            UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Check cost adjustment', ErrorMsg, 1, 0, 0, 0, 0);
            Error(ErrorMsg);
            exit;
        end else
            UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Check cost adjustment', '', 2, 0, 0, 0, 0);

        StartingILENumber := 0;
        StartingVENumber := 0;
        ILE.SetCurrentKey("Entry No.");
        ILE.SetRange("Item No.", vItem."No.");
        ILE.SetFilter("Posting Date", '<=%1', EndingDate);
        if ILE.FindFirst() then
            StartingILENumber := ILE."Entry No.";

        VE.SetCurrentKey("Entry No.");
        VE.SetRange("Item No.", vItem."No.");
        VE.SetFilter("Posting Date", '<=%1', EndingDate);
        if VE.FindFirst() then
            StartingVENumber := VE."Entry No.";

        UpdateWindow(3, 'Generating Quantity on Hand (2/8)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Generate Quantity on Hand', '', 0, 0, 0, 0, 0);
        Clear(GenerateQoHRpt);
        ILE.SetRange("Item No.", vItem."No.");
        ILE.SetFilter("Posting Date", '<=%1', EndingDate);
        ILE.SetRange("Completely Invoiced", true);
        GenerateQoHRpt.SetTableView(ILE);
        ItemRec.SetRange("No.", vItem."No.");
        GenerateQoHRpt.SetTableView(ItemRec);
        GenerateQoHRpt.SetRunParameters(EndingDate, RegNo, CompressionScheduleNo, false);
        GenerateQoHRpt.UseRequestPage := false;
        GenerateQoHRpt.RunModal();
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Generate Quantity on Hand', '', 2, 0, 0, 0, 0);

        UpdateWindow(3, 'Deleting Item Ledger and Value Entries (3/8)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Delete Item Ledger and Value Entries', '', 0, 0, 0, 0, 0);
        Clear(RptDeleteILEandVLE);
        ILE.SetRange("Item No.", vItem."No.");
        ILE.SetFilter("Posting Date", '<=%1', EndingDate);
        ILE.SetRange("Completely Invoiced", true);
        RptDeleteILEandVLE.SetTableView(ILE);
        ItemRec.SetRange("No.", vItem."No.");
        GenerateQoHRpt.SetTableView(ItemRec);
        RptDeleteILEandVLE.SetRunParameters(EndingDate, RegNo, PostingDateRunNo, false);
        RptDeleteILEandVLE.UseRequestPage := false;
        RptDeleteILEandVLE.RunModal();
        RptDeleteILEandVLE.GetDeleteCount(DeletedILEs, DeletedVEs);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Delete Item Ledger and Value Entries', '', 2, DeletedILEs, DeletedVEs, 0, 0);

        UpdateWindow(3, 'Delete Orphan Item Application Entries (4/8)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Delete Orphan Item Application Entries', '', 0, 0, 0, 0, 0);
        Clear(RptDeleteOrphanItemApplEntry);
        ItemApplicationEntry.SetRange("Item No.", vItem."No.");
        ItemApplicationEntry.SetFilter("Posting Date", '<=%1', EndingDate);
        RptDeleteOrphanItemApplEntry.SetTableView(ItemApplicationEntry);
        RptDeleteOrphanItemApplEntry.SetRunParameters(EndingDate, RegNo, false);
        RptDeleteOrphanItemApplEntry.UseRequestPage := false;
        RptDeleteOrphanItemApplEntry.RunModal();
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Delete Orphan Item Application Entries', '', 2, 0, 0, 0, 0);

        UpdateWindow(3, 'Create Item Ledger Entries using Quantity on Hand (5/8)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Create Item Ledger Entries using Quantity on Hand', '', 0, 0, 0, 0, 0);
        Clear(RptCrateILEEntriesUsingQoH);
        QoH.SetRange("Item No.", vItem."No.");
        QoH.SetRange("Posting Date", EndingDate);
        QoH.SetRange("Register No.", RegNo);
        RptCrateILEEntriesUsingQoH.SetTableView(QoH);
        RptCrateILEEntriesUsingQoH.SetRunParameters(StartingILENumber, StartingVENumber, EndingDate, RegNo, PostingDateRunNo, CompressionScheduleNo, ScheduleDescription, false);
        RptCrateILEEntriesUsingQoH.UseRequestPage := false;
        RptCrateILEEntriesUsingQoH.RunModal();
        RptCrateILEEntriesUsingQoH.GetCreatedCount(CreatedILEs, CreatedVEs);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Create Item Ledger Entries using Quantity on Hand', '', 2, 0, 0, CreatedILEs, CreatedVEs);

        UpdateWindow(3, 'Create Item Application Entries (6/8)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Create Item Application Entries', '', 0, 0, 0, 0, 0);
        Clear(RptCreateItemApplication);
        ILE.SetRange("Item No.", vItem."No.");
        ILE.SetFilter("Posting Date", '<=%1', EndingDate);
        ILE.SetRange("Completely Invoiced", true);
        RptCreateItemApplication.SetTableView(ILE);
        RptCreateItemApplication.SetRunParameters(EndingDate, RegNo, false);
        RptCreateItemApplication.UseRequestPage := false;
        RptCreateItemApplication.RunModal();
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Create Item Application Entries', '', 2, 0, 0, 0, 0);

        UpdateWindow(3, 'Running Post-Compression Inventory Valuation (7/8)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Run Post-Compression Inventory Valuation', '', 0, 0, 0, 0, 0);
        Clear(RptPostCompressionInvtValuation);
        ItemValuationComparison.SetRange("Item No.", vItem."No.");
        ItemValuationComparison.SetRange("Cut-off Date", EndingDate);
        ItemValuationComparison.SetRange("Register No.", RegNo);
        RptPostCompressionInvtValuation.SetTableView(ItemValuationComparison);
        RptPostCompressionInvtValuation.SetRunParameters(EndingDate, RegNo, false);
        RptPostCompressionInvtValuation.UseRequestPage := false;
        RptPostCompressionInvtValuation.RunModal();
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Run Post-Compression Inventory Valuation', '', 2, 0, 0, 0, 0);

        vItem."Cost is Adjusted" := false;
        if CompressionScheduleNo <> 0 then begin
            vItem."AQDLC Last Compression No." := CompressionScheduleNo;
            vItem."AQDLC Last Compression Date" := EndingDate;
            MarkScheduleAsProcessed();
        end;
        vItem.Modify();
        Commit();
    end;

    var
        AvgCostAdjustmentEntryPoints: Record "Avg. Cost Adjmt. Entry Point";
        PostValueEntryToGl: Record "Post Value Entry to G/L";
        StartingDate: Date;

    local procedure CheckItemCostAdjustment(vItem: Record Item; var vErrorMsg: Text): Boolean
    begin
        StartingDate := 0D;
        AvgCostAdjustmentEntryPoints.SetRange("Item No.", vItem."No.");
        AvgCostAdjustmentEntryPoints.SetRange("Valuation Date", StartingDate, EndingDate);
        AvgCostAdjustmentEntryPoints.SetRange("Cost Is Adjusted", false);
        if AvgCostAdjustmentEntryPoints.Find('-') then begin
            vErrorMsg := StrSubstNo('Please run cost adjustment for item %1', vItem."No.");
            exit(false);
        end;

        PostValueEntryToGl.SetRange("Item No.", vItem."No.");
        PostValueEntryToGl.SetRange("Posting Date", StartingDate, EndingDate);
        PostValueEntryToGl.SetRange("AQDLC Skipped", false);
        if PostValueEntryToGl.Find('-') then begin
            vErrorMsg := StrSubstNo('Please run "Post Inventory Costs to G/L" for item %1 to and including date %2', vItem."No.", EndingDate);
            exit(false);
        end;
        exit(true);
    end;

    var
        DeletedILEs: Integer;
        DeletedVEs: Integer;
        CreatedILEs: Integer;
        CreatedVEs: Integer;

    local procedure ClearRecordsCount()
    begin
        DeletedILEs := 0;
        DeletedVEs := 0;
        CreatedILEs := 0;
        CreatedVEs := 0;
    end;

    procedure CreateILECompressionLog(ItemFilters: Text; vEndingDate: Date; ExecutionStartDt: DateTime; vCalledFromRegisterNo: Integer; var vRegNo: Integer; vCompressionScheduleNo: Integer; var vPostingDateRunNo: Integer)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        if vCalledFromRegisterNo <> 0 then exit;

        vPostingDateRunNo := GetPostingDateRunNo();
        IleCompressionReg.Init();
        IleCompressionReg."Item Filter" := CopyStr(ItemFilters, 1, 200);
        IleCompressionReg."Executed On" := ExecutionStartDt;
        IleCompressionReg."Executed By" := UserId;
        IleCompressionReg."Start Date/Time" := CurrentDateTime;
        IleCompressionReg.Status := IleCompressionReg.Status::Incomplete;
        IleCompressionReg."Cut-off Date" := vEndingDate;
        IleCompressionReg."Cut-off Date Run No." := vPostingDateRunNo;
        IleCompressionReg."Schedule No." := vCompressionScheduleNo;
        IleCompressionReg.Insert(true);
        vRegNo := IleCompressionReg."Entry No.";
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

    procedure CloseILECompressionLog(vStatus: Option Incomplete,Failed,Completed; vExecutionTimeOut: Boolean; vExecutionTimeOutMsg: Text)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        GetParams();
        if RegNo = 0 then exit;

        if IleCompressionReg.Get(RegNo) then begin
            IleCompressionReg."End Date/Time" := CurrentDateTime;
            IleCompressionReg.Status := vStatus;
            if vExecutionTimeOut then
                IleCompressionReg."Processing Summary" := vExecutionTimeOutMsg;
            IleCompressionReg.Modify();
        end;
    end;

    procedure UpdateCompressionLogEntry(vAction: Option Create,Update; var IleLogLineNo: Integer; ItemNo: Code[20]; Descr: Text; ErrorMessage: Text; vStatus: Option Pending,Failed,Successful; vDeletedILEs: Integer; vDeletedVEs: Integer; vCreatedILEs: Integer; vCreatedVEs: Integer)
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
        CompressionScheduleNo: Integer;
        SkipCompressedItems: Boolean;

    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";

    local procedure MarkScheduleAsProcessed()
    begin
        if CompressionScheduleNo = 0 then exit;
        if CompressionSchedule.Get(CompressionScheduleNo) and (not CompressionSchedule.Processed) then begin
            CompressionSchedule.Processed := true;
            CompressionSchedule.Modify();
        end;
    end;

    local procedure CompressAdditionalRecs()
    begin
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, '', 'Compress Related Tables', '', 0, 0, 0, 0, 0);
        RptCompressAdditionalTablesRec.SetRunParameters(EndingDate, RegNo, false);
        RptCompressAdditionalTablesRec.UseRequestPage := false;
        RptCompressAdditionalTablesRec.RunModal();
        UpdateCompressionLogEntry(1, LogLineNo, '', 'Compress Related Tables', '', 2, 0, 0, 0, 0);
    end;


    local procedure OpenWindow()
    begin
        if not GuiAllowed then exit;
        Window.Open(Txt000);
        Window.Update(1, '..' + Format(EndingDate));
    end;

    local procedure UpdateWindow(No: Integer; Msg: Text)
    begin
        if not GuiAllowed then exit;
        Window.Update(No, Msg);
    end;

    local procedure GetParams()
    begin
        ILECompressionSingleInst.GetILECompressionParams(EndingDate, PostingDateRunNo, RegNo, CalledFromRegisterNo, ScheduleDescription);
    end;
}
