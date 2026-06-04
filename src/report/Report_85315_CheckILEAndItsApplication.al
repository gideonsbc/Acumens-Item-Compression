report 14305134 "Check ILE & Its Application"
{
    Caption = 'Check ILE & Its Application';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    dataset
    {
        dataitem(ILE; "Item Ledger Entry")
        {
            DataItemTableView = WHERE(Positive = CONST(true), Quantity = FILTER(> 0));

            trigger OnPreDataItem();
            begin
                Window.Open(Text001);
                StartTime := TIME;
                Counter := 0;
            end;

            trigger OnAfterGetRecord();
            var
                AppliedQuantityLocal: Decimal;
            begin
                if (ILE."Entry No." MOD 1000) = 0 then
                    Window.Update(1, Format(ILE."Entry No." DIV 1000) + '->' + Format(ILE."Entry No."));

                AppliedQuantity := 0;
                ItemApplicationEntry.Reset();
                ItemApplicationEntry.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
                ItemApplicationEntry.SetFilter("Item Ledger Entry No.", '<>%1', ILE."Entry No.");
                ItemApplicationEntry.SetRange("Inbound Item Entry No.", ILE."Entry No.");
                ItemApplicationEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
                if ItemApplicationEntry.Find('-') then
                    repeat
                        AppliedQuantity += ItemApplicationEntry.Quantity;
                    until ItemApplicationEntry.Next() = 0;

                if (ILE.Quantity + AppliedQuantity) <> ILE."Remaining Quantity" then begin
                    TmpILE.Init();
                    TmpILE := ILE;
                    TmpILE.Insert();
                end;

                Counter += 1;
            end;

            trigger OnPostDataItem();
            begin
                Window.Close();
                TmpILE.Reset();
                if TmpILE.Count() <> 0 then
                    Message('Found %1 mismatch(es). Please review TmpILE temporary table.', TmpILE.Count())
                else
                    Message('Item and its applications are matching\Start Time: %1 End Time: %2', StartTime, TIME);
            end;
        }
    }

    var
        ItemApplicationEntry: Record "Item Application Entry";
        AppliedQuantity: Decimal;
        TmpILE: Record "Item Ledger Entry" temporary;
        Window: Dialog;
        Text001: Label 'Processing Entry No.';
        StartTime: Time;
        Counter: Integer;
}
