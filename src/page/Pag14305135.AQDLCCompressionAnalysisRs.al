page 14305135 "AQDLC Compression Analysis Rs"
{
    ApplicationArea = All;
    Caption = 'Compression Analysis Results';
    PageType = List;
    SourceTable = "AQDLC Compression Analysis Res";
    UsageCategory = Lists;
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    Permissions = tabledata "Item Ledger Entry" = rimd;

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
                    trigger OnDrillDown()
                    var
                        ItemQtyvsRemn: Record "AQDLC Item Quantity vs Remn";
                    begin
                        if Rec."Issue Type" <> Rec."Issue Type"::"Remaining Qty & ILE Qty Mismatch" then exit;

                        ItemQtyvsRemn.Reset();
                        ItemQtyvsRemn.SetRange("Item No.", Rec."Item No.");
                        ItemQtyvsRemn.SetRange("Schedule No.", Rec."Schedule No.");
                        if ItemQtyvsRemn.Find('-') then
                            Page.Run(Page::"AQDLC Item Quantity vs Remn", ItemQtyvsRemn);
                    end;
                }
                field("Total Value"; Rec."Total Value")
                {
                    ToolTip = 'Specifies the value of the Total Value field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("&ILEQtyVsRemaining")
            {
                ApplicationArea = All;
                Caption = 'ILE Qty vs Remaining Qty';
                Image = List;
                ToolTip = 'Open ILE Quantity vs Remaining Quantity page';
                Enabled = Rec."Issue Type" = Rec."Issue Type"::"Remaining Qty & ILE Qty Mismatch";
                trigger OnAction()
                var
                    ItemQtyVsRemn: Record "AQDLC Item Quantity vs Remn";
                begin
                    if Rec.IsEmpty then
                        Error('No item selected');
                    if Rec."Issue Type" <> Rec."Issue Type"::"Remaining Qty & ILE Qty Mismatch" then
                        Error('Only application to issue type %1', Rec."Issue Type"::"Remaining Qty & ILE Qty Mismatch");

                    ItemQtyVsRemn.SetRange("Item No.", Rec."Item No.");
                    ItemQtyVsRemn.SetRange("Schedule No.", Rec."Schedule No.");
                    if ItemQtyVsRemn.Find('-') then
                        Page.Run(Page::"AQDLC Item Quantity vs Remn", ItemQtyVsRemn)
                    else
                        Error('No records found!');
                end;
            }
            action("Item Ledgers")
            {
                Image = ItemLedger;
                ApplicationArea = All;
                Caption = 'Item Ledgers';

                trigger OnAction()
                var
                    ItemLedgers: Record "Item Ledger Entry";
                    ItemNosFilter: Text;
                    CompAnalysisRs: Record "AQDLC Compression Analysis Res";
                begin
                    if Rec.IsEmpty then
                        Error('Nothing selected!');

                    ItemNosFilter := '';
                    CurrPage.SetSelectionFilter(CompAnalysisRs);
                    if CompAnalysisRs.FindSet() then
                        repeat
                            if ItemNosFilter = '' then
                                ItemNosFilter := CompAnalysisRs."Item No."
                            else
                                ItemNosFilter += '|' + CompAnalysisRs."Item No.";
                        until CompAnalysisRs.Next() = 0;

                    if ItemNosFilter = '' then
                        Error('Nothing selected!');

                    ItemLedgers.Reset();
                    ItemLedgers.SetFilter("Item No.", ItemNosFilter);
                    ItemLedgers.SetFilter("Posting Date", '<=%1', Rec."As of Date");
                    Page.Run(Page::"Item Ledger Entries", ItemLedgers);
                end;
            }
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(ILEQtyVsRemaining_Promoted; "&ILEQtyVsRemaining")
                {
                }
                actionref(ItemLedgers_Promoted; "Item Ledgers")
                {
                }
            }
        }
    }
}
