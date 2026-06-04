report 14305131 "Create Item Application"
{
    Caption = 'Create Item Application';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    dataset
    {
        dataitem(ILE; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Document No.", "Posting Date"); // WHERE(PostDate, Document No. filter applied in request in NAV — handled by RequestPage or runtime filters)

            trigger OnPreDataItem();
            begin
                //PositiveILE.FindLast;
                //PositiveVLE.FindLast;
                ItemApplicationEntry.FindLast();

                //NextItemLdgrEntryNo := PositiveILE."Entry No." + 1;
                //NextValueEntryNo := PositiveVLE."Entry No." + 1;
                NextItemLdgrEntryNo := 85000;
                NextValueEntryNo := 85000;

                NextItemApplicationEntryNo := ItemApplicationEntry."Entry No." + 1;
                StartTime := TIME;
            end;

            trigger OnAfterGetRecord();
            begin
                "Document Type" := "Document Type"::" ";
                "Document Line No." := 0;
                Positive := Quantity > 0;
                Modify();

                ItemApplicationEntry.Reset();
                ItemApplicationEntry.SetCurrentKey("Item Ledger Entry No.", "Output Completely Invd. Date");
                ItemApplicationEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                if Positive then begin
                    ItemApplicationEntry.SetRange("Inbound Item Entry No.", "Entry No.");
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", 0);
                    if ItemApplicationEntry.FindFirst() then begin
                        ItemApplicationEntry.Quantity := Quantity;
                        ItemApplicationEntry.Modify();
                        ItemApplicationUpdated += 1;
                    end else begin
                        NewItemApplicationEntry.Init();
                        NewItemApplicationEntry."Entry No." := NextItemApplicationEntryNo;
                        NewItemApplicationEntry."Item Ledger Entry No." := "Entry No.";
                        NewItemApplicationEntry."Inbound Item Entry No." := "Entry No.";
                        NewItemApplicationEntry."Outbound Item Entry No." := 0;
                        NewItemApplicationEntry.Quantity := Quantity;
                        NewItemApplicationEntry."Posting Date" := "Posting Date";
                        NewItemApplicationEntry."Transferred-from Entry No." := 0;
                        NewItemApplicationEntry."Creation Date" := CreateDateTime("Posting Date", TIME);
                        NewItemApplicationEntry."Cost Application" := true;
                        NewItemApplicationEntry."Output Completely Invd. Date" := "Posting Date";
                        NewItemApplicationEntry.Insert();
                        NextItemApplicationEntryNo += 1;
                        ItemApplicationCreated += 1;
                    end;
                end else begin
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", "Entry No.");
                    if ItemApplicationEntry.FindFirst() then
                        ItemApplicationEntry.Delete();

                    ItemApplicationEntry.SetRange("Item Ledger Entry No.");
                    if ItemApplicationEntry.FindFirst() then begin
                        repeat
                            ItemApplicationEntry."Outbound Item Entry No." := 0;
                            ItemApplicationEntry.Modify();
                        until ItemApplicationEntry.Next() = 0;
                    end;

                    PositiveILE.Init();
                    PositiveILE := ILE;
                    PositiveILE."Entry Type" := PositiveILE."Entry Type"::"Positive Adjmt.";
                    PositiveILE."Entry No." := NextItemLdgrEntryNo;
                    PositiveILE.Quantity := -1 * PositiveILE.Quantity; // Reserve Sign to make it positive
                    PositiveILE."Remaining Quantity" := -1 * PositiveILE."Remaining Quantity";
                    PositiveILE."Invoiced Quantity" := PositiveILE.Quantity;
                    PositiveILE.Positive := PositiveILE.Quantity > 0;
                    PositiveILE.Insert();
                    NextItemLdgrEntryNo += 1;

                    NegativeVLE.Reset();
                    NegativeVLE.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                    NegativeVLE.SetRange("Item Ledger Entry No.", "Entry No.");
                    if NegativeVLE.FindFirst() then begin
                        repeat
                            PositiveVLE.Init();
                            PositiveVLE := NegativeVLE;
                            PositiveVLE."Entry No." := NextValueEntryNo;
                            PositiveVLE."Item Ledger Entry No." := PositiveILE."Entry No.";
                            PositiveVLE."Item Ledger Entry Type" := PositiveVLE."Item Ledger Entry Type"::"Positive Adjmt.";
                            PositiveVLE."Valued Quantity" := PositiveILE.Quantity;
                            PositiveVLE."Item Ledger Entry Quantity" := PositiveILE.Quantity;
                            PositiveVLE."Invoiced Quantity" := PositiveILE."Invoiced Quantity";
                            PositiveVLE."Cost Amount (Actual)" := -1 * NegativeVLE."Cost Amount (Actual)";
                            PositiveVLE."Cost Posted to G/L" := -1 * NegativeVLE."Cost Posted to G/L";
                            PositiveVLE.Insert();
                            NextValueEntryNo += 1;
                        until NegativeVLE.Next() = 0;
                    end;

                    // For Positive ILE
                    NewItemApplicationEntry.Init();
                    NewItemApplicationEntry."Entry No." := NextItemApplicationEntryNo;
                    NewItemApplicationEntry."Item Ledger Entry No." := PositiveILE."Entry No.";
                    NewItemApplicationEntry."Inbound Item Entry No." := PositiveILE."Entry No.";
                    NewItemApplicationEntry."Outbound Item Entry No." := 0;
                    NewItemApplicationEntry.Quantity := PositiveILE.Quantity;
                    NewItemApplicationEntry."Posting Date" := PositiveILE."Posting Date";
                    NewItemApplicationEntry."Transferred-from Entry No." := 0;
                    NewItemApplicationEntry."Creation Date" := CreateDateTime(PositiveILE."Posting Date", TIME);
                    NewItemApplicationEntry."Cost Application" := true;
                    NewItemApplicationEntry."Output Completely Invd. Date" := PositiveILE."Posting Date";
                    NewItemApplicationEntry.Insert();
                    NextItemApplicationEntryNo += 1;
                    ItemApplicationCreated += 1;

                    // For Negative ILE
                    NewItemApplicationEntry.Init();
                    NewItemApplicationEntry."Entry No." := NextItemApplicationEntryNo;
                    NewItemApplicationEntry."Item Ledger Entry No." := "Entry No.";
                    NewItemApplicationEntry."Inbound Item Entry No." := PositiveILE."Entry No.";
                    NewItemApplicationEntry."Outbound Item Entry No." := "Entry No.";
                    NewItemApplicationEntry.Quantity := Quantity;
                    NewItemApplicationEntry."Posting Date" := "Posting Date";
                    NewItemApplicationEntry."Transferred-from Entry No." := 0;
                    NewItemApplicationEntry."Creation Date" := CreateDateTime("Posting Date", TIME);
                    NewItemApplicationEntry."Cost Application" := true;
                    NewItemApplicationEntry."Output Completely Invd. Date" := "Posting Date";
                    NewItemApplicationEntry.Insert();
                    NextItemApplicationEntryNo += 1;
                    ItemApplicationCreated += 1;
                end;
            end;

            trigger OnPostDataItem();
            begin
                Message('Item Application Created %1 Modified %2\Start Time: %3 End Time: %4', ItemApplicationCreated, ItemApplicationUpdated, StartTime, TIME);
            end;
        }
    }

    var
        ItemApplicationEntry: Record 339;
        NewItemApplicationEntry: Record 339;
        NextItemApplicationEntryNo: Integer;
        ItemApplicationCreated: Integer;
        ItemApplicationUpdated: Integer;
        PositiveILE: Record "Item Ledger Entry";
        NegativeVLE: Record 5802;
        PositiveVLE: Record 5802;
        NextItemLdgrEntryNo: Integer;
        NextValueEntryNo: Integer;
        StartTime: Time;
}
