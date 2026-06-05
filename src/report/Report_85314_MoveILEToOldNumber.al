report 14305133 "Move ILE To Old Number"
{
    Caption = 'Move ILE To Old Number';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    Permissions = tabledata "Item Ledger Entry" = rimd,
                    tabledata "Value Entry" = rimd,
                    tabledata "Item Application Entry" = rimd;
    dataset
    {
        dataitem(ILE; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Document No.", "Posting Date");

            trigger OnPreDataItem();
            begin
                //=>ILE.SetFilter("Entry No.", '>=%1', 2867147); // Check ILE and update filter if necessary | not necessary

                // Apply the NAV WHERE filters from the original object
                ILE.SetRange("Posting Date", MaxPostingDate);
                ILE.SetFilter("Document No.", '%1', 'QOH-' + Format(MaxPostingDate));

                //=>StartingILENumber := 81005;
                //=>StartingVLENumber := 81005;

                if ShowDialog then
                    Window.Open(Text001);
                StartTime := TIME;
            end;

            trigger OnAfterGetRecord();
            var
                ItemApplicationEntry: Record "Item Application Entry";
            begin
                if ShowDialog then begin
                    if ("Entry No." MOD 1000) = 0 then
                        Window.Update(1, Format("Entry No." DIV 1000) + '->' + Format("Entry No."));
                end;

                NewILE.Init();
                NewILE := ILE;
                NewILE."Entry No." := StartingILENumber;
                NewILE.Insert();

                ItemApplicationEntry.SetRange("Item Ledger Entry No.", ILE."Entry No.");
                if ItemApplicationEntry.Find('-') then
                    ItemApplicationEntry.ModifyAll("Item Ledger Entry No.", NewILE."Entry No.");

                ItemApplicationEntry.SetRange("Inbound Item Entry No.", ILE."Entry No.");
                if ItemApplicationEntry.Find('-') then
                    ItemApplicationEntry.ModifyAll("Inbound Item Entry No.", NewILE."Entry No.");

                ItemApplicationEntry.SetRange("Outbound Item Entry No.", ILE."Entry No.");
                if ItemApplicationEntry.Find('-') then
                    ItemApplicationEntry.ModifyAll("Outbound Item Entry No.", NewILE."Entry No.");

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
                if not ShowDialog then exit;
                Window.Close();
                Message('Item Application Check and Orphan Records\Start Time: %1 End Time: %2', StartTime, TIME);
            end;
        }
    }

    procedure SetRunParameters(vStartingILENumber: Integer; vStartingVLENumber: Integer; vMaxPostingDate: Date; vShowDialog: Boolean)
    begin
        StartingILENumber := vStartingILENumber;
        StartingVLENumber := vStartingVLENumber;
        MaxPostingDate := vMaxPostingDate;
        ShowDialog := vShowDialog;
    end;

    var
        StartingILENumber: Integer;
        StartingVLENumber: Integer;
        NewILE: Record "Item Ledger Entry";
        NewVLE: Record 5802;
        OldVLE: Record 5802;
        Window: Dialog;
        StartTime: Time;
        Text001: Label 'Processing Entry No. ########1#####';
        MaxPostingDate: Date;
        ShowDialog: Boolean;
}
