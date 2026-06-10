tableextension 14305124 "AQDLC Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        field(14305124; "AQDLC Comp. Reg No."; Integer)
        {
            Caption = 'Compression Reg No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14305125; "AQDLC QoH Entry No."; Integer)
        {
            Caption = 'QoH Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14305126; "AQDLC Posting Date Run No."; Integer)
        {
            Caption = 'Posting Date Run No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
