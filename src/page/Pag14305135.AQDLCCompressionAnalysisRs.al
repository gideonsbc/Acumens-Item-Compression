page 14305135 "AQDLC Compression Analysis Rs"
{
    ApplicationArea = All;
    Caption = 'Compression Analysis Results';
    PageType = List;
    SourceTable = "AQDLC Compression Analysis Res";
    UsageCategory = Lists;
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                { }
                field(Description; Rec.Description)
                { }
                field("Schedule No."; Rec."Schedule No.")
                {
                    ToolTip = 'Specifies the value of the Schedule No. field.', Comment = '%';
                }
                field("As of Date"; Rec."As of Date")
                { }
                field("Issue Type"; Rec."Issue Type")
                {
                    ToolTip = 'Specifies the value of the Issue Type field.', Comment = '%';
                }
                field("Total Count"; Rec."Total Count")
                {
                    ToolTip = 'Specifies the value of the Total Count field.', Comment = '%';
                }
                field("Total Value"; Rec."Total Value")
                {
                    ToolTip = 'Specifies the value of the Total Value field.', Comment = '%';
                }
            }
        }
    }
}
