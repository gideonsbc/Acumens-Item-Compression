codeunit 14305124 "AQDLC Item Ledger Compression"
{
    TableNo = Item;

    Permissions = tabledata "Item Ledger Entry" = RIMD,
                    tabledata "Value Entry" = RIMD,
                    tabledata "Item Register" = rimd,
                    tabledata "G/L - Item Ledger Relation" = rimd,
                    tabledata "G/L Entry" = rimd,
                    tabledata "Item Application Entry" = rimd,
                    tabledata "Tracking Specification" = rimd,
                    tabledata "Warehouse Entry" = rimd,
                    tabledata Item = rimd,
                    tabledata "Inventory Comment Line" = rimd,
                    tabledata "Item Journal Line" = rimd,
                    tabledata "Planning Assignment" = rimd,
                    tabledata "Warehouse Register" = rimd,
                    tabledata "Phys. Inventory Ledger Entry" = rimd,
                    tabledata "Capacity Ledger Entry" = rimd;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        ILECompressionSingleInst: Codeunit "AQDLC ILE Compress Single Inst";
        ILECompressionTask: Text;
        //Params
        RegNo: Integer;
        EndingDate: Date;
        CalledFromRegisterNo: Integer;
        ScheduleDescription: Text;
        //
        PostingDateRunNo: Integer;
        Txt000: Label 'Compressing Item Ledger Entries\Period: #1#####\Processing Item: #2#####\Step: #3#################\Counter: #4#################';
        gItem: Record Item;

    trigger OnRun()
    begin
        gItem := Rec;
        GetParams();
        ILECompressionSingleInst.GetILECompressionTask(ILECompressionTask);
        if ILECompressionTask = 'CompressAdditionalRecs' then
            CompressAdditionalRecs()
        else
            RunCompression(Rec);
    end;

    var
        Window: Dialog;
        LogLineNo: Integer;
        StartingILENumber: Integer;
        StartingVENumber: Integer;
        ILE: Record "Item Ledger Entry";
        VE: Record "Value Entry";
        RptDeleteILEandVLE: Report "AQDLC Delete ILE and VLE";
        //RptCreateMissingILEs: Report "AQDLC Create Missing ILEs";
        RptCrateILEEntriesUsingQoH: Report "AQDLC Create ILE Entrs frm QoH";
        RptDeleteOrphanItemApplEntry: Report "AQDLC Dlt Orphn Itm Apl Entry";
        RptCompressAdditionalTablesRec: Report "AQDLC Compress Add. Tables Rec";
        RptCreateItemApplication: Report "AQDLC Create Item Application";
        RptPostCompressionInvtValuation: Report "AQDLC Post-Compress Invt. Val";
        GenerateQoHRpt: Report "AQDLC Generate Qty On Hand";
        QoH: Record "AQDLC Qty on Hand";
        ItemApplicationEntry: Record "Item Application Entry";
        ItemValuationComparison: Record "AQDLC Item Valuation Comparisn";
        Counter: Integer;
        NoOfDeletedRecords: Integer;
        NoOfCreatedRecords: Integer;

    local procedure RunCompression(vItem: Record Item)
    var
        ErrorMsg: Text;
        ItemRec: Record Item;
    begin
        OpenWindow();
        UpdateWindow(2, vItem."No." + ' - ' + vItem.Description);
        UpdateWindow(3, 'Checking Cost Adjustments (1/7)');
        LogLineNo := 0;
        ClearRecordsCount();
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Check Cost Adjustment', '', 0, 0, 0, 0, 0);
        if not CheckItemCostAdjustment(vItem, ErrorMsg) then begin
            UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Check Cost Adjustment', ErrorMsg, 1, 0, 0, 0, 0);
            Error(ErrorMsg);
            exit;
        end else
            UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Check Cost Adjustment', '', 2, 0, 0, 0, 0);

        StartingILENumber := 0;
        StartingVENumber := 0;
        ILE.SetCurrentKey("Entry No.");
        ILE.SetRange("Item No.", vItem."No.");
        ILE.SetFilter("Posting Date", '<=%1', EndingDate);
        if ILE.FindFirst() then
            StartingILENumber := ILE."Entry No.";

        VE.SetCurrentKey("Entry No.");
        VE.SetRange("Item No.", vItem."No.");
        VE.SetFilter("Posting Date", '<=%1', EndingDate);
        if VE.FindFirst() then
            StartingVENumber := VE."Entry No.";

        UpdateWindow(3, 'Generating Quantity on Hand (2/7)');
        LogLineNo := 0;
        NoOfDeletedRecords := 0;
        NoOfCreatedRecords := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Generate Quantity on Hand', '', 0, 0, 0, 0, 0);
        GenerateQtyOnHand(vItem);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Generate Quantity on Hand', '', 2, 0, 0, 0, 0);

        UpdateWindow(3, 'Deleting Item Ledger, Value Entries and Related Records (3/7)');
        LogLineNo := 0;
        NoOfDeletedRecords := 0;
        NoOfCreatedRecords := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Delete Item Ledger, Value Entries and Related Records', '', 0, 0, 0, 0, 0);
        DeleteCompressedEntries(vItem);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Delete Item Ledger, Value Entries and Related Records', '', 2, DeletedILEs, DeletedVEs, 0, 0);

        /*UpdateWindow(3, 'Delete Orphan Item Application Entries (4/7)');
        LogLineNo := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Delete Orphan Item Application Entries', '', 0, 0, 0, 0, 0);
        Clear(RptDeleteOrphanItemApplEntry);
        ItemApplicationEntry.SetRange("Item No.", vItem."No.");
        ItemApplicationEntry.SetFilter("Posting Date", '<=%1', EndingDate);
        RptDeleteOrphanItemApplEntry.SetTableView(ItemApplicationEntry);
        RptDeleteOrphanItemApplEntry.SetRunParameters(EndingDate, RegNo, GuiAllowed);
        RptDeleteOrphanItemApplEntry.UseRequestPage := false;
        RptDeleteOrphanItemApplEntry.RunModal();
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Delete Orphan Item Application Entries', '', 2, 0, 0, 0, 0);*/

        UpdateWindow(3, 'Create Item Ledger Entries using Quantity on Hand (4/7)');
        LogLineNo := 0;
        NoOfDeletedRecords := 0;
        NoOfCreatedRecords := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Create Item Ledger Entries using Quantity on Hand', '', 0, 0, 0, 0, 0);
        CreateILEEntriesUsingQoH(vItem);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Create Item Ledger Entries using Quantity on Hand', '', 2, 0, 0, CreatedILEs, CreatedVEs);
        NoOfCreatedRecords := 0;

        UpdateWindow(3, 'Create Item Application Entries (5/7)');
        LogLineNo := 0;
        NoOfDeletedRecords := 0;
        NoOfCreatedRecords := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Create Item Application Entries', '', 0, 0, 0, 0, 0);
        CreateItemApplications(vItem);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Create Item Application Entries', '', 2, 0, 0, 0, 0);

        UpdateWindow(3, 'Running Post-Compression Inventory Valuation (6/7)');
        LogLineNo := 0;
        NoOfDeletedRecords := 0;
        NoOfCreatedRecords := 0;
        UpdateCompressionLogEntry(0, LogLineNo, vItem."No.", 'Run Post-Compression Inventory Valuation', '', 0, 0, 0, 0, 0);
        PostCompressionInvtValuation(vItem);
        UpdateCompressionLogEntry(1, LogLineNo, vItem."No.", 'Run Post-Compression Inventory Valuation', '', 2, 0, 0, 0, 0);

        vItem."Cost is Adjusted" := false;
        if CompressionScheduleNo <> 0 then begin
            vItem."AQDLC Last Compression No." := CompressionScheduleNo;
            vItem."AQDLC Last Compression Date" := EndingDate;
            MarkScheduleAsProcessed();
        end;
        vItem.Modify();
        Commit();
        CloseWindow();
    end;

    var
        AvgCostAdjustmentEntryPoints: Record "Avg. Cost Adjmt. Entry Point";
        PostValueEntryToGl: Record "Post Value Entry to G/L";
        StartingDate: Date;

    local procedure CheckItemCostAdjustment(vItem: Record Item; var vErrorMsg: Text): Boolean
    begin
        StartingDate := 0D;
        AvgCostAdjustmentEntryPoints.SetRange("Item No.", vItem."No.");
        AvgCostAdjustmentEntryPoints.SetRange("Valuation Date", StartingDate, EndingDate);
        AvgCostAdjustmentEntryPoints.SetRange("Cost Is Adjusted", false);
        if AvgCostAdjustmentEntryPoints.Find('-') then begin
            vErrorMsg := StrSubstNo('Please run cost adjustment for item %1', vItem."No.");
            exit(false);
        end;

        PostValueEntryToGl.SetRange("Item No.", vItem."No.");
        PostValueEntryToGl.SetRange("Posting Date", StartingDate, EndingDate);
        PostValueEntryToGl.SetRange("AQDLC Skipped", false);
        if PostValueEntryToGl.Find('-') then begin
            vErrorMsg := StrSubstNo('Please run "Post Inventory Costs to G/L" for item %1 to and including date %2', vItem."No.", EndingDate);
            exit(false);
        end;
        exit(true);
    end;

    local procedure GenerateQtyOnHand(vItem: Record Item)
    var
        lvILE: Record "Item Ledger Entry";
        lvVE: Record "Value Entry";
        ILEMod: Record "Item Ledger Entry";
        InvtValue: Decimal;
        SkipCompressing: Boolean;
        LastQoHEntryNo: Integer;
    begin
        SkipCompressing := false;
        Counter := 0;

        if QoH.FindLast() then
            LastQoHEntryNo := QoH."Entry No." + 1
        else
            LastQoHEntryNo := 1;

        UpdateWindow(4, Format(Counter));

        ILEMod.SetCurrentKey("Item No.", "Posting Date");
        ILEMod.SetRange("Item No.", vItem."No.");
        ILEMod.SetFilter("Posting Date", '<=%1', EndingDate);
        ILEMod.SetRange("AQDLC Skip Compressing", true);
        ILEMod.ModifyAll("AQDLC Skip Compressing", false);

        QoH.Reset();
        QoH.SetRange("Item No.", vItem."No.");
        QoH.SetRange("Register No.", RegNo);
        QoH.DeleteAll();

        lvILE.SetCurrentKey("Item No.", "Posting Date");
        lvILE.SetRange("Item No.", vItem."No.");
        lvILE.SetFilter("Posting Date", '<=%1', EndingDate);
        if lvILE.FindSet() then
            repeat
                Counter += 1;

                lvILE.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                InvtValue := lvILE."Cost Amount (Actual)";
                if lvILE."Cost Amount (Actual)" = 0 then
                    InvtValue := lvILE."Cost Amount (Expected)";
                GetItemValuationBefore(vItem, lvILE.Quantity, InvtValue, false);

                if not lvILE."Completely Invoiced" then SkipCompressing := true;

                if not SkipCompressing then begin
                    if (lvILE."Entry Type" = lvILE."Entry Type"::Transfer) and (lvILE."Document Type" = lvILE."Document Type"::"Transfer Shipment") then
                        if not TransferCompletelyReceived(lvILE) then
                            SkipCompressing := true;
                end;

                if not SkipCompressing then begin
                    if (lvILE.Quantity = 0) and (InvtValue <> 0) then begin
                        lvILE."AQDLC Skip Compressing" := true;
                        lvILE.Modify();
                        SkipCompressing := true;
                    end;
                end;

                if not SkipCompressing then begin
                    QoH.Reset();
                    QoH.SetCurrentKey("Item No.", "Register No.", "Location Code", "Variant Code");
                    QoH.SetRange("Item No.", lvILE."Item No.");
                    QoH.SetRange("Register No.", RegNo);
                    if ILECompressionSetup."Group by Location Code" then
                        QoH.SetRange("Location Code", lvILE."Location Code");
                    if ILECompressionSetup."Group by Variant Code" then
                        QoH.SetRange("Variant Code", lvILE."Variant Code");
                    if ILECompressionSetup."Group by Lot No." then
                        QoH.SetRange("Lot No.", lvILE."Lot No.");
                    if ILECompressionSetup."Group by Serial No." then
                        QoH.SetRange("Serial No.", lvILE."Serial No.");
                    if ILECompressionSetup."Group by Package No." then
                        QoH.SetRange("Package No.", lvILE."Package No.");

                    if QoH.Find('-') then begin
                        QoH."Qty On Hand" += lvILE.Quantity;

                        if lvILE."Entry Type" in [lvILE."Entry Type"::Purchase, lvILE."Entry Type"::"Positive Adjmt."] then begin
                            lvILE.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                            if lvILE."Cost Amount (Actual)" <> 0 then
                                QoH."Last Puchase/ +Ve Unit Cost" := lvILE."Cost Amount (Actual)" / lvILE."Invoiced Quantity"
                            else
                                QoH."Last Puchase/ +Ve Unit Cost" := lvILE."Cost Amount (Expected)" / lvILE.Quantity;
                        end;

                        UpdateInventoryValueAndUnitCost(QoH, lvILE);
                        QoH.Modify();
                    end else begin
                        QoH.Init();
                        QoH."Entry No." := LastQoHEntryNo;
                        QoH."Register No." := RegNo;
                        QoH."Item No." := lvILE."Item No.";
                        if ILECompressionSetup."Group by Location Code" then
                            QoH."Location Code" := lvILE."Location Code";
                        if ILECompressionSetup."Group by Variant Code" then
                            QoH."Variant Code" := lvILE."Variant Code";
                        if ILECompressionSetup."Group by Lot No." then
                            QoH."Lot No." := lvILE."Lot No.";
                        if ILECompressionSetup."Group by Serial No." then
                            QoH."Serial No." := lvILE."Serial No.";
                        if ILECompressionSetup."Group by Package No." then
                            QoH."Package No." := lvILE."Package No.";
                        QoH."Qty On Hand" := lvILE.Quantity;

                        if lvILE."Entry Type" in [lvILE."Entry Type"::Purchase, lvILE."Entry Type"::"Positive Adjmt."] then begin
                            lvILE.CalcFields("Cost Amount (Expected)", lvILE."Cost Amount (Actual)");
                            if lvILE."Cost Amount (Actual)" <> 0 then
                                QoH."Last Puchase/ +Ve Unit Cost" := lvILE."Cost Amount (Actual)" / lvILE."Invoiced Quantity"
                            else
                                QoH."Last Puchase/ +Ve Unit Cost" := lvILE."Cost Amount (Expected)" / lvILE.Quantity;
                        end;
                        UpdateInventoryValueAndUnitCost(QoH, lvILE);
                        QoH."Posting Date" := EndingDate;
                        QoH.Insert();
                        LastQoHEntryNo += 1;
                    end;

                    if ((Counter MOD 1000) = 0) or (Counter = 1) then
                        UpdateWindow(4, Format(Counter));
                end;
            until lvILE.Next() = 0;

        GetItemValuationBefore(vItem, 0, 0, true);
        QoH.Reset();
        QoH.SetRange("Item No.", vItem."No.");
        QoH.SetRange("Qty On Hand", 0);
        QoH.DeleteAll();
    end;

    var
        ItemQtyOnHandBefore: Decimal;
        ItemUnitCostBefore: Decimal;
        ItemInventoryValueBefore: Decimal;
        CurrItemNo: Code[20];
        CurrItemDesc: Text;

    local procedure GetItemValuationBefore(vItem: Record Item; vQty: Decimal; vInvtVal: Decimal; FinalCall: Boolean)
    var
        vILE: Record "Item Ledger Entry";
        ItemValuationComparison: Record "AQDLC Item Valuation Comparisn";
    begin
        if CurrItemNo = '' then begin
            CurrItemNo := vItem."No.";
            CurrItemDesc := vItem.Description;

            ItemQtyOnHandBefore := 0;
            ItemUnitCostBefore := 0;
            ItemInventoryValueBefore := 0;
        end;

        if (CurrItemNo = vItem."No.") and (not FinalCall) then begin
            ItemQtyOnHandBefore += vQty;
            ItemUnitCostBefore := 0;
            ItemInventoryValueBefore += vInvtVal;
            exit;
        end;
        if ItemQtyOnHandBefore <> 0 then
            ItemUnitCostBefore := ItemInventoryValueBefore / ItemQtyOnHandBefore;

        if not ItemValuationComparison.Get(RegNo, CurrItemNo) then begin
            ItemValuationComparison.Init();
            ItemValuationComparison."Register No." := RegNo;
            ItemValuationComparison."Item No." := CurrItemNo;
            ItemValuationComparison."Item Description" := CurrItemDesc;
            ItemValuationComparison."Cut-off Date" := EndingDate;
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
        ItemQtyOnHandBefore := vQty;
        ItemUnitCostBefore := 0;
        ItemInventoryValueBefore := vInvtVal;

        if FinalCall then
            currItemNo := '';
    end;

    local procedure TransferCompletelyReceived(var vILE: Record "Item Ledger Entry"): Boolean
    var
        TransferLine: Record "Transfer Line";
    begin
        if (vILE."Order No." = '') or (vILE."Order Line No." = 0) then exit(true);

        if not TransferLine.Get(vILE."Order No.", vILE."Order Line No.") then
            exit(true)
        else
            exit(TransferLine."Completely Received");
    end;

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



    local procedure DeleteCompressedEntries(var vItem: Record Item)
    var
        lvILE: Record "Item Ledger Entry";
        SkipDeletion: Boolean;
        ValueEntry: Record "Value Entry";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        TrackingSpecification: Record "Tracking Specification";
        ItemApplnEntry: Record "Item Application Entry";
    begin
        Counter := 0;
        lvILE.SetCurrentKey("Item No.", "Posting Date");
        lvILE.SetRange("Item No.", vItem."No.");
        lvILE.SetFilter("Posting Date", '<=%1', EndingDate);
        lvILE.SetRange("Completely Invoiced", true);
        lvILE.SetRange("AQDLC Skip Compressing", false);
        if lvILE.FindSet() then
            repeat
                SkipDeletion := false;
                if lvILE."Document No." in ['QOH-' + Format(EndingDate) + '-' + Format(PostingDateRunNo), 'MILE-' + Format(EndingDate) + '-' + Format(PostingDateRunNo)] then
                    SkipDeletion := true;
                if not SkipDeletion then begin
                    if (lvILE."Entry Type" = lvILE."Entry Type"::Transfer) and (lvILE."Document Type" = lvILE."Document Type"::"Transfer Shipment") then
                        if not TransferCompletelyReceived(lvILE) then
                            SkipDeletion := true;
                end;

                if not SkipDeletion then begin
                    ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Valuation Date", "Posting Date");
                    ValueEntry.SetRange("Item Ledger Entry No.", lvILE."Entry No.");
                    if ValueEntry.FindSet() then
                        repeat
                            GLItemLedgerRelation.SetRange("Value Entry No.", ValueEntry."Entry No.");
                            if not GLItemLedgerRelation.IsEmpty then begin
                                NoOfDeletedRecords += 1; //GLItemLedgerRelation.Count;
                                GLItemLedgerRelation.DeleteAll();
                            end;

                            ValueEntry.Delete();
                            DeletedVEs += 1;
                            NoOfDeletedRecords += 1;
                        until ValueEntry.Next() = 0;

                    TrackingSpecification.SetRange("Item Ledger Entry No.", lvILE."Entry No.");
                    if not TrackingSpecification.IsEmpty then begin
                        NoOfDeletedRecords += 1; //TrackingSpecification.Count;
                        TrackingSpecification.DeleteAll();
                    end;

                    ItemApplnEntry.SetRange("Item Ledger Entry No.", lvILE."Entry No.");
                    if not ItemApplnEntry.IsEmpty then begin
                        NoOfDeletedRecords += 1; //ItemApplnEntry.Count;
                        ItemApplnEntry.DeleteAll();
                    end;

                    ItemApplnEntry.Reset();
                    ItemApplnEntry.SetRange("Inbound Item Entry No.", lvILE."Entry No.");
                    if not ItemApplnEntry.IsEmpty then begin
                        NoOfDeletedRecords += 1; //ItemApplnEntry.Count;
                        ItemApplnEntry.DeleteAll();
                    end;

                    ItemApplnEntry.Reset();
                    ItemApplnEntry.SetRange("Outbound Item Entry No.", lvILE."Entry No.");
                    if not ItemApplnEntry.IsEmpty then begin
                        NoOfDeletedRecords += 1; //ItemApplnEntry.Count;
                        ItemApplnEntry.DeleteAll();
                    end;

                    lvILE.Delete();

                    DeletedILEs += 1;
                    NoOfDeletedRecords += 1;

                    Counter += 1;
                    if ((Counter MOD 1000) = 0) or (Counter = 1) then
                        UpdateWindow(4, Format(Counter));
                end;
            until lvILE.Next() = 0;

        /*WhseEntry.SetRange("Item No.", "No.");
                WhseEntry.SetFilter("Registering Date", '<=%1', MaxPostingDate);
                WhseEntry.DeleteAll();*/
    end;

    var
        ILEEntryNo: Integer;
        VEEntryNo: Integer;

    local procedure CreateILEEntriesUsingQoH(var vItem: Record Item)
    var
        SkipCreating: Boolean;
    begin
        Counter := 0;
        SkipCreating := false;
        ILEEntryNo := StartingILENumber;
        VEEntryNo := StartingVENumber;
        NoOfCreatedRecords := 0;
        EnsureAvailableILEEntryNo(ILEEntryNo);
        EnsureAvailableVEEntryNo(VEEntryNo);

        QoH.Reset();
        QoH.SetCurrentKey("Item No.", "Register No.", "Posting Date");
        QoH.SetRange("Item No.", vItem."No.");
        QoH.SetRange("Posting Date", EndingDate);
        QoH.SetRange("Register No.", RegNo);
        if QoH.FindSet() then
            repeat
                QoH."Net Qty On Hand" := QoH."Qty On Hand" + QoH."Applied Quanty";
                if QoH."Net Qty On Hand" = 0 then
                    SkipCreating := true;

                if not SkipCreating then begin
                    CreateILE(QoH);
                    CreateVE(QoH);
                    NoOfCreatedRecords += 2;

                    ILEEntryNo += 1;
                    EnsureAvailableILEEntryNo(ILEEntryNo);
                    VEEntryNo += 1;
                    EnsureAvailableVEEntryNo(VEEntryNo);

                    Counter += 1;
                    if ((Counter MOD 1000) = 0) or (Counter = 1) then
                        UpdateWindow(4, Format(Counter));
                end;
            until QoH.Next() = 0;
    end;

    local procedure CreateILE(var vQoH: Record "AQDLC Qty on Hand")
    var
        ILEinit: Record "Item Ledger Entry";
    begin
        //INIT; // left out for performance reasons as in original
        ILEinit."Entry No." := ILEEntryNo;
        ILEinit."AQDLC Comp. Reg No." := vQoH."Register No.";
        ILEinit."AQDLC QoH Entry No." := vQoH."Entry No.";
        ILEinit."AQDLC Posting Date Run No." := PostingDateRunNo;
        ILEinit."Item No." := vQoH."Item No.";
        ILEinit."Posting Date" := EndingDate;
        if vQoH."Net Qty On Hand" < 0 then
            ILEinit."Entry Type" := ILEinit."Entry Type"::"Negative Adjmt."
        else
            ILEinit."Entry Type" := ILEinit."Entry Type"::"Positive Adjmt.";

        ILEinit."Document Type" := ILEinit."Document Type"::" ";
        ILEinit."Document No." := 'QoH-' + Format(EndingDate) + '-' + Format(PostingDateRunNo);
        ILEinit."Location Code" := vQoH."Location Code";
        ILEinit."Variant Code" := vQoH."Variant Code";
        ILEinit."Lot No." := vQoH."Lot No.";
        ILEinit."Serial No." := vQoH."Serial No.";
        ILEinit."Package No." := vQoH."Package No.";
        ILEinit.Quantity := vQoH."Net Qty On Hand";
        ILEinit."Remaining Quantity" := vQoH."Net Qty On Hand";
        ILEinit."Invoiced Quantity" := vQoH."Net Qty On Hand";
        ILEinit.Open := FALSE;
        ILEinit.Positive := vQoH."Net Qty On Hand" > 0;
        ILEinit."Document Date" := EndingDate;
        ILEinit."Qty. per Unit of Measure" := 1;
        ILEinit."Unit of Measure Code" := gItem."Base Unit of Measure";
        //"Product Group Code" := Item."Product Group Code";
        ILEinit."Completely Invoiced" := TRUE;
        ILEinit."Last Invoice Date" := EndingDate;
        ILEinit.Open := TRUE;
        ILEinit.Description := ScheduleDescription;

        ILEinit.Insert();
        CreatedILEs += 1;
    end;

    local procedure CreateVE(var vQoH: Record "AQDLC Qty on Hand")
    var
        VEinit: Record "Value Entry";
    begin
        //INIT;
        VEinit."Entry No." := VEEntryNo;
        VEinit."AQDLC Comp. Reg No" := vQoH."Register No.";
        VEinit."AQDLC QoH Entry No." := vQoH."Entry No.";
        VEinit."AQDLC Posting Date Run No." := PostingDateRunNo;
        VEinit."Item No." := vQoH."Item No.";
        VEinit."Posting Date" := EndingDate;
        if vQoH."Net Qty On Hand" < 0 then
            VEinit."Item Ledger Entry Type" := VEinit."Item Ledger Entry Type"::"Negative Adjmt."
        else
            VEinit."Item Ledger Entry Type" := VEinit."Item Ledger Entry Type"::"Positive Adjmt.";

        VEinit."Document No." := 'QoH-' + Format(EndingDate) + '-' + Format(PostingDateRunNo);
        VEinit."Location Code" := vQoH."Location Code";
        VEinit."Variant Code" := vQoH."Variant Code";
        VEinit."Inventory Posting Group" := gItem."Inventory Posting Group";
        VEinit."Item Ledger Entry No." := ILEEntryNo;
        VEinit."Valued Quantity" := vQoH."Net Qty On Hand";
        VEinit."Item Ledger Entry Quantity" := vQoH."Net Qty On Hand";
        VEinit."Invoiced Quantity" := vQoH."Net Qty On Hand";

        if vQoH."Unit Cost" <> 0 then //"Last Puchase/ +Ve Unit Cost"
            VEinit."Cost per Unit" := vQoH."Unit Cost" //"Last Puchase/ +Ve Unit Cost"
        else
            VEinit."Cost per Unit" := gItem."Unit Cost";

        VEinit."User ID" := 'DPFE';
        VEinit."Source Code" := 'ITEMJNL';

        VEinit."Cost Amount (Actual)" := VEinit."Cost per Unit" * vQoH."Net Qty On Hand";
        VEinit."Cost Posted to G/L" := VEinit."Cost per Unit" * vQoH."Net Qty On Hand";
        VEinit."Journal Batch Name" := 'DPFE';
        VEinit."Gen. Prod. Posting Group" := gItem."Gen. Prod. Posting Group";
        VEinit."Document Date" := EndingDate;
        VEinit.Inventoriable := TRUE;
        VEinit."Valuation Date" := EndingDate;
        VEinit."Entry Type" := VEinit."Entry Type"::"Direct Cost";
        VEinit.Description := ScheduleDescription;

        VEinit.Insert();
        CreatedVEs += 1;
    end;

    local procedure EnsureAvailableILEEntryNo(var vILEentryNo: Integer)
    var
        vILE: Record "Item Ledger Entry";
    begin
        while vILE.Get(vILEentryNo) do
            vILEentryNo += 1;
    end;

    local procedure EnsureAvailableVEEntryNo(var vVEentryNo: Integer)
    var
        vVE: Record "Value Entry";
    begin
        while vVE.Get(vVEentryNo) do
            vVEentryNo += 1;
    end;

    local procedure CreateItemApplications(var vItem: Record Item)
    var
        lvILE: Record "Item Ledger Entry";
        NextItemLdgrEntryNo: Integer;
        NextValueEntryNo: Integer;
        NextItemApplicationEntryNo: Integer;
        ItemApplicationUpdated: Integer;
        NewItemApplicationEntry: Record "Item Application Entry";
        ItemApplicationCreated: Integer;
    begin
        NextItemLdgrEntryNo := 1;
        NextValueEntryNo := 1;
        NextItemApplicationEntryNo := 1;
        Counter := 0;
        NoOfCreatedRecords := 0;

        ItemApplicationEntry.Reset();
        if ItemApplicationEntry.FindLast() then
            NextItemApplicationEntryNo := ItemApplicationEntry."Entry No." + 1;

        lvILE.SetCurrentKey("Item No.", "Posting Date");
        lvILE.SetRange("Item No.", vItem."No.");
        lvILE.SetFilter("Posting Date", '<=%1', EndingDate);
        lvILE.SetRange("Completely Invoiced", true);
        lvILE.SetRange("AQDLC Comp. Reg No.", RegNo);
        if lvILE.FindSet(true) then
            repeat
                Counter += 1;
                if ((Counter MOD 1000) = 0) or (Counter = 1) then
                    UpdateWindow(4, Format(Counter));
                lvILE."Document Type" := lvILE."Document Type"::" ";
                lvILE."Document Line No." := 0;
                lvILE.Positive := lvILE.Quantity > 0;
                lvILE.Modify();

                ItemApplicationEntry.Reset();
                ItemApplicationEntry.SetCurrentKey("Item Ledger Entry No.", "Output Completely Invd. Date");
                ItemApplicationEntry.SetRange("Item Ledger Entry No.", lvILE."Entry No.");
                if lvILE.Positive then begin
                    ItemApplicationEntry.SetRange("Inbound Item Entry No.", lvILE."Entry No.");
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", 0);
                    if ItemApplicationEntry.FindFirst() then begin
                        ItemApplicationEntry.Quantity := lvILE.Quantity;
                        ItemApplicationEntry.Modify();
                        ItemApplicationUpdated += 1;
                    end else begin
                        NewItemApplicationEntry.Init();
                        NewItemApplicationEntry."Entry No." := NextItemApplicationEntryNo;
                        NewItemApplicationEntry."Item Ledger Entry No." := lvILE."Entry No.";
                        NewItemApplicationEntry."Inbound Item Entry No." := lvILE."Entry No.";
                        NewItemApplicationEntry."Outbound Item Entry No." := 0;
                        NewItemApplicationEntry.Quantity := lvILE.Quantity;
                        NewItemApplicationEntry."Posting Date" := lvILE."Posting Date";
                        NewItemApplicationEntry."Transferred-from Entry No." := 0;
                        NewItemApplicationEntry."Creation Date" := CreateDateTime(lvILE."Posting Date", TIME);
                        NewItemApplicationEntry."Cost Application" := true;
                        NewItemApplicationEntry."Output Completely Invd. Date" := lvILE."Posting Date";
                        NewItemApplicationEntry.Insert();
                        NextItemApplicationEntryNo += 1;
                        ItemApplicationCreated += 1;
                        NoOfCreatedRecords += 1;
                    end;
                end else begin
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", lvILE."Entry No.");
                    if ItemApplicationEntry.FindFirst() then begin
                        ItemApplicationEntry.Quantity := lvILE.Quantity;
                        ItemApplicationEntry.Modify();
                        ItemApplicationUpdated += 1;
                    end else begin
                        NewItemApplicationEntry.Init();
                        NewItemApplicationEntry."Entry No." := NextItemApplicationEntryNo;
                        NewItemApplicationEntry."Item Ledger Entry No." := lvILE."Entry No.";
                        NewItemApplicationEntry."Inbound Item Entry No." := 0;//PositiveILE."Entry No.";
                        NewItemApplicationEntry."Outbound Item Entry No." := lvILE."Entry No.";
                        NewItemApplicationEntry.Quantity := lvILE.Quantity;
                        NewItemApplicationEntry."Posting Date" := lvILE."Posting Date";
                        NewItemApplicationEntry."Transferred-from Entry No." := 0;
                        NewItemApplicationEntry."Creation Date" := CreateDateTime(lvILE."Posting Date", TIME);
                        NewItemApplicationEntry."Cost Application" := true;
                        NewItemApplicationEntry."Output Completely Invd. Date" := lvILE."Posting Date";
                        NewItemApplicationEntry.Insert();
                        NextItemApplicationEntryNo += 1;
                        ItemApplicationCreated += 1;
                        NoOfCreatedRecords += 1;
                    end;
                end;
            until lvILE.Next() = 0;
    end;

    local procedure PostCompressionInvtValuation(var vItem: Record Item)
    var
        lvILE: Record "Item Ledger Entry";
    begin
        Counter := 0;
        ItemValuationComparison.SetCurrentKey("Item No.", "Register No.", "Cut-off Date");
        ItemValuationComparison.SetRange("Item No.", vItem."No.");
        ItemValuationComparison.SetRange("Cut-off Date", EndingDate);
        ItemValuationComparison.SetRange("Register No.", RegNo);
        if ItemValuationComparison.FindSet() then
            repeat
                lvILE.SetCurrentKey("Item No.", "Posting Date");
                lvILE.SetRange("Item No.", ItemValuationComparison."Item No.");
                lvILE.SetFilter("Posting Date", '<=%1', EndingDate);
                if lvILE.FindSet(true) then
                    repeat
                        Counter += 1;
                        if ((Counter MOD 1000) = 0) or (Counter = 1) then
                            UpdateWindow(4, Format(Counter));
                        lvILE.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
                        ItemValuationComparison."Remaining Qty After" += lvILE.Quantity;
                        if lvILE."Cost Amount (Actual)" <> 0 then
                            ItemValuationComparison."Inventory Value After" += lvILE."Cost Amount (Actual)"
                        else
                            ItemValuationComparison."Inventory Value After" += lvILE."Cost Amount (Expected)";
                    until lvILE.Next() = 0;

                if ItemValuationComparison."Remaining Qty After" <> 0 then
                    ItemValuationComparison."Unit Cost After" := ItemValuationComparison."Inventory Value After" / ItemValuationComparison."Remaining Qty After";
                ItemValuationComparison."Quantity Variance" := ItemValuationComparison."Remaining Qty After" - ItemValuationComparison."Remaining Qty Before";
                ItemValuationComparison."Valuation Variance" := ItemValuationComparison."Inventory Value After" - ItemValuationComparison."Inventory Value Before";
                ItemValuationComparison.Modify();
            until ItemValuationComparison.Next() = 0;
    end;

    var
        DeletedILEs: Integer;
        DeletedVEs: Integer;
        CreatedILEs: Integer;
        CreatedVEs: Integer;

    local procedure ClearRecordsCount()
    begin
        DeletedILEs := 0;
        DeletedVEs := 0;
        CreatedILEs := 0;
        CreatedVEs := 0;
    end;

    procedure CreateILECompressionLog(ItemFilters: Text; vEndingDate: Date; ExecutionStartDt: DateTime; vCalledFromRegisterNo: Integer; var vRegNo: Integer; vCompressionScheduleNo: Integer; var vPostingDateRunNo: Integer)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        if vCalledFromRegisterNo <> 0 then exit;

        vPostingDateRunNo := GetPostingDateRunNo();
        IleCompressionReg.Init();
        IleCompressionReg."Item Filter" := CopyStr(ItemFilters, 1, 200);
        IleCompressionReg."Executed On" := ExecutionStartDt;
        IleCompressionReg."Executed By" := UserId;
        IleCompressionReg."Start Date/Time" := CurrentDateTime;
        IleCompressionReg.Status := IleCompressionReg.Status::Incomplete;
        IleCompressionReg."Cut-off Date" := vEndingDate;
        IleCompressionReg."Cut-off Date Run No." := vPostingDateRunNo;
        IleCompressionReg."Schedule No." := vCompressionScheduleNo;
        IleCompressionReg.Insert(true);
        vRegNo := IleCompressionReg."Entry No.";
    end;

    local procedure GetPostingDateRunNo(): Integer
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        IleCompressionReg.SetCurrentKey("Cut-off Date", "Cut-off Date Run No.");
        IleCompressionReg.SetRange("Cut-off Date", EndingDate);
        IleCompressionReg.SetAscending("Cut-off Date Run No.", false);
        if IleCompressionReg.FindFirst() then
            exit(IleCompressionReg."Cut-off Date Run No." + 1);
        exit(1);
    end;

    procedure CloseILECompressionLog(vStatus: Option Incomplete,Failed,Completed; vExecutionTimeOut: Boolean; vExecutionTimeOutMsg: Text)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
    begin
        GetParams();
        if RegNo = 0 then exit;

        if IleCompressionReg.Get(RegNo) then begin
            IleCompressionReg."End Date/Time" := CurrentDateTime;
            IleCompressionReg.Status := vStatus;
            if vExecutionTimeOut then
                IleCompressionReg."Processing Summary" := vExecutionTimeOutMsg;
            IleCompressionReg.Modify();
        end;
    end;

    procedure UpdateCompressionLogEntry(vAction: Option Create,Update; var IleLogLineNo: Integer; ItemNo: Code[20]; Descr: Text; ErrorMessage: Text; vStatus: Option Pending,Failed,Successful; vDeletedILEs: Integer; vDeletedVEs: Integer; vCreatedILEs: Integer; vCreatedVEs: Integer)
    var
        IleCompressionEntry: Record "AQDLC ILE Compress Log Entry";
    begin
        if RegNo = 0 then exit;
        if (IleLogLineNo = 0) and (vAction = vAction::Update) then
            vAction := vAction::Create;

        if vAction = vAction::Create then begin
            IleCompressionEntry.Init();
            IleCompressionEntry."Log No." := RegNo;
            IleCompressionEntry."Item No." := ItemNo;
            IleCompressionEntry.Description := Descr;
            IleCompressionEntry.Status := vStatus;
            IleCompressionEntry."Start Date/Time" := CurrentDateTime;
            IleCompressionEntry."No. of ILEs Deleted" := vDeletedILEs;
            IleCompressionEntry."No. of VEs Deleted" := vDeletedVEs;
            IleCompressionEntry."No. of ILEs Created" := vCreatedILEs;
            IleCompressionEntry."No. of VEs Created" := vCreatedVEs;
            IleCompressionEntry."No. of Records Deleted" := NoOfDeletedRecords;
            IleCompressionEntry."No. of Records Created" := NoOfCreatedRecords;
            if vStatus <> vStatus::Pending then
                IleCompressionEntry."End Date/Time" := CurrentDateTime;
            IleCompressionEntry.Insert(true);
            IleLogLineNo := IleCompressionEntry."Line No.";
        end;

        if vAction = vAction::Update then begin
            IleCompressionEntry.SetRange("Log No.", RegNo);
            IleCompressionEntry.SetRange("Line No.", IleLogLineNo);
            if IleCompressionEntry.Find('-') then begin
                IleCompressionEntry."End Date/Time" := CurrentDateTime;
                IleCompressionEntry."Error Message" := CopyStr(ErrorMessage, 1, 2000);
                IleCompressionEntry.Status := vStatus;
                IleCompressionEntry."No. of ILEs Deleted" := vDeletedILEs;
                IleCompressionEntry."No. of VEs Deleted" := vDeletedVEs;
                IleCompressionEntry."No. of ILEs Created" := vCreatedILEs;
                IleCompressionEntry."No. of VEs Created" := vCreatedVEs;
                IleCompressionEntry."No. of Records Deleted" += NoOfDeletedRecords;
                IleCompressionEntry."No. of Records Created" += NoOfCreatedRecords;
                IleCompressionEntry.Modify();
            end;
        end;
    end;


    var
        CompressionScheduleNo: Integer;
        SkipCompressedItems: Boolean;

    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";

    local procedure MarkScheduleAsProcessed()
    begin
        if CompressionScheduleNo = 0 then exit;
        if CompressionSchedule.Get(CompressionScheduleNo) and (not CompressionSchedule.Processed) then begin
            CompressionSchedule.Processed := true;
            CompressionSchedule.Modify();
        end;
    end;

    local procedure CompressAdditionalRecs()
    var
        InventoryCommentLine: Record "Inventory Comment Line";
        TransferLine: Record "Transfer Line";
        TransferShptLine: Record "Transfer Shipment Line";
        TransferRcptLine: Record "Transfer Receipt Line";
        WhseRegister: Record "Warehouse Register";
        WhseEntry: Record "Warehouse Entry";
        ItemRegister: Record "Item Register";
        DeleteRecord: Boolean;
        ItemLdgrEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        PhysInvtLedgEntry: Record "Phys. Inventory Ledger Entry";
        CapLedgEntry: Record "Capacity Ledger Entry";
    begin
        GetParams();
        LogLineNo := 0;
        NoOfDeletedRecords := 0;
        Counter := 0;
        OpenWindow();
        UpdateWindow(2, '');
        UpdateWindow(3, 'Compress Additional Tables like Registers (7/7)');
        UpdateCompressionLogEntry(0, LogLineNo, '', 'Compress Additional Tables like Registers', '', 0, 0, 0, 0, 0);
        /*RptCompressAdditionalTablesRec.SetRunParameters(EndingDate, RegNo, GuiAllowed);
        RptCompressAdditionalTablesRec.UseRequestPage := false;
        RptCompressAdditionalTablesRec.RunModal();*/

        /*InventoryCommentLine.Reset();
        InventoryCommentLine.SetFilter(Date, '<=%1', EndingDate);
        if InventoryCommentLine.FindSet() then begin
            repeat
                Counter += 1;
                if ((Counter MOD 1000) = 0) or (Counter = 1) then
                    UpdateWindow(4, Format(Counter));
                case InventoryCommentLine."Document Type" of
                    InventoryCommentLine."Document Type"::"Transfer Order":
                        begin
                            if not TransferLine.Get(InventoryCommentLine."No.", InventoryCommentLine."Line No.") then begin
                                InventoryCommentLine.Delete();
                                NoOfDeletedRecords += 1;
                            end;
                        end;
                    InventoryCommentLine."Document Type"::"Posted Transfer Shipment":
                        begin
                            if not TransferShptLine.Get(InventoryCommentLine."No.", InventoryCommentLine."Line No.") then begin
                                InventoryCommentLine.Delete();
                                NoOfDeletedRecords += 1;
                            end;
                        end;
                    InventoryCommentLine."Document Type"::"Posted Transfer Receipt":
                        begin
                            if not TransferRcptLine.Get(InventoryCommentLine."No.", InventoryCommentLine."Line No.") then begin
                                InventoryCommentLine.Delete();
                                NoOfDeletedRecords += 1;
                            end;
                        end;
                end;
            until InventoryCommentLine.Next() = 0;
        end;*/

        /*WhseRegister.SetFilter("Creation Date", '<=%1', EndingDate);
        if WhseRegister.FindSet() then
            repeat
                Counter += 1;
                if ((Counter MOD 1000) = 0) or (Counter = 1) then
                    UpdateWindow(4, Format(Counter));
                WhseEntry.SetCurrentKey("Entry No.");
                WhseEntry.SetRange("Entry No.", WhseRegister."From Entry No.", WhseRegister."To Entry No.");
                WhseEntry.SetFilter("Warehouse Register No.", '%1|%2', 0, WhseRegister."No.");
                if WhseEntry.IsEmpty() then begin
                    WhseRegister.Delete();
                    NoOfDeletedRecords += 1;
                end;
            until WhseRegister.Next() = 0;*/

        ItemRegister.SetCurrentKey("Creation Date");
        ItemRegister.SetFilter("Creation Date", '<=%1', EndingDate);
        if ItemRegister.FindSet() then
            repeat
                Counter += 1;
                if ((Counter MOD 1000) = 0) or (Counter = 1) then
                    UpdateWindow(4, Format(Counter));

                DeleteRecord := true;
                /*ItemLdgrEntry.SetCurrentKey("Entry No.");
                ItemLdgrEntry.SetRange("Entry No.", ItemRegister."From Entry No.", ItemRegister."To Entry No.");
                ItemLdgrEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                ItemLdgrEntry.SetFilter("AQDLC Comp. Reg No.", '<>%1', RegNo);
                ValueEntry.SetCurrentKey("Entry No.");
                ValueEntry.SetRange("Entry No.", ItemRegister."From Entry No.", ItemRegister."To Entry No.");
                ValueEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                ValueEntry.SetFilter("AQDLC Comp. Reg No", '<>%1', RegNo);*/

                PhysInvtLedgEntry.SetCurrentKey("Entry No.");
                PhysInvtLedgEntry.SetRange("Entry No.", ItemRegister."From Phys. Inventory Entry No.", ItemRegister."To Phys. Inventory Entry No.");
                PhysInvtLedgEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                CapLedgEntry.SetCurrentKey("Entry No.");
                CapLedgEntry.SetRange("Entry No.", ItemRegister."From Capacity Entry No.", ItemRegister."To Capacity Entry No.");
                CapLedgEntry.SetFilter("Item Register No.", '0|%1', ItemRegister."No.");
                /*if not ItemLdgrEntry.IsEmpty() then
                    DeleteRecord := false
                else if not ValueEntry.IsEmpty() then
                    DeleteRecord := false*/
                if not PhysInvtLedgEntry.IsEmpty() then
                    DeleteRecord := false
                else if not CapLedgEntry.IsEmpty() then
                    DeleteRecord := false;

                if DeleteRecord then begin
                    ItemRegister.Delete();
                    NoOfDeletedRecords += 1;
                end;
            until ItemRegister.Next() = 0;

        UpdateCompressionLogEntry(1, LogLineNo, '', 'Compress Additional Tables like Registers', '', 2, 0, 0, 0, 0);
        CloseWindow();
    end;


    local procedure OpenWindow()
    begin
        if not GuiAllowed then exit;
        Window.Open(Txt000);
        Window.Update(1, '..' + Format(EndingDate));
    end;

    local procedure UpdateWindow(No: Integer; Msg: Text)
    begin
        if not GuiAllowed then exit;
        Window.Update(No, Msg);
    end;

    local procedure CloseWindow()
    begin
        if GuiAllowed then
            Window.Close();
    end;

    local procedure GetParams()
    begin
        ILECompressionSingleInst.GetILECompressionParams(EndingDate, PostingDateRunNo, RegNo, CalledFromRegisterNo, CompressionScheduleNo, ScheduleDescription);
    end;

    procedure getDuration(vStartDateTime: DateTime; vEndDateTime: DateTime): Duration
    begin
        if (vStartDateTime = 0DT) or (vEndDateTime = 0DT) then
            exit(0);
        exit(Round(vEndDateTime - vStartDateTime, 100));
    end;
}
