page 14305133 "AQDLC Compression Cues"
{
    ApplicationArea = All;
    Caption = 'Compression Cues';
    PageType = ListPart;
    SourceTable = "AQDLC Compression Cues";
    RefreshOnActivate = true;
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            cuegroup(ILECompressions)
            {
                Caption = 'Item Ledger Compressions';
                //ShowCaption = false;
                field("Compression Schedules"; Rec."Compression Schedules")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "AQDLC ILE Compression Schedule";
                }
                field("Selected Compression Items"; Rec."Selected Compression Items")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "AQDLC Compression Item Selectn";
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}
