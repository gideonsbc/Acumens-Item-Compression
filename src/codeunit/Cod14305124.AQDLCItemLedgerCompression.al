codeunit 14305124 "AQDLC Item Ledger Compression"
{
    Permissions = tabledata "Post Value Entry to G/L" = rimd;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";

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
