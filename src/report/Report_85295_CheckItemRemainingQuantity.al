report 14305124 "Check Item Remaining Quantity"
{
    Caption = 'Check Item Remaining Quantity';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Item; Item)
        {
            trigger OnPreDataItem()
            begin
                Window.Open('Processing Item No. ###########1######');
                StartTime := TIME;
                Counter := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                if (Counter MOD 1000) = 0 then
                    Window.Update(1, Format((Counter DIV 1000)) + '->' + Item."No.");

                Counter += 1;

                // Process Item Ledger Entries for this Item (inlined from nested dataitem)
                ItemLedgEntry.Reset();
                ItemLedgEntry.SetRange("Item No.", Item."No.");
                if ItemLedgEntry.Find('-') then
                    repeat
                        AppliedQuantity := 0;

                        TempItemEntry.DeleteAll();
                        FindAppliedEntry(ItemLedgEntry);
                        TempItemEntry.Reset();
                        if TempItemEntry.FindFirst() then
                            repeat
                                AppliedQuantity += TempItemEntry.Quantity;
                            until TempItemEntry.Next() = 0;

                        Clear(ItemQtyVsRemainingQty);
                        if ItemQtyVsRemainingQty.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Location Code") then begin
                            ItemQtyVsRemainingQty.Quantity += ItemLedgEntry.Quantity;
                            ItemQtyVsRemainingQty."Remaining Quantity" += ItemLedgEntry."Remaining Quantity";
                            ItemQtyVsRemainingQty."Applied Quantity" += AppliedQuantity;

                            if Abs(ItemLedgEntry.Quantity) - Abs(AppliedQuantity) <> 0 then begin
                                if STRLEN(ItemQtyVsRemainingQty.Comments) + STRLEN(FORMAT(ItemLedgEntry."Entry No.")) + 1 <= MAXSTRLEN(ItemQtyVsRemainingQty.Comments) then begin
                                    if ItemQtyVsRemainingQty.Comments <> '' then
                                        ItemQtyVsRemainingQty.Comments += ',';
                                    ItemQtyVsRemainingQty.Comments += FORMAT(ItemLedgEntry."Entry No.");
                                end;
                            end;

                            ItemQtyVsRemainingQty.Modify();
                        end else begin
                            ItemQtyVsRemainingQty.Init();
                            ItemQtyVsRemainingQty."Item No." := ItemLedgEntry."Item No.";
                            ItemQtyVsRemainingQty."Location Code" := ItemLedgEntry."Location Code";
                            ItemQtyVsRemainingQty.Quantity := ItemLedgEntry.Quantity;
                            ItemQtyVsRemainingQty."Remaining Quantity" := ItemLedgEntry."Remaining Quantity";
                            if Abs(ItemLedgEntry.Quantity) - Abs(AppliedQuantity) <> 0 then begin
                                ItemQtyVsRemainingQty."Applied Quantity" := AppliedQuantity;
                                ItemQtyVsRemainingQty.Comments += FORMAT(ItemLedgEntry."Entry No.");
                            end;
                            ItemQtyVsRemainingQty.Insert();
                        end;
                    until ItemLedgEntry.Next() = 0;
            end;

            trigger OnPostDataItem()
            begin
                ItemQtyVsRemainingQty.Reset();
                if ItemQtyVsRemainingQty.FindFirst() then
                    repeat
                        if ItemQtyVsRemainingQty.Quantity = ItemQtyVsRemainingQty."Remaining Quantity" then
                            ItemQtyVsRemainingQty.Delete();
                    until ItemQtyVsRemainingQty.Next() = 0;

                Window.Close();
                Message('Batch Process is completed - Check Item Remaining Quantity\Start Time: %1 End Time: %2', StartTime, TIME);
            end;

            // ItemLedgerEntry logic inlined into Item OnAfterGetRecord
        }
    }

    var
        ItemQtyVsRemainingQty: Record "AQD Item Quantity vs Remaining";
        TempItemEntry: Record "Item Ledger Entry" temporary;
        Window: Dialog;
        AppliedQuantity: Decimal;
        StartTime: Time;
        Counter: Integer;
        ItemLedgEntry: Record "Item Ledger Entry";

    local procedure FindAppliedEntry(ItemLedgEntry: Record "Item Ledger Entry");
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemLedgEntry.Positive then begin
            ItemApplnEntry.Reset();
            ItemApplnEntry.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Inbound Item Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
            if ItemApplnEntry.Find('-') then
                repeat
                    InsertTempEntry(ItemApplnEntry."Outbound Item Entry No.", ItemApplnEntry.Quantity);
                until ItemApplnEntry.Next() = 0;
        end else begin
            ItemApplnEntry.Reset();
            ItemApplnEntry.SetCurrentKey("Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Outbound Item Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
            if ItemApplnEntry.Find('-') then
                repeat
                    InsertTempEntry(ItemApplnEntry."Inbound Item Entry No.", -ItemApplnEntry.Quantity);
                until ItemApplnEntry.Next() = 0;
        end;
    end;

    local procedure InsertTempEntry(EntryNo: Integer; AppliedQty: Decimal);
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Get(EntryNo);
        if AppliedQty * ItemLedgEntry.Quantity < 0 then
            exit;

        if not TempItemEntry.Get(EntryNo) then begin
            TempItemEntry.Init();
            TempItemEntry := ItemLedgEntry;
            TempItemEntry.Quantity := AppliedQty;
            TempItemEntry.Insert();
        end else begin
            TempItemEntry.Quantity := TempItemEntry.Quantity + AppliedQty;
            TempItemEntry.Modify();
        end;
    end;
}
