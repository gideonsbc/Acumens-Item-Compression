report 14305130 "AQDLC Compress Add. Tables Rec"
{

    Caption = 'Compress Additional Tables like Registers';
    ProcessingOnly = true;
    ApplicationArea = All;

    Permissions = tabledata "Inventory Comment Line" = rimd,
                    tabledata "G/L - Item Ledger Relation" = rimd,
                    tabledata "Item Register" = rimd,
                    tabledata "Item Journal Line" = rimd,
                    tabledata "Planning Assignment" = rimd,
                    tabledata "G/L Entry" = rimd,
                    tabledata "Warehouse Register" = rimd,
                    tabledata "Warehouse Entry" = rimd,
                    tabledata "Phys. Inventory Ledger Entry" = rimd,
                    tabledata "Capacity Ledger Entry" = rimd;
    dataset
    {
    }
    trigger OnInitReport();
    begin
        StartTime := CurrentDateTime;
    end;

    trigger OnPreReport();
    var
        DateToFilter: Date;
        DeleteRecord: Boolean;
    begin
        if ShowDialog then
            Window.Open('[7/7] Compressing Additional Tables...');
        DateToFilter := MaxPostingDate;
        if DateToFilter = 0D then
            DateToFilter := DMY2DATE(1, 1, 2015);

        /*

        ItemJnlLine.DeleteAll();*/

        // LedgerEntryDimension.Reset();
        // LedgerEntryDimension.SetFilter("Table ID", '%1|%2', 32, 5802);
        // if LedgerEntryDimension.FindFirst() then begin
        //     repeat
        //         if LedgerEntryDimension."Table ID" = 32 then begin
        //             if not ItemLdgrEntry.Get(LedgerEntryDimension."Entry No.") then
        //                 LedgerEntryDimension.Delete();
        //         end else if LedgerEntryDimension."Table ID" = 5802 then begin
        //             if not ValueEntry.Get(LedgerEntryDimension."Entry No.") then
        //                 LedgerEntryDimension.Delete();
        //         end;
        //     until LedgerEntryDimension.Next() = 0;
        // end;
        InventoryCommentLine.Reset();
        if InventoryCommentLine.FindFirst() then begin
            repeat
                case InventoryCommentLine."Document Type" of
                    InventoryCommentLine."Document Type"::"Transfer Order":
                        begin
                            if not TransferLine.Get(InventoryCommentLine."No.", InventoryCommentLine."Line No.") then
                                InventoryCommentLine.Delete();
                        end;
                    InventoryCommentLine."Document Type"::"Posted Transfer Shipment":
                        begin
                            if not TransferShptLine.Get(InventoryCommentLine."No.", InventoryCommentLine."Line No.") then
                                InventoryCommentLine.Delete();
                        end;
                    InventoryCommentLine."Document Type"::"Posted Transfer Receipt":
                        begin
                            if not TransferRcptLine.Get(InventoryCommentLine."No.", InventoryCommentLine."Line No.") then
                                InventoryCommentLine.Delete();
                        end;
                end;
            until InventoryCommentLine.Next() = 0;
        end;

        WhseRegister.SetCurrentKey("No.");
        WhseRegister.SetFilter("Creation Date", '<=%1', MaxPostingDate);
        if WhseRegister.FindSet() then
            repeat
                WhseEntry.SetRange("Entry No.", WhseRegister."From Entry No.", WhseRegister."To Entry No.");
                WhseEntry.SetFilter("Warehouse Register No.", '%1|%2', 0, WhseRegister."No.");
                if WhseEntry.IsEmpty() then
                    WhseRegister.Delete();
            until WhseRegister.Next() = 0;

        ItemRegister.SetCurrentKey("Creation Date");
        ItemRegister.SetFilter("Creation Date", '<=%1', DateToFilter);
        if ItemRegister.FindSet() then
            repeat
                DeleteRecord := true;
                ItemLdgrEntry.SetRange("Entry No.", ItemRegister."From Entry No.", ItemRegister."To Entry No.");
                ItemLdgrEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                ItemLdgrEntry.SetFilter("AQDLC Comp. Reg No.", '<>%1', CompressionRegNo);
                ItemLdgrEntry.SetFilter("Posting Date", '<=%1', DateToFilter);
                ValueEntry.SetRange("Entry No.", ItemRegister."From Entry No.", ItemRegister."To Entry No.");
                ValueEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                ValueEntry.SetFilter("AQDLC Comp. Reg No", '<>%1', CompressionRegNo);
                ValueEntry.SetFilter("Posting Date", '<=%1', DateToFilter);
                PhysInvtLedgEntry.SetRange("Entry No.", ItemRegister."From Phys. Inventory Entry No.", ItemRegister."To Phys. Inventory Entry No.");
                PhysInvtLedgEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                CapLedgEntry.SetRange("Entry No.", ItemRegister."From Capacity Entry No.", ItemRegister."To Capacity Entry No.");
                CapLedgEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                if not ItemLdgrEntry.IsEmpty() then
                    DeleteRecord := false
                else if not ValueEntry.IsEmpty() then
                    DeleteRecord := false
                else if not PhysInvtLedgEntry.IsEmpty() then
                    DeleteRecord := false
                else if not CapLedgEntry.IsEmpty() then
                    DeleteRecord := false;

                if DeleteRecord then
                    ItemRegister.Delete();
            until ItemRegister.Next() = 0;

        // Not Want to Delete
        //AvgCostAdjmtEntryPoint.RESET;
        //AvgCostAdjmtEntryPoint.SETFILTER("Valuation Date",'<%1',DateToFilter);
        //AvgCostAdjmtEntryPoint.SETRANGE("Cost Is Adjusted",TRUE);
        //AvgCostAdjmtEntryPoint.DELETEALL;

        /*GLItemLedgerRelation.Reset();
        if GLItemLedgerRelation.FindSet() then begin
            repeat
                DeleteRecord := false;

                if not GLEntry.Get(GLItemLedgerRelation."G/L Entry No.") then
                    DeleteRecord := true;
                if not ValueEntry.Get(GLItemLedgerRelation."Value Entry No.") then
                    DeleteRecord := true;

                if DeleteRecord then
                    GLItemLedgerRelation.Delete();
            until GLItemLedgerRelation.Next() = 0;
        end;*/

        //PlanningAssignment.DeleteAll();
    end;

    trigger OnPostReport();
    begin
        if not ShowDialog then exit;
        Window.Close();
        //Message('Report processing is completed.\Start Time: %1 End Time: %2 (%3)', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
    end;

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        ShowDialog := vShowDialog;
    end;


    var
        ItemRegister: Record 46;
        ItemJnlLine: Record 83;
        LedgerEntryDimension: Record 355;
        JnlLineDimension: Record 356;
        InventoryCommentLine: Record 5748;
        AvgCostAdjmtEntryPoint: Record 5804;
        GLItemLedgerRelation: Record 5823;
        PlanningAssignment: Record 99000850;
        ItemLdgrEntry: Record 32;
        ValueEntry: Record 5802;
        TransferLine: Record 5741;
        TransferShptLine: Record 5745;
        TransferRcptLine: Record 5747;
        PhysInvtLedgEntry: Record "Phys. Inventory Ledger Entry";
        CapLedgEntry: Record "Capacity Ledger Entry";
        GLEntry: Record 17;
        WhseRegister: Record "Warehouse Register";
        WhseEntry: Record "Warehouse Entry";
        DeleteRecord: Boolean;
        Window: Dialog;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        MaxPostingDate: Date;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
}
