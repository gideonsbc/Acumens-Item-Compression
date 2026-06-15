table 14305131 "AQDLC ILE Compression Schedule"
{
    Caption = 'Item Compression Schedule';
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
            Caption = 'End Date';
            NotBlank = true;

            trigger OnValidate()
            begin
                if ("Cut-off Date" <> 0D) then begin
                    PreventDuplicateSchedules();
                end;
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                TestField(Year);
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
        field(6; Year; Integer)
        {
            MinValue = 0;

            trigger OnValidate()
            begin
                Description := '';
                "Cut-off Date" := 0D;
                if Year <> 0 then begin
                    Description := Format(Year) + ' Compression';
                    Validate("Cut-off Date", DMY2Date(31, 12, Year));
                end;
            end;
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

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";

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
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        if Processed then
            Error('You cannot delete a processed schedule!');

        CompressionSchedule.Reset();
        if CompressionSchedule.Count = 1 then
            Error('You cannot delete this schedule because at least one schedule must always exist.');
    end;

    local procedure PreventDuplicateSchedules()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
        MaxCutoffDate: Date;
    begin
        if "Cut-off Date" = 0D then exit;
        if "Entry No." = 0 then exit;

        ILECompressionSetup.Get();
        ILECompressionSetup.TestField("Cut-off Period");
        MaxCutoffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
        if "Cut-off Date" > MaxCutoffDate then
            Error('The End-Date date %1 is not valid. The latest allowed End-Date date is %2.', "Cut-off Date", MaxCutoffDate);

        CompressionSchedule.SetRange("Cut-off Date", "Cut-off Date");
        CompressionSchedule.SetFilter("Entry No.", '<>%1', "Entry No.");
        if CompressionSchedule.Find('-') then
            Error('There exists another schedule (No. %1) for End-Date Date %2', CompressionSchedule."Entry No.", "Cut-off Date");
    end;
}
