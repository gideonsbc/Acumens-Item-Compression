report 14305126 "Delete ILE and VLE"
{
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD;
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
                DataItemTableView = SORTING("Item No.", "Posting Date");
                DataItemLink = "Item No." = FIELD("No.");

                trigger OnAfterGetRecord();
                begin
                    if "Document No." in ['QOH-123114', 'MILE-123114'] then
                        CurrReport.Skip();

                    ValueEntry.Reset();
                    ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                    ValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                    ValueEntry.SetFilter("Posting Date", '<%1', MaxPostingDate);
                    VLEDeleteCount += ValueEntry.Count();
                    ValueEntry.DeleteAll();

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
                MaxPostingDate := DMY2DATE(1, 1, 2025);

                Window.Open(Text001);
                Counter := 0;
                StartTime := TIME;
            end;

            trigger OnAfterGetRecord();
            begin
                if Counter MOD 1000 = 0 then
                    Window.Update(1, Format(Counter DIV 1000) + '->' + Item."No.");
                Counter += 1;
            end;

            trigger OnPostDataItem();
            begin
                Window.Close();
                Message('Batch process execution is completed - 2 Delete ILE and VLE\Start Time: %1 End Time: %2' +
                  '\\Deleted ILE Count %3\\VLE Count %4', StartTime, TIME, ILEDeleteCount, VLEDeleteCount);
            end;
        }
    }
    trigger OnPreReport();
    begin
        if not Confirm(Text002 + Item.GetFilters() + '\' + "ItemLedgerEntry".GetFilters()) then begin
            Error('Report is aborted');
            CurrReport.Break();
        end;
    end;

    var
        Text001: Label 'Processing Item No.  ########1#####';
        ValueEntry: Record "Value Entry";
        Window: Dialog;
        MaxPostingDate: Date;
        Text002: Label 'Do you want to run batch process for below filters?\';
        ILEDeleteCount: Integer;
        VLEDeleteCount: Integer;
        Text003: Label 'Deleted ILE Count %1\VLE Count %2';
        Counter: Integer;
        StartTime: Time;
}
