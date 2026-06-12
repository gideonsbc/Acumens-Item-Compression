pageextension 14305124 "AQDLCItem Card" extends "Item Card"
{
    layout
    {
        addafter(Item)
        {
            group("AQDLCAcumens Item Ledger Compression")
            {
                Caption = 'Acumens Item Ledger Compression';
                Visible = ILECompressionGrpVisible;

                field("AQDLC Last Compression No."; Rec."AQDLC Last Compression No.")
                {
                    ApplicationArea = All;
                }
                field("AQDLC Last Compression Date"; Rec."AQDLC Last Compression Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ILECompressionGrpVisible := false;
        if ILECompressionSetup.Get() and ILECompressionSetup."Enable App" then begin
            ILECompressionGrpVisible := true;
        end;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        ILECompressionGrpVisible: Boolean;
}
