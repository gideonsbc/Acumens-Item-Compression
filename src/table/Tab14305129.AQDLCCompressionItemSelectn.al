table 14305129 "AQDLC Compression Item Selectn"
{
    Caption = 'Compression Item Selection';
    DataClassification = CustomerContent;
    LookupPageId = "AQDLC Compression Item Selectn";
    DrillDownPageId = "AQDLC Compression Item Selectn";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(4; "OrderBy Value"; Decimal)
        {
            Caption = 'Count/Amount';
            //CaptionClass = FnOrderByValCaption();
        }
        field(5; "Order By"; Option)
        {
            Caption = 'Criteria';
            OptionMembers = "No. of Entries",Quantity,Sales;
        }
        field(6; "As of Date"; Date)
        {
            Caption = 'As of Date';
        }
        field(7; "Number of Items"; Integer)
        {
            Caption = 'Number of Items';
        }
        field(8; "Schedule No."; Integer)
        {
            TableRelation = "AQDLC ILE Compression Schedule";
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; "OrderBy Value")
        { }
    }
    trigger OnInsert()
    var
        CompItemSelection: Record "AQDLC Compression Item Selectn";
    begin
        if "Entry No." = 0 then begin
            CompItemSelection.Reset();
            CompItemSelection.SetAscending("Entry No.", false);
            if CompItemSelection.FindFirst() then
                "Entry No." := CompItemSelection."Entry No.";
            "Entry No." += 1;
        end;
    end;

    procedure FnOrderByValCaption(): Text
    begin
        if Rec."Order By" = Rec."Order By"::Quantity then
            exit('Remaining Quantity');
        if Rec."Order By" = Rec."Order By"::Sales then
            exit('Total Sales');
        exit('ILE Entries');
    end;
}
