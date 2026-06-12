table 14305131 "AQDLC ILE Compression Schedule"
{
    Caption = 'ILE Compression Schedule';
    DataClassification = CustomerContent;
    LookupPageId = "AQDLC ILE Compression Schedule";
    DrillDownPageId = "AQDLC ILE Compression Schedule";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Cut-off Date"; Date)
        {
            Caption = 'Cut-off Date';

            trigger OnValidate()
            begin
                if ("Cut-off Date" <> 0D) then begin
                    PreventDuplicateSchedules();
                    Description := Format(Date2DMY("Cut-off Date", 3)) + ' Compression';
                end;
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                TestField("Cut-off Date");
            end;
        }
        field(4; Processed; Boolean)
        {
            Caption = 'Processed';
            Editable = false;
        }
        field(5; "Items Compressed"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Item where("AQDLC Last Compression No." = field("Entry No.")));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; "Cut-off Date")
        {
        }
    }
    trigger OnInsert()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        if "Entry No." = 0 then begin
            CompressionSchedule.Reset();
            CompressionSchedule.SetAscending("Entry No.", false);
            if CompressionSchedule.FindFirst() then
                "Entry No." := CompressionSchedule."Entry No.";
            "Entry No." += 1;
        end;
        PreventDuplicateSchedules();
    end;

    trigger OnModify()
    begin
        PreventDuplicateSchedules();
    end;

    trigger OnDelete()
    begin
        if Processed then
            Error('You cannot delete a processed scheduled!');
    end;

    local procedure PreventDuplicateSchedules()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        if "Cut-off Date" = 0D then exit;
        if "Entry No." = 0 then exit;

        CompressionSchedule.SetRange("Cut-off Date", "Cut-off Date");
        CompressionSchedule.SetFilter("Entry No.", '<>%1', "Entry No.");
        if CompressionSchedule.Find('-') then
            Error('There exists another schedule (No. %1) for Cut-off Date %1', CompressionSchedule."Entry No.", "Cut-off Date");
    end;
}
