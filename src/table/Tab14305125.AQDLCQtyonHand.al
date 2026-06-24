table 14305125 "AQDLC Qty on Hand"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "AQDLC Quantity on Hand";
    LookupPageId = "AQDLC Quantity on Hand";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(5; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(6; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(7; "Package No."; Code[50])
        {
            Caption = 'Package No.';
        }
        field(8; "Qty On Hand"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Net Qty On Hand"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Season Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Shortcut Dimension 6 Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Applied Quanty"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Last Puchase/ +Ve Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Unit Cost"; Decimal)
        { }
        field(15; "Inventory Value"; Decimal)
        { }
        field(16; "Item Qty On Hand Before"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; "Item Unit Cost Before"; Decimal)
        { }
        field(18; "Item Inventory Value Before"; Decimal)
        { }
        field(19; "Item Qty On Hand After"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(20; "Item Unit Cost After"; Decimal)
        { }
        field(21; "Item Inventory Value After"; Decimal)
        { }
        field(22; "Posting Date"; Date)
        {
            Editable = false;
        }
        field(23; "Item Quantity Variance"; Decimal)
        {
            Editable = false;
        }
        field(24; "Item Valuation Variance"; Decimal)
        {
            Editable = false;
        }
        field(25; "Register No."; Integer)
        {
            Editable = false;
            TableRelation = "AQDLC ILE Compression Register";
        }


    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = false;
        }
        key(Key1; "Item No.")
        {
            Clustered = false;
        }
        key(key2; "Item No.", "Register No.", "Location Code", "Variant Code")
        { }
    }
}