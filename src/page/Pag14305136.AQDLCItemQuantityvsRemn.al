page 14305136 "AQDLC Item Quantity vs Remn"
{
    ApplicationArea = All;
    Caption = 'Item Quantity vs Remaining Quantity';
    PageType = List;
    SourceTable = "AQDLC Item Quantity vs Remn";
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
                    Visible = false;
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
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ToolTip = 'Specifies the value of the Remaining Quantity field.', Comment = '%';
                }
                field(Difference; Rec.Difference)
                {
                    ToolTip = 'Quantity - Remaining Quantity';
                }
                field("Inventory Value"; Rec."Inventory Value")
                {
                    ToolTip = 'Specifies the value of the Inventory Value field.', Comment = '%';
                    Visible = false;
                }
            }
        }
    }
}
