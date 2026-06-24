table 14305134 "AQDLC Posted Docs Compress Log"
{
    Caption = 'Posted Documents Compression Logs';
    DataClassification = CustomerContent;
    LookupPageId = "AQDLC Posted Docs Compress Log";
    DrillDownPageId = "AQDLC Posted Docs Compress Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Schedule No."; Integer)
        {
            Caption = 'Schedule No.';
            TableRelation = "AQDLC ILE Compression Schedule";
            Editable = false;
        }
        field(3; "As of Date"; Date)
        {
            Caption = 'As of Date';
        }
        field(4; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(5; "Table Name"; Text[50])
        {
            Caption = 'Table Name';
        }
        field(6; "Start Date/Time"; DateTime)
        {
            Caption = 'Start Date/Time';
        }
        field(7; "End Date/Time"; DateTime)
        {
            Caption = 'End Date/Time';
        }
        field(8; "No. of Records Deleted"; Integer)
        {
            Caption = 'No. of Records Deleted';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key2; "Schedule No.", "As of Date", "Table ID")
        { }
    }
    trigger OnInsert()
    var
        PostedDocsCompressLog: Record "AQDLC Posted Docs Compress Log";
    begin
        if "Entry No." = 0 then begin
            PostedDocsCompressLog.Reset();
            PostedDocsCompressLog.SetAscending("Entry No.", false);
            if PostedDocsCompressLog.FindFirst() then
                "Entry No." := PostedDocsCompressLog."Entry No.";
            "Entry No." += 1;
        end;
    end;

    procedure Duration(): Duration
    begin
        if ("Start Date/Time" = 0DT) or ("End Date/Time" = 0DT) then
            exit(0);
        exit(Round("End Date/Time" - "Start Date/Time", 100));
    end;
}
