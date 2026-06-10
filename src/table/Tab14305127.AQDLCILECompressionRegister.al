table 14305127 "AQDLC ILE Compression Register"
{
    Caption = 'AQD ILE Compression Register';
    DataClassification = CustomerContent;
    LookupPageId = "AQDLC ILE Compression Regs";
    DrillDownPageId = "AQDLC ILE Compression Regs";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Executed On"; DateTime)
        {
            Caption = 'Executed On';
            Editable = false;
        }
        field(3; "Executed By"; Code[50])
        {
            Caption = 'Executed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(4; "Item Filter"; Text[200])
        {
            Caption = 'Item Filter';
            Editable = false;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Incomplete,Completed;
            Editable = false;
        }
        field(6; "Start Date/Time"; DateTime)
        {
            Caption = 'Start Date/Time';
        }
        field(7; "End Date/Time"; DateTime)
        {
            Caption = 'End Date/Time';
        }
        field(8; "Posting Date"; Date)
        {
            Editable = false;
        }
        field(9; "Posting Date Run No."; Integer)
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; "Posting Date", "Posting Date Run No.")
        { }
    }
    trigger OnInsert()
    var
        ILECompReg: Record "AQDLC ILE Compression Register";
    begin
        if "Entry No." = 0 then begin
            ILECompReg.Reset();
            ILECompReg.SetAscending("Entry No.", false);
            if ILECompReg.FindFirst() then
                "Entry No." := ILECompReg."Entry No.";
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
