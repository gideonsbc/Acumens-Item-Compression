tableextension 14305126 "AQDLC Post Value Entry to G/L" extends "Post Value Entry to G/L"
{
    fields
    {
        field(14305124; "AQDLC Skipped"; Boolean)
        {
            Caption = 'Skipped';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
