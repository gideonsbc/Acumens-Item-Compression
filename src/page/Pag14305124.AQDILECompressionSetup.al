page 14305124 "AQD ILE Compression Setup"
{
    ApplicationArea = All;
    Caption = 'Acumens Item Ledger Compression Setup';
    PageType = Card;
    SourceTable = "AQD ILE Compression Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Cut-off Period"; Rec."Cut-off Period")
                {
                    ToolTip = 'Specifies the value of the Cut-off Period field.', Comment = '%';
                }
            }
            group(CompressionGroupFields)
            {
                Caption = 'Compression Group Fields';
                field("Group by Item"; Rec."Group by Item")
                {
                    Editable = false;
                }
                field("Group by Location Code"; Rec."Group by Location Code")
                { }
                field("Group by Variant Code"; Rec."Group by Variant Code")
                { }
                field("Group by Lot No."; Rec."Group by Lot No.")
                { }
                field("Group by Serial No."; Rec."Group by Serial No.")
                { }
                field("Group by Package No."; Rec."Group by Package No.")
                { }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            /*action("Initialize App")
            {
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Assigns AQD App permission set to all users and creates TARIFF Charge.';
                Caption = 'Initialize the App';
                trigger OnAction()
                begin
                    InitializeApp(true);
                end;
            }
            action("About App")
            {
                Image = Info;
                ApplicationArea = All;
                ToolTip = 'Shows more information about the Acumens Freight, Duties & Tariffs App';
                Caption = 'About the App';
                RunObject = page "AQD About Acumens Tariff App";
            }*/
            group("CompressResults1")
            {
                Caption = '&Compress Results';
                Image = Dimensions;
                action("&Quantity on Hand")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity on Hand';
                    Image = List;
                    RunObject = Page "AQD Quantity on Hand";
                    ToolTip = 'View Quantity on Hand';
                }
            }
        }
        area(Promoted)
        {
            group(HOME)
            {
                Caption = 'Home', Comment = 'Generated from the PromotedActionCategories property index 3.';

                /*actionref(InitializeApp_Home; "Initialize App")
                {
                }*/
            }
            group(About)
            {
                Caption = 'About', Comment = 'Generated from the PromotedActionCategories property index 5.';

                /*actionref(Aboutapp_About; "About App")
                {
                }*/
            }
            group(CompressResults)
            {
                Caption = '&Compression Results', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref(QoH_Promoted; "&Quantity on Hand")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Evaluate(Rec."Cut-off Period", '-7Y');
            Rec.Insert();
        end;
        if Format(Rec."Cut-off Period") = '' then
            Evaluate(Rec."Cut-off Period", '-7Y');
        Rec."Group by Item" := true;
    end;
}
