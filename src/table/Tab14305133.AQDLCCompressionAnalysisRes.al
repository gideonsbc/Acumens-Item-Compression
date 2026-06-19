table 14305133 "AQDLC Compression Analysis Res"
{
    Caption = 'Compression Analysis Result';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(4; "Schedule No."; Integer)
        {
            Caption = 'Schedule No.';
            TableRelation = "AQDLC ILE Compression Schedule";
        }
        field(5; "As of Date"; Date)
        {
            Caption = 'As of Date';
        }
        field(6; "Issue Type"; Enum "AQDLC Compression Analysis Iss")
        {
            Caption = 'Issue Type';
        }
        field(7; "Total Count"; Integer)
        {
            Caption = 'Total Count';
        }
        field(8; "Total Value"; Decimal)
        {
            Caption = 'Total Value';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key2; "Item No.", "Schedule No.", "As of Date", "Issue Type")
        { }
    }
    trigger OnInsert()
    var
        CompressionAnalysisResult: Record "AQDLC Compression Analysis Res";
    begin
        if "Entry No." = 0 then begin
            CompressionAnalysisResult.Reset();
            CompressionAnalysisResult.SetAscending("Entry No.", false);
            if CompressionAnalysisResult.FindFirst() then
                "Entry No." := CompressionAnalysisResult."Entry No.";
            "Entry No." += 1;
        end;
    end;
}
