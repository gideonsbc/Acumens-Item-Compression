report 14305132 "AQDLC Open All Items for Adj"
{
    Caption = 'Open All Items for Adjustment';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    Permissions = tabledata Item = rimd;

    dataset
    {
    }
    trigger OnPreReport();
    begin
        Item.ModifyAll("Cost is Adjusted", false);
        if not ShowDialog then exit;
        Message('All Items reset for Cost Adjustment');
    end;

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        ShowDialog := vShowDialog;
    end;

    var
        Item: Record item;
        MaxPostingDate: Date;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
}
