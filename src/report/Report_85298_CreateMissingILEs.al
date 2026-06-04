report 14305127 "Create Missing ILEs"
{
    Caption = 'Create Missing ILEs';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem();
            begin
                Window.Open(Text001);
                Counter := 0;
                StartTime := TIME;
            end;

            trigger OnAfterGetRecord();
            begin
                if Counter MOD 1000 = 0 then
                    Window.Update(1, Format(Counter DIV 1000) + '->' + Item."No.");

                Counter += 1;

                QoHRec.Reset();
                QoHRec.SetRange("Item No.", Item."No.");
                QoHRec.ModifyAll("Applied Quanty", 0);

                QoH.Reset();
                QoH.SetRange("Item No.", Item."No.");
                if not QoH.Find('-') then
                    CurrReport.Skip();
            end;

            trigger OnPostDataItem();
            begin
                Window.Close();
                Message('Batch process execution is completed - 3 Create Missing ILEs\Start Time: %1 End Time: %2', StartTime, TIME);
            end;
        }

        dataitem(ILE; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Item No.", "Variant Code", "Location Code", "Posting Date");

            trigger OnAfterGetRecord();
            begin
                if "Document No." in ['QOH-123114', 'MILE-123114'] then
                    CurrReport.Skip();

                // SBC 2019-07-23 - skip if no QoH
                QoH.Reset();
                QoH.SetRange("Item No.", ILE."Item No.");
                QoH.SetRange("Location Code", ILE."Location Code");
                if QoH.IsEmpty() then
                    CurrReport.Skip();

                ItemApplicationEntry.SetRange("Item Ledger Entry No.", ILE."Entry No.");
                if ItemApplicationEntry.FindSet() then
                    repeat
                        if ILE.Positive then begin
                            if ItemApplicationEntry."Outbound Item Entry No." <> 0 then begin
                                if not AppliedILE.Get(ItemApplicationEntry."Outbound Item Entry No.") then
                                    CreateMissingILE(true)
                                else begin
                                    if AppliedILE."Posting Date" = 20141231D then
                                        ModifyILE(true);
                                end;
                            end;
                        end else begin
                            if ItemApplicationEntry."Inbound Item Entry No." <> 0 then begin
                                if not AppliedILE.Get(ItemApplicationEntry."Inbound Item Entry No.") then
                                    CreateMissingILE(false)
                                else begin
                                    if AppliedILE."Posting Date" = 20141231D then
                                        ModifyILE(false);
                                end;
                            end;
                        end;
                    until ItemApplicationEntry.Next() = 0;
            end;
        }
    }

    var
        ItemLdgrEntry: Record "Item Ledger Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        TempItemEntry: Record "Item Ledger Entry" temporary;
        ItemQtyVsRemainingQty: Record "AQD Item Quantity vs Remaining";
        AppliedILE: Record "Item Ledger Entry";
        AppliedVE: Record "Value Entry";
        QoHRec: Record "AQD Quantity on Hand";
        LED: Record 355;

        ItemR: Record Item;
        QoH: Record "AQD Quantity on Hand";
        VE: Record "Value Entry";
        Window: Dialog;
        Text001: Label 'Processing Item No.';
        Counter: Integer;
        StartTime: Time;

    local procedure CreateMissingILE(OutBound: Boolean)
    begin
        if OutBound then
            AppliedILE."Entry No." := ItemApplicationEntry."Outbound Item Entry No."
        else
            AppliedILE."Entry No." := ItemApplicationEntry."Inbound Item Entry No.";



        AppliedILE."Item No." := ILE."Item No.";
        AppliedILE."Posting Date" := 20141231D;

        if ItemApplicationEntry.Quantity < 0 then begin
            AppliedILE."Entry Type" := AppliedILE."Entry Type"::"Positive Adjmt.";
            AppliedILE.Positive := true;
        end else
            AppliedILE."Entry Type" := AppliedILE."Entry Type"::"Negative Adjmt.";

        AppliedILE."Document No." := 'MILE-123114';
        AppliedILE."Location Code" := ILE."Location Code";
        AppliedILE.Quantity := -ItemApplicationEntry.Quantity;
        AppliedILE."Remaining Quantity" := 0;
        AppliedILE."Invoiced Quantity" := -ItemApplicationEntry.Quantity;
        AppliedILE.Open := false;
        AppliedILE."Document Date" := 20141231D;
        AppliedILE."No. Series" := 'ITEM-MO';
        AppliedILE."Qty. per Unit of Measure" := 1;
        AppliedILE."Unit of Measure Code" := 'EA';
        //AppliedILE."Product Group Code" := ILE."Product Group Code";
        AppliedILE."Completely Invoiced" := true;
        AppliedILE."Last Invoice Date" := 20141231D;
        AppliedILE.Insert();

        QoHRec.Reset();
        QoHRec.SetRange("Item No.", ILE."Item No.");
        QoHRec.SetRange("Location Code", ILE."Location Code");
        if ItemApplicationEntry.Quantity < 0 then begin
            if QoHRec.FindFirst() then begin
                QoHRec."Applied Quanty" += ItemApplicationEntry.Quantity;
                QoHRec.Modify();
            end;
        end;

        CreateMissingVE();
    end;

    local procedure CreateMissingVE()
    begin
        VE.FindLast();
        VE."Entry No." := VE."Entry No." + 1;

        AppliedVE."Entry No." := VE."Entry No.";
        AppliedVE."Item No." := AppliedILE."Item No.";
        AppliedVE."Posting Date" := 20141231D;
        if AppliedILE.Quantity < 0 then
            AppliedVE."Item Ledger Entry Type" := "Item Ledger Entry Type"::"Negative Adjmt."
        else
            AppliedVE."Item Ledger Entry Type" := "Item Ledger Entry Type"::"Positive Adjmt.";

        AppliedVE."Document No." := 'MILE-123114';
        AppliedVE."Location Code" := AppliedILE."Location Code";
        AppliedVE."Inventory Posting Group" := ItemR."Inventory Posting Group";
        AppliedVE."Item Ledger Entry No." := AppliedILE."Entry No.";
        AppliedVE."Valued Quantity" := AppliedILE.Quantity;
        AppliedVE."Item Ledger Entry Quantity" := AppliedILE.Quantity;
        AppliedVE."Invoiced Quantity" := AppliedILE.Quantity;
        AppliedVE."User ID" := 'DPFE';
        AppliedVE."Source Code" := 'ITEMJNL';

        ILE.CalcFields("Cost Amount (Actual)");

        AppliedVE."Cost per Unit" := 0;
        if ILE."Invoiced Quantity" <> 0 then
            AppliedVE."Cost per Unit" := Round(ILE."Cost Amount (Actual)" / ILE."Invoiced Quantity", 0.00001);

        AppliedVE."Cost Amount (Actual)" := AppliedVE."Cost per Unit" * AppliedILE.Quantity;
        AppliedVE."Cost Posted to G/L" := AppliedVE."Cost per Unit" * AppliedILE.Quantity;
        AppliedVE."Journal Batch Name" := 'DPFE';
        AppliedVE."Gen. Prod. Posting Group" := ItemR."Gen. Prod. Posting Group";
        AppliedVE."Document Date" := 20141231D;
        AppliedVE.Inventoriable := true;
        AppliedVE."Valuation Date" := 20141231D;
        AppliedVE."Entry Type" := AppliedVE."Entry Type"::"Direct Cost";
        AppliedVE.Insert();
    end;

    local procedure ModifyILE(Outbound: Boolean)
    begin
        AppliedILE.Quantity += -ItemApplicationEntry.Quantity;
        AppliedILE."Remaining Quantity" := 0;
        AppliedILE."Invoiced Quantity" += -ItemApplicationEntry.Quantity;
        AppliedILE.Open := false;
        AppliedILE.Modify();

        QoHRec.SetRange("Item No.", AppliedILE."Item No.");
        QoHRec.SetRange("Location Code", AppliedILE."Location Code");
        if ItemApplicationEntry.Quantity < 0 then begin
            if QoHRec.FindFirst() then begin
                QoHRec."Applied Quanty" += ItemApplicationEntry.Quantity;
                QoHRec.Modify();
            end;
        end;

        ModifyVE();
    end;

    local procedure ModifyVE()
    begin
        AppliedVE.SetRange("Item Ledger Entry No.", AppliedILE."Entry No.");
        AppliedVE.FindFirst();
        AppliedVE."Valued Quantity" := AppliedILE.Quantity;
        AppliedVE."Item Ledger Entry Quantity" := AppliedILE.Quantity;
        AppliedVE."Invoiced Quantity" := AppliedILE.Quantity;
        ILE.CalcFields("Cost Amount (Actual)");

        if ILE."Invoiced Quantity" <> 0 then
            AppliedVE."Cost per Unit" := Round(ILE."Cost Amount (Actual)" / ILE."Invoiced Quantity", 0.00001);

        AppliedVE."Cost Amount (Actual)" += AppliedVE."Cost per Unit" * -ItemApplicationEntry.Quantity;
        AppliedVE."Cost Posted to G/L" += AppliedVE."Cost per Unit" * -ItemApplicationEntry.Quantity;
        AppliedVE."Journal Batch Name" := 'DPFE';
        AppliedVE.Modify();
    end;
}
