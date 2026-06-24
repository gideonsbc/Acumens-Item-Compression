table 14305124 "AQDLC Item Quantity vs Remn"
{
    Caption = 'Item Quantity vs Remaining';
    DataClassification = CustomerContent;
    LookupPageId = "AQDLC Item Quantity vs Remn";
    DrillDownPageId = "AQDLC Item Quantity vs Remn";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Schedule No."; Integer)
        {
            Caption = 'Schedule No.';
            TableRelation = "AQDLC ILE Compression Schedule";
        }
        field(3; "As of Date"; Date)
        {
            Caption = 'As of Date';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(7; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(8; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(9; "Package No."; Code[50])
        {
            Caption = 'Package No.';
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(11; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
        }
        field(12; "Applied Quantity"; Decimal)
        {
            Caption = 'Applied Quantity';
        }
        field(13; Comments; Text[250])
        {
            Caption = 'Comments';
        }
        field(14; "Inventory Value"; Decimal)
        { }
        field(15; Difference; Decimal)
        { }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key2; "Item No.", "Schedule No.", "Location Code", "Variant Code")
        { }
    }
    trigger OnInsert()
    var
        ItemQtyvsRemn: Record "AQDLC Item Quantity vs Remn";
    begin
        if "Entry No." = 0 then begin
            ItemQtyvsRemn.Reset();
            ItemQtyvsRemn.SetAscending("Entry No.", false);
            if ItemQtyvsRemn.FindFirst() then
                "Entry No." := ItemQtyvsRemn."Entry No.";
            "Entry No." += 1;
        end;
    end;
}





