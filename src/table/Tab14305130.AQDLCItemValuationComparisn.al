table 14305130 "AQDLC Item Valuation Comparisn"
{
    Caption = 'Item Valuation Comparison';
    DataClassification = CustomerContent;
    LookupPageId = "AQDLC Item Valuation Comparisn";
    DrillDownPageId = "AQDLC Item Valuation Comparisn";

    fields
    {
        field(1; "Register No."; Integer)
        {
            Caption = 'Register No.';
            TableRelation = "AQDLC ILE Compression Register";
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; "Item Description"; Text[200])
        {
            Caption = 'Description';
        }
        field(4; "Cut-off Date"; Date)
        {
            Caption = 'Cut-off Date';
        }
        field(5; "Remaining Qty Before"; Decimal)
        {
            Caption = 'Remaining Qty Before';
        }
        field(6; "Unit Cost Before"; Decimal)
        {
            Caption = 'Unit Cost Before';
        }
        field(7; "Inventory Value Before"; Decimal)
        {
            Caption = 'Inventory Value Before';
        }
        field(8; "Remaining Qty After"; Decimal)
        {
            Caption = 'Remaining Qty After';
        }
        field(9; "Unit Cost After"; Decimal)
        {
            Caption = 'Unit Cost After';
        }
        field(10; "Inventory Value After"; Decimal)
        {
            Caption = 'Inventory Value After';
        }
        field(11; "Quantity Variance"; Decimal)
        {
            Caption = 'Quantity Variance';
        }
        field(12; "Valuation Variance"; Decimal)
        {
            Caption = 'Valuation Variance';
        }
        field(13; "Schedule No."; Integer)
        {
            TableRelation = "AQDLC ILE Compression Schedule";
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Register No.", "Item No.")
        {
            Clustered = true;
        }
        key(Key1; "Register No.")
        { }
    }
}
