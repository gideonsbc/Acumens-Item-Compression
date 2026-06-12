page 14305131 "AQDLC ILE Compression Schedule"
{
    ApplicationArea = All;
    Caption = 'ILE Compression Schedules';
    PageType = List;
    SourceTable = "AQDLC ILE Compression Schedule";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;
    DelayedInsert = true;

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
                field("Cut-off Date"; Rec."Cut-off Date")
                {
                    ToolTip = 'Specifies the value of the Cut-off Date field.', Comment = '%';
                    ShowMandatory = true;
                    NotBlank = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Processed; Rec.Processed)
                {
                    ToolTip = 'Specifies the value of the Processed field.', Comment = '%';
                    Visible = false;
                }
                field("Items Compressed"; Rec."Items Compressed")
                { }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("&Run Compression")
            {
                ApplicationArea = All;
                Caption = 'Run Compression';
                Image = Compress;
                ToolTip = 'Run Date Compress Item Ledger the selected schedule';
                trigger OnAction()
                var
                    RptCompressIle: Report "AQDLC Date Compress Item Ledg";
                    ItemSelection: Record "AQDLC Compression Item Selectn";
                begin
                    if Rec.IsEmpty then
                        Error('No schedule selected!');

                    RptCompressIle.SetRunParameters(Rec."Entry No.");
                    RptCompressIle.Run();
                end;
            }
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(RunCompression_Promoted; "&Run Compression")
                {
                }
            }
        }
    }
}
