page 14305125 "AQDLC Quantity on Hand"
{
    ApplicationArea = All;
    Caption = 'Quantity on Hand';
    PageType = List;
    SourceTable = "AQDLC Qty on Hand";
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
                field("Unit Cost Before"; Rec."Unit Cost Before")
                { }
                field("Inventory Value Before"; Rec."Inventory Value Before")
                { }
                field("Qty On Hand After"; Rec."Qty On Hand After")
                { }
                field("Unit Cost After"; Rec."Unit Cost After")
                { }
                field("Inventory Value After"; Rec."Inventory Value After")
                { }
                field("Quantity Variance"; Rec."Quantity Variance")
                { }
                field("Valuation Variance"; Rec."Valuation Variance")
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
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(ItemLedgers_Home; "Item Ledgers")
                {
                }
            }
        }
    }
}
