table 14305125 "AQD Quantity on Hand"
{
    DataClassification = ToBeClassified;

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
        field(23; "Qty On Hand"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(24; "Net Qty On Hand"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(25; "Season Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(26; "Shortcut Dimension 6 Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(27; "Applied Quanty"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(28; "Last Puchase/ +Ve Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
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
    }
}