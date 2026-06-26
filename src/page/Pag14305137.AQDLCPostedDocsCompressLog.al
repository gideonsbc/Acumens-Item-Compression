page 14305137 "AQDLC Posted Docs Compress Log"
{
    ApplicationArea = All;
    Caption = 'Posted Documents Compression Logs';
    PageType = List;
    SourceTable = "AQDLC Posted Docs Compress Log";
    UsageCategory = Lists;
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Schedule No."; Rec."Schedule No.")
                {
                    ToolTip = 'Specifies the value of the Schedule No. field.', Comment = '%';
                }
                field("As of Date"; Rec."As of Date")
                {
                    ToolTip = 'Specifies the value of the As of Date field.', Comment = '%';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.', Comment = '%';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the value of the Table Name field.', Comment = '%';
                }
                field("No. of Records Deleted"; Rec."No. of Records Deleted")
                { }
                field(Status; Rec.Status)
                { }
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

                }
            }
        }
    }
}
