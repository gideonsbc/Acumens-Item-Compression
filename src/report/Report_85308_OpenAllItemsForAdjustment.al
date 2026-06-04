report 14305132 "Open All Items for Adjustment"
{
    Caption = 'Open All Items for Adjustment';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
    }
    trigger OnPreReport();
    begin
        Item.ModifyAll("Cost is Adjusted", false);
        Message('All Items reset for Cost Adjustment');
    end;

    var
        Item: Record item;
}
