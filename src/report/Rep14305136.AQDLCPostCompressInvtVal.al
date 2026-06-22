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
                if ShowDialog then
                    Window.Open(Text001);
                StartTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord();
            begin
                if ShowDialog then begin
                    if Counter MOD 1000 = 0 then
                        Window.Update(1, Format(Counter DIV 1000) + ' -> ' + "Item No.");
                end;

                ILE.SetRange("Item No.", "Item No.");
                ILE.SetFilter("Posting Date", '<=%1', "Cut-off Date");
                if ILE.FindSet() then
                    repeat
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
                Message('Batch process execution is completed - Post-compression valuation\Start Time: %1 End Time: %2 (%3)', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
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
        Text001: Label 'Processing Item No.  ########1#####';
        Counter: Integer;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        ProcessDate: Date;
        ShowDialog: Boolean;
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        CompressionRegNo: Integer;

}
