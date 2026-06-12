page 14305125 "AQDLC Quantity on Hand"
{
    ApplicationArea = All;
    Caption = 'Quantity on Hand';
    PageType = List;
    SourceTable = "AQDLC Qty on Hand";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;
    Editable = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

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
                field("Register No."; Rec."Register No.")
                {
                    trigger OnDrillDown()
                    var
                        ILECompressionLog: Record "AQDLC ILE Compression Register";
                    begin
                        if Rec."Register No." = 0 then exit;

                        ILECompressionLog.Reset();
                        ILECompressionLog.SetRange("Entry No.", Rec."Register No.");
                        if ILECompressionLog.Find('-') then
                            Page.Run(Page::"AQDLC ILE Compression Register", ILECompressionLog);
                    end;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ToolTip = 'Specifies the value of the Lot No. field.', Comment = '%';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ToolTip = 'Specifies the value of the Serial No. field.', Comment = '%';
                }
                field("Package No."; Rec."Package No.")
                {
                    ToolTip = 'Specifies the value of the Package No. field.', Comment = '%';
                }
                field("Qty On Hand"; Rec."Qty On Hand")
                {
                    ToolTip = 'Specifies the value of the Qty On Hand field.', Comment = '%';
                }
                field("Net Qty On Hand"; Rec."Net Qty On Hand")
                {
                    ToolTip = 'Specifies the value of the Net Qty On Hand field.', Comment = '%';
                    Visible = false;
                }
                field("Season Code"; Rec."Season Code")
                {
                    ToolTip = 'Specifies the value of the Season Code field.', Comment = '%';
                    Visible = false;
                }
                field("Shortcut Dimension 6 Code"; Rec."Shortcut Dimension 6 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 6 Code field.', Comment = '%';
                    Visible = false;
                }
                field("Applied Quanty"; Rec."Applied Quanty")
                {
                    ToolTip = 'Specifies the value of the Applied Quanty field.', Comment = '%';
                    Visible = false;
                }
                field("Last Puchase/ +Ve Unit Cost"; Rec."Last Puchase/ +Ve Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Last Puchase/ +Ve Unit Cost field.', Comment = '%';
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                { }
                field("Inventory Value"; Rec."Inventory Value")
                { }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("Item Ledgers")
            {
                Image = ItemLedger;
                ApplicationArea = All;
                Caption = 'Item Ledgers';
                RunObject = Page "Item Ledger Entries";
                RunPageLink = "AQDLC Comp. Reg No." = field("Register No."), "AQDLC QoH Entry No." = field("Entry No.");
            }
            action("&Valuation Comparison")
            {
                ApplicationArea = All;
                Caption = 'Valuation Comparison';
                Image = List;
                RunObject = Page "AQDLC Item Valuation Comparisn";
                RunPageLink = "Register No." = field("Register No."), "Item No." = field("Item No.");
                ToolTip = 'View Item Valuation Comparison';
            }
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

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
