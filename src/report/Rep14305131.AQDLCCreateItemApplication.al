report 14305131 "AQDLC Create Item Application"
{
    Caption = 'Create Item Application';
    ProcessingOnly = true;
    ApplicationArea = All;

    Permissions = tabledata "Item Application Entry" = rimd,
                    tabledata "Item Ledger Entry" = rimd,
                    tabledata "Value Entry" = rimd;
    dataset
    {
        dataitem(ILE; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Item No.", "Posting Date"); // WHERE(PostDate, Document No. filter applied in request in NAV — handled by RequestPage or runtime filters)

            trigger OnPreDataItem();
            begin
                SetFilter("Posting Date", '<=%1', MaxPostingDate);
                SetRange("AQDLC Comp. Reg No.", CompressionRegNo);
                NextItemLdgrEntryNo := 1;
                NextValueEntryNo := 1;
                NextItemApplicationEntryNo := 1;

                /*if PositiveILE.FindLast then
                    NextItemLdgrEntryNo := PositiveILE."Entry No." + 1;

                if PositiveVLE.FindLast then
                    NextValueEntryNo := PositiveVLE."Entry No." + 1;*/
                if ItemApplicationEntry.FindLast() then
                    NextItemApplicationEntryNo := ItemApplicationEntry."Entry No." + 1;

                //NextItemLdgrEntryNo := 85000;
                //NextValueEntryNo := 85000;

                StartTime := CurrentDateTime;
                if ShowDialog then begin
                    Window.Open(Text001);
                    Counter := 0;
                end;
            end;

            trigger OnAfterGetRecord();
            begin
                if ShowDialog then begin
                    Counter += 1;
                    if ((Counter MOD 1000) = 0) or (Counter = 1) then
                        Window.Update(1, Format("Entry No.") + ' (' + Format(Counter) + ')');
                end;
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
                    if ItemApplicationEntry.FindFirst() then begin
                        ItemApplicationEntry.Quantity := Quantity;
                        ItemApplicationEntry.Modify();
                        ItemApplicationUpdated += 1;
                    end else begin
                        NewItemApplicationEntry.Init();
                        NewItemApplicationEntry."Entry No." := NextItemApplicationEntryNo;
                        NewItemApplicationEntry."Item Ledger Entry No." := "Entry No.";
                        NewItemApplicationEntry."Inbound Item Entry No." := 0;//PositiveILE."Entry No.";
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
            end;

            trigger OnPostDataItem();
            begin
                if not ShowDialog then exit;
                Window.Close();
                //Message('Item Application Created %1 Modified %2\Start Time: %3 End Time: %4 (%5)', ItemApplicationCreated, ItemApplicationUpdated, StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
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
        ItemApplicationEntry: Record "Item Application Entry";
        NewItemApplicationEntry: Record "Item Application Entry";
        NextItemApplicationEntryNo: Integer;
        ItemApplicationCreated: Integer;
        ItemApplicationUpdated: Integer;
        PositiveILE: Record "Item Ledger Entry";
        NegativeVLE: Record 5802;
        PositiveVLE: Record 5802;
        NextItemLdgrEntryNo: Integer;
        NextValueEntryNo: Integer;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        MaxPostingDate: Date;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
        Counter: Integer;
        TotalCount: Integer;
        Window: Dialog;
        Text001: Label '[5/7] Creating Item Application for ILE No. ###########1######';
}
