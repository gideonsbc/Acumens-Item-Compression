page 14305127 "AQDLC ILE Compression Register"
{
    ApplicationArea = All;
    Caption = 'Item Ledger Compression Register';
    PageType = Card;
    SourceTable = "AQDLC ILE Compression Register";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                field("Duration"; Rec.Duration)
                {
                    Editable = false;
                }
            }
            group(ModifiedRecords)
            {
                Caption = 'Modified Records';
                field("No. of ILEs Deleted"; Rec."No. of ILEs Deleted")
                { }
                field("No. of VEs Deleted"; Rec."No. of VEs Deleted")
                { }
                field("No. of ILEs Created"; Rec."No. of ILEs Created")
                { }
                field("No. of VEs Created"; Rec."No. of VEs Created")
                { }
            }
            part("AQD ILE Compression Log Entrs"; "AQDLC ILE Compress Log Entries")
            {
                Caption = 'Log Entries';
                SubPageLink = "Log No." = field("Entry No.");
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
            }
        }
    }
}
