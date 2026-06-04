report 14305129 "Delete Orphan Item Appl. Entry"
{
    Caption = 'Delete Orphan Item Appl. Entry';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    dataset
    {
        dataitem(ItemApplnEntry; "Item Application Entry")
        {
            trigger OnPreDataItem();
            begin
                Window.Open(Text001);
                StartTime := TIME; // SBC 2019-07-29
            end;

            trigger OnAfterGetRecord();
            begin
                RecordDeleted := false;
                if (ItemApplnEntry."Entry No." MOD 1000) = 0 then
                    Window.Update(1, Format(ItemApplnEntry."Entry No." DIV 1000) + '->' + Format(ItemApplnEntry."Entry No."));

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
                Window.Close();
                Message('Item Application Check and Orphan Records Deleted: %1\Start Time: %2 End Time: %3', DeleteCount, StartTime, TIME);
            end;
        }
    }

    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecordDeleted: Boolean;
        DeleteCount: Integer;
        Text001: Label 'Processing Entry No.';
        Window: Dialog;
        StartTime: Time;
}
