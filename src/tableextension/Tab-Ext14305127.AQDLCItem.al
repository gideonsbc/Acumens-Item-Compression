tableextension 14305127 AQDLCItem extends Item
{
    fields
    {
        field(14305124; "AQDLC Last Compression No."; Integer)
        {
            Caption = 'Last Compression No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "AQDLC ILE Compression Schedule";
        }
        field(14305125; "AQDLC Last Compression Date"; Date)
        {
            Caption = 'Last Compression Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }


    keys
    {
        key(AQDLCKey1; "AQDLC Last Compression No.")
        {
        }
    }
}
