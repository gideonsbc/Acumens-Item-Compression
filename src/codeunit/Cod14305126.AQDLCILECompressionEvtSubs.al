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

    [EventSubscriber(ObjectType::Table, Database::"Value Entry", OnAfterDeleteEvent, '', false, false)]
    local procedure t5802_OnAfterDeleteEvent(var Rec: Record "Value Entry")
    var
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
    begin
        if not (ILECompressionSetup.Get() and ILECompressionSetup."Enable App") then exit;
        ILECompressionSingleInst.IncrementVEDeleteCount();

        //GLItemLedgerRelation.SetRange("Value Entry No.", Rec."Entry No.");
        //GLItemLedgerRelation.DeleteAll();
        ILECompressionSingleInst.UpdateVEDeleteFilter(Rec."Entry No.");
    end;
}
