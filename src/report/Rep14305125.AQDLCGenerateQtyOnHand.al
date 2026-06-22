report 14305125 "AQDLC Generate Qty On Hand"
{
    Caption = 'Generate Quantity On Hand';
    ProcessingOnly = true;
    ApplicationArea = All;

    Permissions = tabledata "Transfer Line" = rimd;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            dataitem(ItemLedgerEntry; "Item Ledger Entry")
            {
                DataItemTableView = SORTING("Item No.", "Posting Date") where("Completely Invoiced" = filter(true));
                DataItemLink = "Item No." = FIELD("No.");

                trigger OnAfterGetRecord()
                var
                    VLE: Record "Value Entry";
                    InvtValue: Decimal;
                begin
                    if ("Entry Type" = "Entry Type"::Transfer) and ("Document Type" = "Document Type"::"Transfer Shipment") then
                        if not TransferCompletelyReceived(ItemLedgerEntry) then
                            CurrReport.Skip();

                    CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                    InvtValue := "Cost Amount (Actual)";
                    if "Cost Amount (Actual)" = 0 then
                        InvtValue := "Cost Amount (Expected)";
                    if (Quantity = 0) and (InvtValue <> 0) then begin
                        "AQDLC Skip Compressing" := true;
                        Modify();
                        CurrReport.Skip();
                    end;
                    QoH.Reset();
                    QoH.SetRange("Item No.", "Item No.");
                    QoH.SetRange("Register No.", CompressionRegNo);
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

                        UpdateInventoryValueAndUnitCost(QoH, ItemLedgerEntry);
                        QoH.Modify();
                    end else begin
                        QoH.Init();
                        QoH."Entry No." := LastQoHEntryNo;
                        QoH."Register No." := CompressionRegNo;
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
                        UpdateInventoryValueAndUnitCost(QoH, ItemLedgerEntry);
                        QoH."Posting Date" := MaxPostingDate;
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
                StartTime := CurrentDateTime;
                Counter := 0;
            end;

            trigger OnAfterGetRecord()
            var
                ILEMod: Record "Item Ledger Entry";
            begin
                if ShowDialog then begin
                    if (Counter MOD 1000) = 0 then
                        Window.Update(1, Format((Counter DIV 1000)) + '->' + Item."No.");
                end;

                ILEMod.SetRange("Item No.", "No.");
                ILEMod.SetRange("AQDLC Skip Compressing", true);
                if ILEMod.Find('-') then
                    ILEMod.ModifyAll("AQDLC Skip Compressing", false);

                QoH.Reset();
                QoH.SetRange("Item No.", Item."No.");
                QoH.SetRange("Register No.", CompressionRegNo);
                QoH.DeleteAll();
                Counter += 1;

                GetItemValuationBefore(Item);
            end;

            trigger OnPostDataItem()
            begin
                if not ShowDialog then exit;
                Window.Close();
                Message(
                  'Batch process execution is completed - 1 Generate Quantity On Hand\Start Time: %1 End Time: %2\%3',
                  StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
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

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vCompressionScheduleNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        CompressionScheduleNo := vCompressionScheduleNo;
        ShowDialog := vShowDialog;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        // Tables
        QoH: Record "AQDLC Qty on Hand";
        ItemApplicationEntry: Record "Item Application Entry";

        // Counters / control
        LastQoHEntryNo: Integer;
        Counter: Integer;
        MaxPostingDate: Date;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";

        // UI / messages
        Window: Dialog;
        Text001: Label 'Processing Item No. ###########1######';
        Text002: Label 'Item Ledger Entry Backup is not taken. Please take Item Ledger Entry Backup before starting Process.';
        Text003: Label 'Value Entry Backup is not taken. Please take Item Ledger Entry Backup before starting Process.';
        Text004: Label 'Item Application Entry Backup is not taken. Please take Item Ledger Entry Backup before starting Process.';
        Text005: Label 'Are batch processes Report 795 "Adjust Cost - Item Entries" and Report 1002 "Post Inventory Cost to G/L" completed?';
        Text006: Label 'Report Execution is aborted to respect user''s decision.';
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
        CompressionScheduleNo: Integer;

    local procedure UpdateInventoryValueAndUnitCost(var vQoH: Record "AQDLC Qty on Hand"; var ILE: Record "Item Ledger Entry")
    begin
        ILE.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
        if ILE."Cost Amount (Actual)" <> 0 then
            vQoH."Inventory Value" += ILE."Cost Amount (Actual)"
        else
            vQoH."Inventory Value" += ILE."Cost Amount (Expected)";
        if vQoH."Qty On Hand" <> 0 then
            vQoH."Unit Cost" := vQoH."Inventory Value" / vQoH."Qty On Hand";

        vQoH."Item Qty On Hand Before" := ItemQtyOnHandBefore;
        vQoH."Item Unit Cost Before" := ItemUnitCostBefore;
        vQoH."Item Inventory Value Before" := ItemInventoryValueBefore;
    end;

    var
        ItemQtyOnHandBefore: Decimal;
        ItemUnitCostBefore: Decimal;
        ItemInventoryValueBefore: Decimal;

    local procedure GetItemValuationBefore(vItem: Record Item)
    var
        vILE: Record "Item Ledger Entry";
        ItemValuationComparison: Record "AQDLC Item Valuation Comparisn";
    begin
        ItemQtyOnHandBefore := 0;
        ItemUnitCostBefore := 0;
        ItemInventoryValueBefore := 0;

        vILE.SetRange("Item No.", vItem."No.");
        vILE.SetFilter("Posting Date", '<=%1', MaxPostingDate);
        if vILE.FindSet() then
            repeat
                vILE.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                ItemQtyOnHandBefore += vILE.Quantity;
                if vILE."Cost Amount (Actual)" <> 0 then
                    ItemInventoryValueBefore += vILE."Cost Amount (Actual)"
                else
                    ItemInventoryValueBefore += vILE."Cost Amount (Expected)";
            until vILE.Next() = 0;
        if ItemQtyOnHandBefore <> 0 then
            ItemUnitCostBefore := ItemInventoryValueBefore / ItemQtyOnHandBefore;

        if not ItemValuationComparison.Get(CompressionRegNo, vItem."No.") then begin
            ItemValuationComparison.Init();
            ItemValuationComparison."Register No." := CompressionRegNo;
            ItemValuationComparison."Item No." := vItem."No.";
            ItemValuationComparison."Item Description" := vItem.Description;
            ItemValuationComparison."Cut-off Date" := MaxPostingDate;
            ItemValuationComparison."Remaining Qty Before" := ItemQtyOnHandBefore;
            ItemValuationComparison."Unit Cost Before" := ItemUnitCostBefore;
            ItemValuationComparison."Inventory Value Before" := ItemInventoryValueBefore;
            ItemValuationComparison."Schedule No." := CompressionScheduleNo;
            ItemValuationComparison.Insert();
        end else begin
            ItemValuationComparison."Remaining Qty Before" := ItemQtyOnHandBefore;
            ItemValuationComparison."Unit Cost Before" := ItemUnitCostBefore;
            ItemValuationComparison."Inventory Value Before" := ItemInventoryValueBefore;
            ItemValuationComparison.Modify();
        end;
    end;

    procedure TransferCompletelyReceived(var vILE: Record "Item Ledger Entry"): Boolean
    var
        TransferLine: Record "Transfer Line";
    begin
        if (vILE."Order No." = '') or (vILE."Order Line No." = 0) then exit(true);

        if not TransferLine.Get(vILE."Order No.", vILE."Order Line No.") then
            exit(true)
        else
            exit(TransferLine."Completely Received");
    end;
}