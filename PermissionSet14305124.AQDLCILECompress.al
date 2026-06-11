permissionset 14305124 "AQDLC ILE Compress"
{
    Caption = 'Acumens Item Ledger Compression';
    Assignable = true;
    Permissions = tabledata "AQDLC Compression Item Selectn" = RIMD,
        tabledata "AQDLC ILE Compress Log Entry" = RIMD,
        tabledata "AQDLC ILE Compression Register" = RIMD,
        tabledata "AQDLC ILE Compression Setup" = RIMD,
        tabledata "AQDLC Qty on Hand" = RIMD,
        table "AQDLC Compression Item Selectn" = X,
        table "AQDLC ILE Compress Log Entry" = X,
        table "AQDLC ILE Compression Register" = X,
        table "AQDLC ILE Compression Setup" = X,
        table "AQDLC Qty on Hand" = X,
        report "AQDLC Compress Add. Tables Rec" = X,
        report "AQDLC Compress Item Selection" = X,
        report "AQDLC Create ILE Entrs frm QoH" = X,
        report "AQDLC Create Item Application" = X,
        report "AQDLC Date Compress Item Ledg" = X,
        report "AQDLC Delete ILE and VLE" = X,
        report "AQDLC Dlt Orphn Itm Apl Entry" = X,
        report "AQDLC Generate Qty On Hand" = X,
        report "AQDLC Post-Compress Invt. Val" = X,
        codeunit "AQDLC Item Ledger Compression" = X,
        page "AQDLC Compression Item Selectn" = X,
        page "AQDLC ILE Compress Log Entries" = X,
        page "AQDLC ILE Compression Register" = X,
        page "AQDLC ILE Compression Regs" = X,
        page "AQDLC ILE Compression Setup" = X,
        page "AQDLC Quantity on Hand" = X;
}