report 14305133 "Move ILE To Old Number"
{
    Caption = 'Move ILE To Old Number';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    dataset
    {
        dataitem(ILE; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Document No.", "Posting Date");

            trigger OnPreDataItem();
            begin
                ILE.SetFilter("Entry No.", '>=%1', 2867147); // Check ILE and update filter if necessary

                // Apply the NAV WHERE filters from the original object
                ILE.SetRange("Posting Date", 20141231D);
                ILE.SetFilter("Document No.", '%1', 'QOH-123114');

                StartingILENumber := 81005;
                StartingVLENumber := 81005;

                Window.Open(Text001);
                StartTime := TIME; // SBC 2019-07-29
            end;

            trigger OnAfterGetRecord();
            begin
                if ("Entry No." MOD 1000) = 0 then
                    Window.Update(1, Format("Entry No." DIV 1000) + '->' + Format("Entry No."));

                NewILE.Init();
                NewILE := ILE;
                NewILE."Entry No." := StartingILENumber;
                NewILE.Insert();
                StartingILENumber += 1;

                OldVLE.Reset();
                OldVLE.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                OldVLE.SetRange("Item Ledger Entry No.", "Entry No.");
                if OldVLE.FindFirst() then begin
                    repeat
                        NewVLE.Init();
                        NewVLE := OldVLE;
                        NewVLE."Entry No." := StartingVLENumber;
                        NewVLE."Item Ledger Entry No." := NewILE."Entry No.";
                        NewVLE.Insert();
                        OldVLE.Delete();
                        StartingVLENumber += 1;
                    until OldVLE.Next() = 0;
                end;

                Delete();
            end;

            trigger OnPostDataItem();
            begin
                Window.Close();
                Message('Item Application Check and Orphan Records\Start Time: %1 End Time: %2', StartTime, TIME);
            end;
        }
    }

    var
        StartingILENumber: Integer;
        StartingVLENumber: Integer;
        NewILE: Record "Item Ledger Entry";
        NewVLE: Record 5802;
        OldVLE: Record 5802;
        Window: Dialog;
        StartTime: Time;
        Text001: Label 'Processing Entry No.';
}
