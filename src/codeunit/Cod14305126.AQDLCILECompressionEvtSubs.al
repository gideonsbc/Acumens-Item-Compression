codeunit 14305126 "AQDLC ILE Compression Evt Subs"
{
    Permissions = tabledata "Post Value Entry to G/L" = rimd,
                    tabledata "G/L - Item Ledger Relation" = rimd;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        ILECompressionSingleInst: Codeunit "AQDLC ILE Compress Single Inst";

    [EventSubscriber(ObjectType::Report, Report::"Post Inventory Cost to G/L", OnAfterInsertValueEntryNoBuf, '', false, false)]
    local procedure OnAfterInsertValueEntryNoBuf(ValueEntry: Record "Value Entry")
    var
        PostValueEntryToGl: Record "Post Value Entry to G/L";
    begin
        if not (ILECompressionSetup.Get() and ILECompressionSetup."Enable App") then exit;

        if PostValueEntryToGl.Get(ValueEntry."Entry No.") then begin
            PostValueEntryToGl."AQDLC Skipped" := true;
            PostValueEntryToGl.Modify();
        end;
    end;
}
