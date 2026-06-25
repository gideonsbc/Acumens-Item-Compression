report 14305129 "AQDLC Dlt Orphn Itm Apl Entry"
{
    Caption = 'Delete Orphan Item Appl. Entry';
    ProcessingOnly = true;
    ApplicationArea = All;

    Permissions = tabledata "Item Application Entry" = rimd;
    dataset
    {
        dataitem(ItemApplnEntry; "Item Application Entry")
        {
            trigger OnPreDataItem();
            begin
                SetFilter("Posting Date", '<=%1', MaxPostingDate);
                if ShowDialog then begin
                    Window.Open(Text001);
                    Counter := 0;
                end;
                StartTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord();
            begin
                RecordDeleted := false;
                if ShowDialog then begin
                    Counter += 1;
                    if ((Counter MOD 1000) = 0) or (Counter = 1) then
                        Window.Update(1, Format("Entry No.") + ' (' + Format(Counter) + ')');
                end;

                if not ItemLedgerEntry.Get(ItemApplnEntry."Item Ledger Entry No.") then begin
                    ItemApplnEntry.Delete();
                    RecordDeleted := true;
                    DeleteCount += 1;
                end;

                if not RecordDeleted then begin
                    if not ItemLedgerEntry.Get(ItemApplnEntry."Inbound Item Entry No.") then begin
                        ItemApplnEntry.Delete();
                        RecordDeleted := true;
                        DeleteCount += 1;
                    end;
                end;

                if not RecordDeleted then begin
                    if not ItemLedgerEntry.Get(ItemApplnEntry."Outbound Item Entry No.") then begin
                        ItemApplnEntry.Delete();
                        RecordDeleted := true;
                        DeleteCount += 1;
                    end;
                end;
            end;

            trigger OnPostDataItem();
            begin
                if not ShowDialog then exit;
                Window.Close();
                //Message('Item Application Check and Orphan Records Deleted: %1\Start Time: %2 End Time: %3 (%4)', DeleteCount, StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
            end;
        }
    }

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        ShowDialog := vShowDialog;
    end;

    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecordDeleted: Boolean;
        DeleteCount: Integer;
        Text001: Label '[4/8] Deleting Orphaned Item Application Entry No. ########1#####';
        Counter: Integer;
        TotalCount: Integer;
        Window: Dialog;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        MaxPostingDate: Date;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
}
