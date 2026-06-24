report 14305126 "AQDLC Delete ILE and VLE"
{
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD,
    tabledata "Item Register" = rimd,
    tabledata "G/L - Item Ledger Relation" = rimd,
    tabledata "G/L Entry" = rimd,
    tabledata "Item Application Entry" = rimd,
    tabledata "Tracking Specification" = rimd,
    tabledata "Warehouse Entry" = rimd;

    Caption = 'Delete ILE and VLE';
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";


            dataitem(ItemLedgerEntry; "Item Ledger Entry")
            {
                DataItemTableView = SORTING("Item No.", "Posting Date") where("Completely Invoiced" = filter(true), "AQDLC Skip Compressing" = filter(false));
                DataItemLink = "Item No." = FIELD("No.");

                trigger OnPreDataItem()
                begin
                    SetFilter("Posting Date", '<=%1', MaxPostingDate);
                    if ShowDialog then begin
                        Counter := 0;
                    end;
                    ILEsBatchDeleteCounter := 0;
                    Clear(ILEsFilterText);
                    Clear(ItemRegisterFilterText);
                end;

                trigger OnAfterGetRecord();
                var
                begin
                    if ShowDialog then begin
                        Counter += 1;
                        if (Counter MOD 1000) = 0 then
                            Window.Update(2, Format("Entry No.") + ' (' + Format((Counter DIV 1000)) + ',000)');
                        //Window.Update(2, Format("Entry No.") + ' (' + Format((Counter)) + ')');
                    end;
                    if "Document No." in ['QOH-' + Format(MaxPostingDate) + '-' + Format(PostingDateRunNo), 'MILE-' + Format(MaxPostingDate) + '-' + Format(PostingDateRunNo)] then
                        CurrReport.Skip();
                    if ("Entry Type" = "Entry Type"::Transfer) and ("Document Type" = "Document Type"::"Transfer Shipment") then
                        if not RptGenerateQtyOnHand.TransferCompletelyReceived(ItemLedgerEntry) then
                            CurrReport.Skip();

                    if ILEsFilterText = '' then
                        ILEsFilterText := Format("Entry No.")
                    else
                        ILEsFilterText += '|' + Format("Entry No.");
                    ILEsBatchDeleteCounter += 1;

                    /*if "Item Register No." <> 0 then begin
                        if ItemRegisterFilterText = '' then
                            ItemRegisterFilterText := Format("Item Register No.")
                        else
                            ItemRegisterFilterText += '|' + Format("Item Register No.");
                    end;*/

                    if ILEsBatchDeleteCounter = 1000 then begin
                        DeleteEntriesInBatches();

                        Clear(ILEsFilterText);
                        //Clear(ItemRegisterFilterText);
                        ILEsBatchDeleteCounter := 0;
                    end;

                    ILEDeleteCount += 1;
                end;

                trigger OnPostDataItem();
                begin
                    DeleteEntriesInBatches();
                    DeleteItemApplns(true);
                end;
            }
            trigger OnPreDataItem();
            begin
                if MaxPostingDate = 0D then
                    Error('Max Posting Date is required!');

                if ShowDialog then begin
                    Window.Open(Text001 + Text004);
                end;
                StartTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord();
            begin
                if ShowDialog then begin
                    Window.Update(1, "No." + ' => ' + Description);
                end;

                WhseEntry.SetRange("Item No.", "No.");
                WhseEntry.SetFilter("Registering Date", '<=%1', MaxPostingDate);
                WhseEntry.DeleteAll();
            end;

            trigger OnPostDataItem();
            begin
                ILECompressionSingleInst.GetVEDeleteCount(VEDeleteCount);

                if not ShowDialog then exit;
                Window.Close();
                //Message('Batch process execution is completed - 2 Delete ILE and VLE\Start Time: %1 End Time: %2 (%5)' +
                //'\\Deleted ILE Count %3\\VLE Count %4', StartTime, CurrentDateTime, ILEDeleteCount, VEDeleteCount, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
            end;
        }
    }
    trigger OnPreReport();
    begin
        ILECompressionSingleInst.SetVEDeleteCount(0);
        ILECompressionSingleInst.ResetVEDeleteFilter();
        if not ShowDialog then exit;
        /*if not Confirm(Text002 + Item.GetFilters() + '\' + "ItemLedgerEntry".GetFilters()) then begin
            Error('Report is aborted');
            CurrReport.Break();
        end;*/
    end;

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vPostingDateRunNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        PostingDateRunNo := vPostingDateRunNo;
        ShowDialog := vShowDialog;
    end;

    procedure GetDeleteCount(var vILEDeleteCount: Integer; var vVEDeleteCount: Integer)
    begin
        vILEDeleteCount := ILEDeleteCount;
        vVEDeleteCount := VEDeleteCount;
    end;

    var
        Text001: Label '[2/7] Deleting Entries for Item No.  ########1#####\\';
        Text004: Label 'ILE No.  ########2#####';
        ValueEntry: Record "Value Entry";
        Window: Dialog;
        MaxPostingDate: Date;
        Text002: Label 'Do you want to run batch process for below filters?\';
        ILEDeleteCount: Integer;
        VEDeleteCount: Integer;
        Text003: Label 'Deleted ILE Count %1\VLE Count %2';
        Counter: Integer;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
        PostingDateRunNo: Integer;
        ItemRegister: Record "Item Register";
        RptGenerateQtyOnHand: Report "AQDLC Generate Qty On Hand";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        TrackingSpecification: Record "Tracking Specification";
        WhseEntry: Record "Warehouse Entry";
        GLEntry: Record "G/L Entry";
        DeleteRecord: Boolean;
        TotalItems: Integer;
        TotalILEs: Integer;
        ILEsFilterText: Text;
        ItemRegisterFilterText: Text;
        ILEsBatchDeleteCounter: Integer;
        ILECompressionSingleInst: Codeunit "AQDLC ILE Compress Single Inst";

    local procedure DeleteEntriesInBatches()
    var
        ILE: Record "Item Ledger Entry";
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ILEsFilterText = '' then exit;

        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Valuation Date", "Posting Date");
        ValueEntry.SetFilter("Item Ledger Entry No.", ILEsFilterText);
        //ValueEntry.SetFilter("Posting Date", '<=%1', MaxPostingDate);
        //VEDeleteCount += ValueEntry.Count();
        ValueEntry.DeleteAll(true); //to delete item ledger relations

        TrackingSpecification.SetFilter("Item Ledger Entry No.", ILEsFilterText);
        TrackingSpecification.DeleteAll();

        //ItemRegister.SetCurrentKey("No.");
        //ItemRegister.SetFilter("No.", ItemRegisterFilterText);
        //ItemRegister.DeleteAll();

        ItemApplnEntry.SetFilter("Item Ledger Entry No.", ILEsFilterText);
        ItemApplnEntry.DeleteAll();

        ItemApplnEntry.Reset();
        ItemApplnEntry.SetFilter("Inbound Item Entry No.", ILEsFilterText);
        ItemApplnEntry.DeleteAll();

        ItemApplnEntry.Reset();
        ItemApplnEntry.SetFilter("Outbound Item Entry No.", ILEsFilterText);
        ItemApplnEntry.DeleteAll();

        ILE.SetCurrentKey("Entry No.");
        ILE.SetFilter("Entry No.", ILEsFilterText);
        ILE.DeleteAll();

        DeleteItemApplns(false);
    end;


    local procedure DeleteItemApplns(FinalCall: Boolean)
    var
        VeCount: Integer;
        VeFilter: Text;
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
    begin
        ILECompressionSingleInst.GetVEDeleteFilter(VeFilter, VeCount);
        if VeFilter = '' then exit;
        if (VeCount >= 1000) or (FinalCall) then begin
            GLItemLedgerRelation.SetFilter("Value Entry No.", VeFilter);
            GLItemLedgerRelation.DeleteAll();
            ILECompressionSingleInst.ResetVEDeleteFilter();
        end;
    end;
}
