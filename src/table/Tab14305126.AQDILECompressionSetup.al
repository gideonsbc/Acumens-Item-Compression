table 14305126 "AQD ILE Compression Setup"
{
    Caption = 'AQD ILE Compression Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2; "Enable App"; Boolean)
        { }
        field(3; "Cut-off Period"; DateFormula)
        {
            Caption = 'Cut-off Period';

            trigger OnValidate()
            var
                TestDate: Date;
            begin
                TestDate := CALCDATE("Cut-off Period", Today);
                if TestDate > Today then
                    Error('Cut-off Period cannot result in a future date.');
            end;
        }
        field(4; "Group by Item"; Boolean)
        {
            InitValue = true;
            Caption = 'Item No.';
        }
        field(5; "Group by Location Code"; Boolean)
        {
            InitValue = true;
            Caption = 'Location Code';
        }
        field(6; "Group by Variant Code"; Boolean)
        {
            Caption = 'Variant Code';
        }
        field(7; "Group by Lot No."; Boolean)
        {
            Caption = 'Lot No.';
        }
        field(8; "Group by Serial No."; Boolean)
        {
            Caption = 'Serial No.';
        }
        field(9; "Group by Package No."; Boolean)
        {
            Caption = 'Package No.';
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
