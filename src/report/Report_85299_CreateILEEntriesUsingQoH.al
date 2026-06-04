report 14305128 "Create ILE Entries using QoH"
{
    Caption = 'Create ILE Entries using QoH';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD;
    dataset
    {
        dataitem(QoH; "AQD Quantity on Hand")
        {
            DataItemTableView = SORTING("Item No.");

            trigger OnPreDataItem();
            begin
                Window.Open(Text001);

                //ILE.SETRANGE("Posting Date", ProcessDate);
                //ILE.SETFILTER("Document No.", '%1', 'QOH-123114');
                if ILE.FindLast() then
                    ILEEntryNo := ILE."Entry No." + 1
                else
                    ILEEntryNo := 1000;

                //VE.SETRANGE("Posting Date", ProcessDate);
                //VE.SETFILTER("Document No.", '%1', 'QOH-123114');
                if VE.FindLast() then
                    VEEntryNo := VE."Entry No." + 1
                else
                    VEEntryNo := 1000;

                ILE.Reset();
                VE.Reset();
                ProcessDate := DMY2DATE(5, 1, 2015); // set process date (adjust if needed)
                StartTime := TIME;
                Counter := 0;
            end;

            trigger OnAfterGetRecord();
            begin
                if Counter MOD 1000 = 0 then
                    Window.Update(1, Format(Counter DIV 1000) + '->' + "Item No.");

                if not Item.Get(QoH."Item No.") then
                    CurrReport.Skip();

                QoH."Net Qty On Hand" := QoH."Qty On Hand" + QoH."Applied Quanty";
                if QoH."Net Qty On Hand" = 0 then
                    CurrReport.Skip();

                // LED.SetRange("Table ID", 5802);
                // LED.SetRange("Entry No.", ILEEntryNo);
                // LED.DeleteAll();

                // LED.SetRange("Table ID", 32);
                // LED.SetRange("Entry No.", VEEntryNo);
                // LED.DeleteAll();

                CreateILE();
                CreateVE();

                ILEEntryNo += 1;
                VEEntryNo += 1;

                Counter += 1;
            end;

            trigger OnPostDataItem();
            begin
                Window.Close();
                Message('Batch process execution is completed - 4 Create ILE Entries using QoH\Start Time: %1 End Time: %2', StartTime, TIME);
            end;
        }
    }

    var
        ILEEntryNo: Integer;
        VEEntryNo: Integer;
        ILE: Record "Item Ledger Entry";
        VE: Record 5802;
        Item: Record 27;
        LED: Record 355;
        Window: Dialog;
        Text001: Label 'Processing Item No.  ########1#####';
        Counter: Integer;
        StartTime: Time;
        ProcessDate: Date;

    local procedure CreateILE()
    begin
        //INIT; // left out for performance reasons as in original
        ILE."Entry No." := ILEEntryNo;
        ILE."Item No." := QoH."Item No.";
        ILE."Posting Date" := ProcessDate;
        if QoH."Net Qty On Hand" < 0 then
            ILE."Entry Type" := ILE."Entry Type"::"Negative Adjmt."
        else
            ILE."Entry Type" := ILE."Entry Type"::"Positive Adjmt.";

        ILE."Document Type" := ILE."Document Type"::" ";
        ILE."Document No." := 'QoH-123114';
        ILE."Location Code" := QoH."Location Code";
        ILE.Quantity := QoH."Net Qty On Hand";
        ILE."Remaining Quantity" := QoH."Net Qty On Hand";
        ILE."Invoiced Quantity" := QoH."Net Qty On Hand";
        ILE.Open := FALSE;
        ILE.Positive := QoH."Net Qty On Hand" > 0;
        ILE."Document Date" := ProcessDate;
        ILE."Qty. per Unit of Measure" := 1;
        ILE."Unit of Measure Code" := Item."Base Unit of Measure";
        //"Product Group Code" := Item."Product Group Code";
        ILE."Completely Invoiced" := TRUE;
        ILE."Last Invoice Date" := ProcessDate;
        ILE.Open := TRUE;

        ILE.Insert();
    end;

    local procedure CreateVE()
    begin
        //INIT;
        VE."Entry No." := VEEntryNo;
        VE."Item No." := QoH."Item No.";
        VE."Posting Date" := ProcessDate;
        if QoH."Net Qty On Hand" < 0 then
            VE."Item Ledger Entry Type" := VE."Item Ledger Entry Type"::"Negative Adjmt."
        else
            VE."Item Ledger Entry Type" := VE."Item Ledger Entry Type"::"Positive Adjmt.";

        VE."Document No." := 'QoH-123114';
        VE."Location Code" := QoH."Location Code";
        VE."Inventory Posting Group" := Item."Inventory Posting Group";
        VE."Item Ledger Entry No." := ILEEntryNo;
        VE."Valued Quantity" := QoH."Net Qty On Hand";
        VE."Item Ledger Entry Quantity" := QoH."Net Qty On Hand";
        VE."Invoiced Quantity" := QoH."Net Qty On Hand";

        if QoH."Last Puchase/ +Ve Unit Cost" <> 0 then
            VE."Cost per Unit" := QoH."Last Puchase/ +Ve Unit Cost"
        else
            VE."Cost per Unit" := Item."Unit Cost";

        VE."User ID" := 'DPFE';
        VE."Source Code" := 'ITEMJNL';

        VE."Cost Amount (Actual)" := VE."Cost per Unit" * QoH."Net Qty On Hand";
        VE."Cost Posted to G/L" := VE."Cost per Unit" * QoH."Net Qty On Hand";
        VE."Journal Batch Name" := 'DPFE';
        VE."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        VE."Document Date" := ProcessDate;
        VE.Inventoriable := TRUE;
        VE."Valuation Date" := ProcessDate;
        VE."Entry Type" := VE."Entry Type"::"Direct Cost";

        VE.Insert();
    end;
}
