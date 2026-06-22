report 14305128 "AQDLC Create ILE Entrs frm QoH"
{
    Caption = 'Create ILE Entries using QoH';
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

                ILE.Reset();
                VE.Reset();
                if ProcessDate = 0D then
                    ProcessDate := DMY2DATE(5, 1, 2015); // set process date (adjust if needed)
                StartTime := CurrentDateTime;
                Counter := 0;
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

                // LED.SetRange("Table ID", 5802);
                // LED.SetRange("Entry No.", ILEEntryNo);
                // LED.DeleteAll();

                // LED.SetRange("Table ID", 32);
                // LED.SetRange("Entry No.", VEEntryNo);
                // LED.DeleteAll();

                CreateILE();
                CreateVE();

                ILEEntryNo += 1;
                EnsureAvailableILEEntryNo(ILEEntryNo);
                VEEntryNo += 1;
                EnsureAvailableVEEntryNo(VEEntryNo);

                Counter += 1;
            end;

            trigger OnPostDataItem();
            begin
                if not ShowDialog then exit;
                Window.Close();
                Message('Batch process execution is completed - 4 Create ILE Entries using QoH\Start Time: %1 End Time: %2 (%3)', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
            end;
        }
    }

    procedure SetRunParameters(vStartingILENumber: Integer; vStartingVLENumber: Integer; vMaxPostingDate: Date; vCompressionRegNo: Integer; vPostingDateRunNo: Integer; vShowDialog: Boolean)
    begin
    end;

    procedure SetRunParameters(vStartingILENumber: Integer; vStartingVLENumber: Integer; vMaxPostingDate: Date; vCompressionRegNo: Integer; vPostingDateRunNo: Integer; vCompressionScheduleNo: Integer; vScheduleDescr: Text; vShowDialog: Boolean)
    begin
        ILEEntryNo := vStartingILENumber;
        VEEntryNo := vStartingVLENumber;
        ProcessDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        PostingDateRunNo := vPostingDateRunNo;
        CompressionScheduleNo := vCompressionScheduleNo;
        ScheduleDescription := vScheduleDescr;
        ShowDialog := vShowDialog;

        //If the starting entry was a QOH, then it wasn't deleted
        EnsureAvailableILEEntryNo(ILEEntryNo);
        EnsureAvailableVEEntryNo(VEEntryNo);
    end;

    procedure GetCreatedCount(var vILECreatedCount: Integer; var vVECreatedCount: Integer)
    begin
        vILECreatedCount := ILECreatedCount;
        vVECreatedCount := VECreatedCount;
    end;

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
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        ProcessDate: Date;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
        PostingDateRunNo: Integer;
        ILECreatedCount: Integer;
        VECreatedCount: Integer;
        CompressionScheduleNo: Integer;
        ScheduleDescription: Text;

    local procedure CreateILE()
    begin
        //INIT; // left out for performance reasons as in original
        ILE."Entry No." := ILEEntryNo;
        ILE."AQDLC Comp. Reg No." := QoH."Register No.";
        ILE."AQDLC QoH Entry No." := QoH."Entry No.";
        ILE."AQDLC Posting Date Run No." := PostingDateRunNo;
        ILE."Item No." := QoH."Item No.";
        ILE."Posting Date" := ProcessDate;
        if QoH."Net Qty On Hand" < 0 then
            ILE."Entry Type" := ILE."Entry Type"::"Negative Adjmt."
        else
            ILE."Entry Type" := ILE."Entry Type"::"Positive Adjmt.";

        ILE."Document Type" := ILE."Document Type"::" ";
        ILE."Document No." := 'QoH-' + Format(ProcessDate) + '-' + Format(PostingDateRunNo);
        ILE."Location Code" := QoH."Location Code";
        ILE."Variant Code" := QoH."Variant Code";
        ILE."Lot No." := QoH."Lot No.";
        ILE."Serial No." := QoH."Serial No.";
        ILE."Package No." := QoH."Package No.";
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
        ILE.Description := ScheduleDescription;

        ILE.Insert();
        ILECreatedCount += 1;
    end;

    local procedure CreateVE()
    begin
        //INIT;
        VE."Entry No." := VEEntryNo;
        VE."AQDLC Comp. Reg No" := QoH."Register No.";
        VE."AQDLC QoH Entry No." := QoH."Entry No.";
        VE."AQDLC Posting Date Run No." := PostingDateRunNo;
        VE."Item No." := QoH."Item No.";
        VE."Posting Date" := ProcessDate;
        if QoH."Net Qty On Hand" < 0 then
            VE."Item Ledger Entry Type" := VE."Item Ledger Entry Type"::"Negative Adjmt."
        else
            VE."Item Ledger Entry Type" := VE."Item Ledger Entry Type"::"Positive Adjmt.";

        VE."Document No." := 'QoH-' + Format(ProcessDate) + '-' + Format(PostingDateRunNo);
        VE."Location Code" := QoH."Location Code";
        VE."Variant Code" := QoH."Variant Code";
        VE."Inventory Posting Group" := Item."Inventory Posting Group";
        VE."Item Ledger Entry No." := ILEEntryNo;
        VE."Valued Quantity" := QoH."Net Qty On Hand";
        VE."Item Ledger Entry Quantity" := QoH."Net Qty On Hand";
        VE."Invoiced Quantity" := QoH."Net Qty On Hand";

        if QoH."Unit Cost" <> 0 then //"Last Puchase/ +Ve Unit Cost"
            VE."Cost per Unit" := QoH."Unit Cost" //"Last Puchase/ +Ve Unit Cost"
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
        VE.Description := ScheduleDescription;

        VE.Insert();
        VECreatedCount += 1;
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
}
