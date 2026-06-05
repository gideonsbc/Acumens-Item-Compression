page 14305125 "AQD Quantity on Hand"
{
    ApplicationArea = All;
    Caption = 'Quantity on Hand';
    PageType = List;
    SourceTable = "AQD Quantity on Hand";
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
                }
                field("Season Code"; Rec."Season Code")
                {
                    ToolTip = 'Specifies the value of the Season Code field.', Comment = '%';
                }
                field("Shortcut Dimension 6 Code"; Rec."Shortcut Dimension 6 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 6 Code field.', Comment = '%';
                }
                field("Applied Quanty"; Rec."Applied Quanty")
                {
                    ToolTip = 'Specifies the value of the Applied Quanty field.', Comment = '%';
                }
                field("Last Puchase/ +Ve Unit Cost"; Rec."Last Puchase/ +Ve Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Last Puchase/ +Ve Unit Cost field.', Comment = '%';
                }
            }
        }
    }
}
