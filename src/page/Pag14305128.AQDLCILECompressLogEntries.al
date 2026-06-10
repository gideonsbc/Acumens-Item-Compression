page 14305128 "AQDLC ILE Compress Log Entries"
{
    ApplicationArea = All;
    Caption = 'ILE Compression Log Entries';
    PageType = ListPart;
    SourceTable = "AQDLC ILE Compress Log Entry";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Start Date/Time"; Rec."Start Date/Time")
                {
                    ToolTip = 'Specifies the value of the Start Date/Time field.', Comment = '%';
                }
                field("End Date/Time"; Rec."End Date/Time")
                {
                    ToolTip = 'Specifies the value of the End Date/Time field.', Comment = '%';
                }
                field("Duration"; Rec.Duration)
                {
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                { }
            }
        }
    }
}
