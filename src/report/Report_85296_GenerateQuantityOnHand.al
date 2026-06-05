report 14305125 "Generate Quantity On Hand"
{
    Caption = 'Generate Quantity On Hand';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;


    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            dataitem(ItemLedgerEntry; "Item Ledger Entry")
            {
                DataItemTableView = SORTING("Item No.", "Posting Date");
                DataItemLink = "Item No." = FIELD("No.");

                trigger OnAfterGetRecord()
                var
                    VLE: Record "Value Entry";
                begin
                    CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                    QoH.Reset();
                    QoH.SetRange("Item No.", "Item No.");
                    if ILECompressionSetup."Group by Location Code" then
                        QoH.SetRange("Location Code", "Location Code");
                    if ILECompressionSetup."Group by Variant Code" then
                        QoH.SetRange("Variant Code", "Variant Code");
                    if ILECompressionSetup."Group by Lot No." then
                        QoH.SetRange("Lot No.", "Lot No.");
                    if ILECompressionSetup."Group by Serial No." then
                        QoH.SetRange("Serial No.", "Serial No.");
                    if ILECompressionSetup."Group by Package No." then
                        QoH.SetRange("Package No.", "Package No.");

                    if QoH.FindFirst() then begin
                        QoH."Qty On Hand" += Quantity;

                        if "Entry Type" in ["Entry Type"::Purchase, "Entry Type"::"Positive Adjmt."] then begin
                            CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                            if "Cost Amount (Actual)" <> 0 then
                                QoH."Last Puchase/ +Ve Unit Cost" := "Cost Amount (Actual)" / "Invoiced Quantity"
                            else
                                QoH."Last Puchase/ +Ve Unit Cost" := "Cost Amount (Expected)" / Quantity;
                        end;

                        QoH.Modify();
                    end else begin
                        QoH.Init();
                        QoH."Entry No." := LastQoHEntryNo;
                        QoH."Item No." := "Item No.";
                        if ILECompressionSetup."Group by Location Code" then
                            QoH."Location Code" := "Location Code";
                        if ILECompressionSetup."Group by Variant Code" then
                            QoH."Variant Code" := "Variant Code";
                        if ILECompressionSetup."Group by Lot No." then
                            QoH."Lot No." := "Lot No.";
                        if ILECompressionSetup."Group by Serial No." then
                            QoH."Serial No." := "Serial No.";
                        if ILECompressionSetup."Group by Package No." then
                            QoH."Package No." := "Package No.";
                        QoH."Qty On Hand" := Quantity;

                        if "Entry Type" in ["Entry Type"::Purchase, "Entry Type"::"Positive Adjmt."] then begin
                            CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                            if "Cost Amount (Actual)" <> 0 then
                                QoH."Last Puchase/ +Ve Unit Cost" := "Cost Amount (Actual)" / "Invoiced Quantity"
                            else
                                QoH."Last Puchase/ +Ve Unit Cost" := "Cost Amount (Expected)" / Quantity;
                        end;

                        QoH.Insert();
                        LastQoHEntryNo += 1;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    QoH.Reset();
                    QoH.SetRange("Item No.", Item."No.");
                    QoH.SetRange("Qty On Hand", 0);
                    QoH.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    ILECompressionSetup.Get();
                    ItemLedgerEntry.SetFilter("Posting Date", '<=%1', MaxPostingDate);
                end;
            }
            trigger OnPreDataItem()
            begin
                if MaxPostingDate = 0D then
                    MaxPostingDate := DMY2DATE(1, 1, 2025);


                if QoH.FindLast() then
                    LastQoHEntryNo := QoH."Entry No." + 1
                else
                    LastQoHEntryNo := 1;

                if ShowDialog then
                    Window.Open(Text001);
                StartTime := TIME;
                Counter := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                if ShowDialog then begin
                    if (Counter MOD 1000) = 0 then
                        Window.Update(1, Format((Counter DIV 1000)) + '->' + Item."No.");
                end;

                QoH.Reset();
                QoH.SetRange("Item No.", Item."No.");
                QoH.DeleteAll();
                Counter += 1;
            end;

            trigger OnPostDataItem()
            begin
                if not ShowDialog then exit;
                Window.Close();
                Message(
                  'Batch process execution is completed - 1 Generate Quantity On Hand\Start Time: %1 End Time: %2',
                  StartTime,
                  TIME);
            end;
        }
    }

    trigger OnPreReport()
    begin
        // Check Item Ledger Entry, Value Entry or Item Application Entry backup are taken
        if not ShowDialog then exit;
        if not Confirm(Text005, false) then
            Error(Text006);
    end;

    procedure SetRunParameters(vMaxPostingDate: Date; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        ShowDialog := vShowDialog;
    end;

    var
        ILECompressionSetup: Record "AQD ILE Compression Setup";
        // Tables
        QoH: Record "AQD Quantity on Hand";
        ItemApplicationEntry: Record "Item Application Entry";

        // Counters / control
        LastQoHEntryNo: Integer;
        Counter: Integer;
        MaxPostingDate: Date;
        StartTime: Time;

        // UI / messages
        Window: Dialog;
        Text001: Label 'Processing Item No. ###########1######';
        Text002: Label 'Item Ledger Entry Backup is not taken. Please take Item Ledger Entry Backup before starting Process.';
        Text003: Label 'Value Entry Backup is not taken. Please take Item Ledger Entry Backup before starting Process.';
        Text004: Label 'Item Application Entry Backup is not taken. Please take Item Ledger Entry Backup before starting Process.';
        Text005: Label 'Are batch processes Report 795 "Adjust Cost - Item Entries" and Report 1002 "Post Inventory Cost to G/L" completed?';
        Text006: Label 'Report Execution is aborted to respect user''s decision.';
        ShowDialog: Boolean;
}