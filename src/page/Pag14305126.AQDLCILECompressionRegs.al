page 14305126 "AQDLC ILE Compression Regs"
{
    ApplicationArea = All;
    Caption = 'Item Ledger Compression Registers';
    PageType = List;
    SourceTable = "AQDLC ILE Compression Register";
    UsageCategory = Lists;
    CardPageId = "AQDLC ILE Compression Register";
    SourceTableView = sorting("Entry No.") order(descending);
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
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Cut-off Date"; Rec."Cut-off Date")
                { }
                field("Executed On"; Rec."Executed On")
                {
                    ToolTip = 'Specifies the value of the Executed On field.', Comment = '%';
                }
                field("Executed By"; Rec."Executed By")
                {
                    ToolTip = 'Specifies the value of the Executed By field.', Comment = '%';
                }
                field("Item Filter"; Rec."Item Filter")
                {
                    ToolTip = 'Specifies the value of the Item Filter field.', Comment = '%';
                    Visible = false;
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
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("Quantity on Hand")
            {
                Image = ItemLedger;
                ApplicationArea = All;
                Caption = 'Quantity on Hand';
                RunObject = Page "AQDLC Quantity on Hand";
                RunPageLink = "Register No." = field("Entry No.");
            }
            action("&Valuation Comparison")
            {
                ApplicationArea = All;
                Caption = 'Valuation Comparison';
                Image = List;
                RunObject = Page "AQDLC Item Valuation Comparisn";
                RunPageLink = "Register No." = field("Entry No.");
                ToolTip = 'View Item Valuation Comparison';
            }
            action("Item Ledgers")
            {
                Image = ItemLedger;
                ApplicationArea = All;
                Caption = 'Item Ledgers';
                RunObject = Page "Item Ledger Entries";
                RunPageLink = "AQDLC Comp. Reg No." = field("Entry No.");
            }
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(QuantityonHand_Home; "Quantity on Hand")
                {
                }
                actionref(ItemLedgers_Home; "Item Ledgers")
                {
                }
                actionref(ValuationComparison_Promoted; "&Valuation Comparison")
                {
                }
            }
        }
    }
}
