table 14305124 "AQD Item Quantity vs Remaining"
{
    Caption = 'Item Quantity vs Remaining';
    DataClassification = ToBeClassified;

    fields
    {
        // ...existing code...
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(22; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
        }
        field(23; "Applied Quantity"; Decimal)
        {
            Caption = 'Applied Quantity';
        }
        field(24; Comments; Text[250])
        {
            Caption = 'Comments';
        }
        // ...existing code...
    }

    keys
    {
        key(PK; "Item No.", "Location Code")
        {
            Clustered = true;
        }
        // ...existing code...
    }
}





