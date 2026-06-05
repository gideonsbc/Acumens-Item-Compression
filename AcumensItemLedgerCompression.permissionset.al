permissionset 14305124 "AQD Item Ldgr Comprs"
{
    Caption = 'Acumens Item Ledger Compression';
    Assignable = true;
    Permissions = tabledata "AQD Item Quantity vs Remaining" = RIMD,
        tabledata "AQD Quantity on Hand" = RIMD,
        table "AQD Item Quantity vs Remaining" = X,
        table "AQD Quantity on Hand" = X,
        report "Check ILE & Its Application" = X,
        report "Check Item Remaining Quantity" = X,
        report "Compress Additional Tables Rec" = X,
        report "Create ILE Entries using QoH" = X,
        report "Create Item Application" = X,
        report "Create Missing ILEs" = X,
        report "Delete ILE and VLE" = X,
        report "Delete Orphan Item Appl. Entry" = X,
        report "Generate Quantity On Hand" = X,
        report "Move ILE To Old Number" = X,
        report "Open All Items for Adjustment" = X,
        codeunit "AQD Item Ledger Compression" = X,
        tabledata "AQD ILE Compression Setup" = RIMD,
        table "AQD ILE Compression Setup" = X,
        report "AQD Date Compress Item Ledger" = X,
        page "AQD ILE Compression Setup" = X,
        page "AQD Quantity on Hand" = X;
}