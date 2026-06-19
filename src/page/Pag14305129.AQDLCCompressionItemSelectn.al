page 14305129 "AQDLC Compression Item Selectn"
{
    ApplicationArea = All;
    Caption = 'Compression Item Selection';
    PageType = List;
    SourceTable = "AQDLC Compression Item Selectn";
    UsageCategory = Lists;
    Editable = false;

    Permissions = tabledata Item = rimd;

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
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("As of Date"; Rec."As of Date")
                {
                    ToolTip = 'Specifies the value of the As at Date field.', Comment = '%';
                }
                field("Order By"; Rec."Order By")
                { }
                field("OrderBy Value"; Rec."OrderBy Value")
                {
                    ToolTip = 'Specifies the value of the OrderBy Value field.', Comment = '%';
                }
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
                ToolTip = 'Run Date Compress Item Ledger for all selected items';
                trigger OnAction()
                var
                    ItemNosFilter: Text;
                    RptCompressIle: Report "AQDLC Date Compress Item Ledg";
                    ItemSelection: Record "AQDLC Compression Item Selectn";
                    ItemRec: Record Item;
                begin
                    if Rec.IsEmpty then
                        Error('There are no selected items!');

                    ItemNosFilter := '';
                    ItemSelection.Reset();
                    if ItemSelection.FindSet() then
                        repeat
                            if ItemNosFilter = '' then
                                ItemNosFilter := ItemSelection."Item No."
                            else
                                ItemNosFilter += '|' + ItemSelection."Item No.";
                        until ItemSelection.Next() = 0;

                    if ItemNosFilter = '' then
                        Error('There are no selected items!');

                    ItemRec.Reset();
                    ItemRec.SetFilter("No.", ItemNosFilter);
                    if ItemRec.Find('-') then begin
                        RptCompressIle.SetRunParameters(Rec."Schedule No.");
                        RptCompressIle.SetTableView(ItemRec);
                        RptCompressIle.Run();
                    end;
                end;
            }
            action("&Run Compression Data Analysis")
            {
                ApplicationArea = All;
                Caption = 'Run Compression Data Analysis';
                Image = Process;
                ToolTip = 'Analyzes inventory data prior to compression and identifies potential data integrity issues that may affect compression results.';
                trigger OnAction()
                var
                    ItemNosFilter: Text;
                    RptCompressionAnalysis: Report "AQDLC Compression Data Analys";
                    ItemSelection: Record "AQDLC Compression Item Selectn";
                    ItemRec: Record Item;
                begin
                    if Rec.IsEmpty then
                        Error('There are no selected items!');

                    ItemNosFilter := '';
                    ItemSelection.Reset();
                    if ItemSelection.FindSet() then
                        repeat
                            if ItemNosFilter = '' then
                                ItemNosFilter := ItemSelection."Item No."
                            else
                                ItemNosFilter += '|' + ItemSelection."Item No.";
                        until ItemSelection.Next() = 0;

                    if ItemNosFilter = '' then
                        Error('There are no selected items!');

                    ItemRec.Reset();
                    ItemRec.SetFilter("No.", ItemNosFilter);
                    if ItemRec.Find('-') then begin
                        RptCompressionAnalysis.SetRunParameters(Rec."Schedule No.");
                        RptCompressionAnalysis.SetTableView(ItemRec);
                        RptCompressionAnalysis.Run();
                    end;
                end;
            }
            action("&Run Item Selection")
            {
                ApplicationArea = All;
                Caption = 'Run Item Selection';
                Image = SelectReport;
                RunObject = Report "AQDLC Compress Item Selection";
                ToolTip = 'Run Compression Item Selection';
                Visible = false;
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
                actionref(RunCompressionDataAnalysis_Promoted; "&Run Compression Data Analysis")
                {
                }
                actionref(RunItemSelection_Promoted; "&Run Item Selection")
                {
                }
            }
        }
    }
}