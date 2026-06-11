report 14305126 "AQDLC Delete ILE and VLE"
{
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD,
    tabledata "Item Register" = rimd;
    Caption = 'Delete ILE and VLE';
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
                DataItemTableView = SORTING("Item No.", "Posting Date") where("Completely Invoiced" = filter(true));
                DataItemLink = "Item No." = FIELD("No.");

                trigger OnPreDataItem()
                begin
                    SetFilter("Posting Date", '<=%1', MaxPostingDate);
                end;

                trigger OnAfterGetRecord();
                begin
                    if "Document No." in ['QOH-' + Format(MaxPostingDate) + '-' + Format(PostingDateRunNo), 'MILE-' + Format(MaxPostingDate) + '-' + Format(PostingDateRunNo)] then
                        CurrReport.Skip();
                    if ("Entry Type" = "Entry Type"::Transfer) and ("Document Type" = "Document Type"::"Transfer Shipment") then
                        if not RptGenerateQtyOnHand.TransferCompletelyReceived(ItemLedgerEntry) then
                            CurrReport.Skip();

                    ValueEntry.Reset();
                    ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                    ValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                    ValueEntry.SetFilter("Posting Date", '<=%1', MaxPostingDate);
                    VEDeleteCount += ValueEntry.Count();
                    ValueEntry.DeleteAll();

                    if "Item Register No." <> 0 then begin
                        ItemRegister.SetRange("No.", "Item Register No.");
                        ItemRegister.DeleteAll();
                    end;

                    Delete();
                    ILEDeleteCount += 1;
                end;

                trigger OnPostDataItem();
                begin
                    // ValueEntry.Reset();
                    // ValueEntry.SetRange("Item No.", Item."No.");
                    // ValueEntry.SetRange(Quantity, 0);
                    // ValueEntry.DeleteAll();
                end;
            }
            trigger OnPreDataItem();
            begin
                if MaxPostingDate = 0D then
                    MaxPostingDate := DMY2DATE(1, 1, 2025);

                if ShowDialog then
                    Window.Open(Text001);
                Counter := 0;
                StartTime := TIME;
            end;

            trigger OnAfterGetRecord();
            begin
                if ShowDialog then begin
                    if Counter MOD 1000 = 0 then
                        Window.Update(1, Format(Counter DIV 1000) + '->' + Item."No.");
                end;
                Counter += 1;
            end;

            trigger OnPostDataItem();
            begin
                if not ShowDialog then exit;
                Window.Close();
                Message('Batch process execution is completed - 2 Delete ILE and VLE\Start Time: %1 End Time: %2' +
                  '\\Deleted ILE Count %3\\VLE Count %4', StartTime, TIME, ILEDeleteCount, VEDeleteCount);
            end;
        }
    }
    trigger OnPreReport();
    begin
        if not ShowDialog then exit;
        if not Confirm(Text002 + Item.GetFilters() + '\' + "ItemLedgerEntry".GetFilters()) then begin
            Error('Report is aborted');
            CurrReport.Break();
        end;
    end;

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vPostingDateRunNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        PostingDateRunNo := vPostingDateRunNo;
        ShowDialog := vShowDialog;
    end;

    procedure GetDeleteCount(var vILEDeleteCount: Integer; var vVEDeleteCount: Integer)
    begin
        vILEDeleteCount := ILEDeleteCount;
        vVEDeleteCount := VEDeleteCount;
    end;

    var
        Text001: Label 'Processing Item No.  ########1#####';
        ValueEntry: Record "Value Entry";
        Window: Dialog;
        MaxPostingDate: Date;
        Text002: Label 'Do you want to run batch process for below filters?\';
        ILEDeleteCount: Integer;
        VEDeleteCount: Integer;
        Text003: Label 'Deleted ILE Count %1\VLE Count %2';
        Counter: Integer;
        StartTime: Time;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
        PostingDateRunNo: Integer;
        ItemRegister: Record "Item Register";
        RptGenerateQtyOnHand: Report "AQDLC Generate Qty On Hand";
}
