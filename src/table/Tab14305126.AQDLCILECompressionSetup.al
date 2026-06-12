table 14305126 "AQDLC ILE Compression Setup"
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
                CutoffDate: Date;
                PrevYear: Integer;
            begin
                CutoffDate := CALCDATE("Cut-off Period", Today);
                if CutoffDate > Today then
                    Error('Cut-off Period cannot result in a future Cut-off Date %1.', CutoffDate);

                PrevYear := Date2DMY(CutoffDate, 3) - 1;
                "Latest Valid December 31" := DMY2Date(31, 12, PrevYear);
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
            InitValue = true;
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
        field(10; "Latest Valid December 31"; Date)
        {
            Editable = false;
        }
        field(11; "Maximum Runtime (Hours)"; Integer)
        {
            MinValue = 0;
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
