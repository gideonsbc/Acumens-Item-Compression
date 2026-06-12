page 14305130 "AQDLC Item Valuation Comparisn"
{
    ApplicationArea = All;
    Caption = 'Item Valuation Comparison';
    PageType = List;
    SourceTable = "AQDLC Item Valuation Comparisn";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Register No."; Rec."Register No.")
                {
                    ToolTip = 'Specifies the value of the Register No. field.', Comment = '%';
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
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.', Comment = '%';
                }
                field("Cut-off Date"; Rec."Cut-off Date")
                {
                    ToolTip = 'Specifies the value of the Cut-off Date field.', Comment = '%';
                }
                field("Remaining Qty Before"; Rec."Remaining Qty Before")
                {
                    ToolTip = 'Specifies the value of the Remaining Qty Before field.', Comment = '%';
                }
                field("Unit Cost Before"; Rec."Unit Cost Before")
                {
                    ToolTip = 'Specifies the value of the Unit Cost Before field.', Comment = '%';
                }
                field("Inventory Value Before"; Rec."Inventory Value Before")
                {
                    ToolTip = 'Specifies the value of the Inventory Value Before field.', Comment = '%';
                }
                field("Remaining Qty After"; Rec."Remaining Qty After")
                {
                    ToolTip = 'Specifies the value of the Remaining Qty After field.', Comment = '%';
                }
                field("Unit Cost After"; Rec."Unit Cost After")
                {
                    ToolTip = 'Specifies the value of the Unit Cost After field.', Comment = '%';
                }
                field("Inventory Value After"; Rec."Inventory Value After")
                {
                    ToolTip = 'Specifies the value of the Inventory Value After field.', Comment = '%';
                }
                field("Quantity Variance"; Rec."Quantity Variance")
                {
                    ToolTip = 'Specifies the value of the Quantity Variance field.', Comment = '%';
                }
                field("Valuation Variance"; Rec."Valuation Variance")
                {
                    ToolTip = 'Specifies the value of the Valuation Variance field.', Comment = '%';
                }
            }
        }
    }
}
