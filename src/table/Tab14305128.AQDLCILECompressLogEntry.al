table 14305128 "AQDLC ILE Compress Log Entry"
{
    Caption = 'AQD ILE Compression Log Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Log No."; Integer)
        {
            Caption = 'Log No.';
            Editable = false;
            TableRelation = "AQDLC ILE Compression Register";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(4; Description; Text[200])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(5; "Error Message"; Text[2000])
        {
            Caption = 'Error Message';
            Editable = false;
        }
        field(6; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,Failed,Successful;
            Editable = false;
        }
        field(7; "Start Date/Time"; DateTime)
        {
            Caption = 'Start Date/Time';
            Editable = false;
        }
        field(8; "End Date/Time"; DateTime)
        {
            Caption = 'End Date/Time';
            Editable = false;
        }
        field(9; "No. of ILEs Deleted"; Integer)
        {
            Editable = false;
        }
        field(10; "No. of VEs Deleted"; Integer)
        {
            Editable = false;
        }
        field(11; "No. of ILEs Created"; Integer)
        {
            Editable = false;
        }
        field(12; "No. of VEs Created"; Integer)
        {
            Editable = false;
        }
        field(13; "No. of Records Deleted"; Integer)
        {
            Caption = 'No. of Records Deleted';
        }
        field(14; "No. of Records Created"; Integer)
        {
            Caption = 'No. of Records Created';
        }
    }
    keys
    {
        key(PK; "Log No.", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        ILECompLogEntry: Record "AQDLC ILE Compress Log Entry";
    begin
        if "Line No." = 0 then begin
            ILECompLogEntry.Reset();
            ILECompLogEntry.SetRange("Log No.", "Log No.");
            ILECompLogEntry.SetAscending("Line No.", false);
            if ILECompLogEntry.FindFirst() then
                "Line No." := ILECompLogEntry."Line No.";
            "Line No." += 1;
        end;
    end;

    procedure Duration(): Duration
    begin
        if ("Start Date/Time" = 0DT) or ("End Date/Time" = 0DT) then
            exit(0);
        exit(Round("End Date/Time" - "Start Date/Time", 100));
    end;
}
