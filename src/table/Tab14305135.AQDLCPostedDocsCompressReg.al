table 14305135 "AQDLC Posted Docs Compress Reg"
{
    Caption = 'AQD Posted Docs Comp Register';
    DataClassification = CustomerContent;

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
        field(3; "Cut-off Date"; Date)
        {
            Caption = 'Cut-off Date';
        }
        field(4; "Executed By"; Code[50])
        {
            Caption = 'Executed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(5; "Executed On"; DateTime)
        {
            Caption = 'Executed On';
        }
        field(6; "Deleted Records"; Integer)
        {
            Caption = 'Deleted Records';
            FieldClass = FlowField;
            CalcFormula = sum("AQDLC Posted Docs Compress Log"."No. of Records Deleted" where("Register No." = field("Entry No.")));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        PostedDocsCompReg: Record "AQDLC Posted Docs Compress Reg";
    begin
        if "Entry No." = 0 then begin
            PostedDocsCompReg.Reset();
            PostedDocsCompReg.SetAscending("Entry No.", false);
            if PostedDocsCompReg.FindFirst() then
                "Entry No." := PostedDocsCompReg."Entry No.";
            "Entry No." += 1;
        end;
    end;
}
