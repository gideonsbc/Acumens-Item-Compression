table 14305132 "AQDLC Compression Cues"
{
    Caption = 'Compression Cues';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }

        field(2; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(3; "Global Dimension 1 Filter"; Code[80])
        {
            Caption = 'Global Dimension 1 Filter';
            CaptionClass = '1,3,1';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(4; "Global Dimension 2 Filter"; Code[80])
        {
            Caption = 'Global Dimension 2 Filter';
            CaptionClass = '1,3,2';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(5; "Salesperson Code Filter"; Code[250])
        {
            Caption = 'Salesperson Code Filter';
            FieldClass = FlowFilter;
        }
        field(6; "Location Filter"; Code[250])
        {
            Caption = 'Location Code';
            FieldClass = FlowFilter;
            TableRelation = Location where("Use As In-Transit" = const(false));
            ValidateTableRelation = false;
        }
        field(7; "Responsibility Centre Filter"; Code[250])
        {
            Caption = 'Responsibility Centre Filter';
            FieldClass = FlowFilter;
            TableRelation = Location where("Use As In-Transit" = const(false));
            ValidateTableRelation = false;
        }
        field(8; "Selected Compression Items"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("AQDLC Compression Item Selectn");
            Caption = 'Selected Items';
        }
        field(9; "Compression Schedules"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("AQDLC ILE Compression Schedule");
            Caption = 'Compression Schedules';
        }

    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}