codeunit 14305128 "AQDLC Posted Documents Comp"
{
    var
        MaxPostingDate: Date;
        PostedSalesInvoices: Record "Sales Invoice Header";
        PostedSalesInvoiceLines: Record "Sales Invoice Line";
        PostedWarehouseShipmentHdr: Record "Posted Whse. Shipment Header";
        PostedWarehouseShipmentLine: Record "Posted Whse. Shipment Line";
        PostedWhseRcptHdr: Record "Posted Whse. Receipt Header";
        PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
        PostedSalesShipmentHdr: Record "Sales Shipment Header";
        PostedSalesShipmentLine: Record "Sales Shipment Line";
        PostedPurchInvHdr: Record "Purch. Inv. Header";
        PostedPurchInvLine: Record "Purch. Inv. Line";
        WhseTransfer: Record "Transfer Shipment Header";
        PostedTransferShipmentHdr: Record "Transfer Shipment Header";
        PostedTransferShipmentLine: Record "Transfer Shipment Line";
        PostedTransferRcptHdr: Record "Transfer Receipt Header";
        PostedTransferRcptLine: Record "Transfer Receipt Line";
        TrackingSpecification: Record "Tracking Specification";

    trigger OnRun()
    begin

    end;

    procedure SetRunParameter(vMaxPostingDate: Date)
    begin
        MaxPostingDate := vMaxPostingDate;
    end;

    local procedure CompressPostedDocs()
    begin
        if MaxPostingDate = 0D then exit;

        PostedSalesInvoices.SetCurrentKey("Posting Date");
        PostedSalesInvoices.SetFilter("Posting Date", '<=%1', MaxPostingDate);
        PostedSalesInvoices.DeleteAll(false);
        Commit();
    end;
}
