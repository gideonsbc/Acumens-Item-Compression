report 14305136 "AQDLC Post-Compress Invt. Val"
{
    Caption = 'Post-Compression Inventory Valuation';
    ProcessingOnly = true;
    ApplicationArea = All;
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD;
    dataset
    {
        dataitem(QoH; "AQDLC Qty on Hand")
        {
            DataItemTableView = SORTING("Item No.");

            trigger OnPreDataItem();
            begin
                if ShowDialog then
                    Window.Open(Text001);

                ILECompressionSetup.Get();
            end;

            trigger OnAfterGetRecord();
            begin
                if ShowDialog then begin
                    if Counter MOD 1000 = 0 then
                        Window.Update(1, Format(Counter DIV 1000) + ' -> ' + "Item No.");
                end;

                if not Item.Get(QoH."Item No.") then
                    CurrReport.Skip();

                QoH."Net Qty On Hand" := QoH."Qty On Hand" + QoH."Applied Quanty";
                if QoH."Net Qty On Hand" = 0 then
                    CurrReport.Skip();

                ILE.SetRange("Item No.", "Item No.");
                ILE.SetFilter("Posting Date", '<=%1', "Posting Date");
                if ILECompressionSetup."Group by Location Code" then
                    ILE.SetRange("Location Code", "Location Code");
                if ILECompressionSetup."Group by Variant Code" then
                    ILE.SetRange("Variant Code", "Variant Code");
                if ILECompressionSetup."Group by Lot No." then
                    ILE.SetRange("Lot No.", "Lot No.");
                if ILECompressionSetup."Group by Serial No." then
                    ILE.SetRange("Serial No.", "Serial No.");
                if ILECompressionSetup."Group by Package No." then
                    ILE.SetRange("Package No.", "Package No.");
                if ILE.FindSet() then
                    repeat
                        ILE.CalcFields("Cost Amount (Actual)");
                        "Qty On Hand After" += ILE.Quantity;
                        "Inventory Value After" += ILE."Cost Amount (Actual)";
                    until ILE.Next() = 0;

                if "Qty On Hand After" <> 0 then
                    "Unit Cost After" := "Inventory Value After" / "Qty On Hand";
                "Quantity Variance" := "Qty On Hand After" - "Qty On Hand";
                "Valuation Variance" := "Inventory Value After" - "Inventory Value Before";
                Modify();
            end;

            trigger OnPostDataItem();
            begin
                if not ShowDialog then exit;
                Window.Close();
                Message('Batch process execution is completed - 4 Create ILE Entries using QoH\Start Time: %1 End Time: %2', StartTime, TIME);
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
        VE: Record 5802;
        Item: Record 27;
        Window: Dialog;
        Text001: Label 'Processing Item No.  ########1#####';
        Counter: Integer;
        StartTime: Time;
        ProcessDate: Date;
        ShowDialog: Boolean;
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        CompressionRegNo: Integer;

}
