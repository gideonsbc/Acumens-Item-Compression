report 14305136 "AQDLC Post-Compress Invt. Val"
{
    Caption = 'Post-Compression Inventory Valuation';
    ProcessingOnly = true;
    ApplicationArea = All;
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD;
    dataset
    {
        dataitem("AQDLC Item Valuation Comparisn"; "AQDLC Item Valuation Comparisn")
        {
            DataItemTableView = SORTING("Item No.");

            trigger OnPreDataItem();
            begin
                SetRange("Register No.", CompressionRegNo);
                if ShowDialog then begin
                    Window.Open(Text001);
                    Counter := 0;
                end;
                StartTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord();
            begin
                if ShowDialog then begin
                    Counter += 1;
                    if ((Counter MOD 10) = 0) or (Counter = 1) then
                        Window.Update(1, "Item No." + ' => ' + "Item Description" + ' (' + Format(Counter) + ')');
                end;

                Counter2 := 0;
                ILE.SetCurrentKey("Item No.", "Posting Date");
                ILE.SetRange("Item No.", "Item No.");
                ILE.SetFilter("Posting Date", '<=%1', "Cut-off Date");
                if ILE.FindSet() then
                    repeat
                        if ShowDialog then begin
                            Counter2 += 1;
                            if ((Counter2 MOD 1000) = 0) or (Counter2 = 1) then
                                Window.Update(2, Format(ILE."Entry No.") + ' (' + Format(Counter2) + ')');
                        end;
                        ILE.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
                        "Remaining Qty After" += ILE.Quantity;
                        if ILE."Cost Amount (Actual)" <> 0 then
                            "Inventory Value After" += ILE."Cost Amount (Actual)"
                        else
                            "Inventory Value After" += ILE."Cost Amount (Expected)";
                    until ILE.Next() = 0;

                if "Remaining Qty After" <> 0 then
                    "Unit Cost After" := "Inventory Value After" / "Remaining Qty After";
                "Quantity Variance" := "Remaining Qty After" - "Remaining Qty Before";
                "Valuation Variance" := "Inventory Value After" - "Inventory Value Before";
                Modify();
            end;

            trigger OnPostDataItem();
            begin
                if not ShowDialog then exit;
                Window.Close();
                //Message('Batch process execution is completed - Post-compression valuation\Start Time: %1 End Time: %2 (%3)', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
            end;
        }
    }

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vShowDialog: Boolean)
    begin
        ProcessDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        ShowDialog := vShowDialog;
    end;

    var
        ILEEntryNo: Integer;
        VEEntryNo: Integer;
        ILE: Record "Item Ledger Entry";
        VE: Record "Value Entry";
        Item: Record Item;
        Window: Dialog;
        Text001: Label '[6/7] Running Post-Compression Valuation for Item No.  ########1#####\ILE: ########2#####';
        Counter: Integer;
        TotalCount: Integer;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        ProcessDate: Date;
        ShowDialog: Boolean;
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        CompressionRegNo: Integer;
        Counter2: Integer;

}
