codeunit 14305128 "AQDLC Posted Documents Comp"
{
    Permissions =
    tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Invoice Line" = rimd,
    tabledata "Posted Whse. Shipment Header" = rimd,
    tabledata "Posted Whse. Shipment Line" = rimd,
    tabledata "Posted Whse. Receipt Header" = rimd,
    tabledata "Posted Whse. Receipt Line" = rimd,
    tabledata "Sales Shipment Header" = rimd,
    tabledata "Sales Shipment Line" = rimd,
    tabledata "Purch. Inv. Header" = rimd,
    tabledata "Purch. Inv. Line" = rimd,
    tabledata "Transfer Shipment Header" = rimd,
    tabledata "Transfer Shipment Line" = rimd,
    tabledata "Transfer Receipt Header" = rimd,
    tabledata "Transfer Receipt Line" = rimd,
    tabledata "Tracking Specification" = rimd,
    tabledata "Job Queue Log Entry" = rimd;

    var
        MaxPostingDate: Date;
        ScheduleNo: Integer;
        SkipCompressedTables: Boolean;
        MaxRunTimeHrs: Decimal;
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
        JobQueueLogEntry: Record "Job Queue Log Entry";

    trigger OnRun()
    begin
        CompressPostedDocs();
    end;

    var
        Window: Dialog;
        Txt000: Label 'Compressing Posted Documents\Period: #1##############################\Processing Table: #2##############################';

    local procedure OpenWindow()
    begin
        if not GuiAllowed then exit;
        Window.Open(Txt000);
        Window.Update(1, '..' + Format(MaxPostingDate));
    end;

    local procedure UpdateWindow(No: Integer; Msg: Text)
    begin
        if not GuiAllowed then exit;
        Window.Update(No, Msg);
    end;

    local procedure CloseWindow()
    begin
        if not GuiAllowed then exit;
        Window.Close();
    end;

    procedure SetRunParameter(vMaxPostingDate: Date; vScheduleNo: Integer; vSkipCompressedTables: Boolean; vMaxRunTimeHrs: Decimal; vExecutionStartDt: DateTime)
    begin
        MaxPostingDate := vMaxPostingDate;
        ScheduleNo := vScheduleNo;
        SkipCompressedTables := vSkipCompressedTables;
        MaxRunTimeHrs := vMaxRunTimeHrs;

        ExecutionStartDt := vExecutionStartDt;
        StartTimeoutCountDown(ExecutionStartDt);
    end;

    var
        NoOfRecordsDeleted: Integer;

    local procedure CompressPostedDocs()
    var
        Counter: Integer;
        FilterText: Text;
        MaxPostingDateTime: DateTime;
    begin
        if MaxPostingDate = 0D then exit;
        OpenWindow();

        //<<Sales Invoices
        if not CheckIfSkipTable(Database::"Sales Invoice Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Sales Invoices');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Sales Invoice Header", 'Posted Sales Invoices (Headers + Lines)');

            Counter := 0;
            FilterText := '';
            PostedSalesInvoices.SetCurrentKey("Posting Date");
            PostedSalesInvoices.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedSalesInvoices.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedSalesInvoices."No.")
                    else
                        FilterText += '|' + Format(PostedSalesInvoices."No.");

                    if Counter = 1000 then begin
                        DeletePostedSalesInvoices(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedSalesInvoices.Next() = 0;
            DeletePostedSalesInvoices(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Sales Invoice Header", PostedSalesInvoices.TableName);
            Commit();
        end;
        //>>Sales Invoices

        //<<Purchase Invoices
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Purch. Inv. Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Purchase Invoices');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Purch. Inv. Header", 'Posted Purchase Invoices (Headers and Lines)');

            Counter := 0;
            FilterText := '';
            PostedPurchInvHdr.SetCurrentKey("Posting Date");
            PostedPurchInvHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedPurchInvHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedPurchInvHdr."No.")
                    else
                        FilterText += '|' + Format(PostedPurchInvHdr."No.");

                    if Counter = 1000 then begin
                        DeletePostedPurchaseInvoices(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedPurchInvHdr.Next() = 0;
            DeletePostedPurchaseInvoices(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Purch. Inv. Header", PostedPurchInvHdr.TableName);
            Commit();
        end;
        //>>Purchase Invoices

        //<<Sales Shipments
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Sales Shipment Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Sales Shipments');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Sales Shipment Header", 'Posted Sales Shipments (Headers and Lines)');

            Counter := 0;
            FilterText := '';
            PostedSalesShipmentHdr.SetCurrentKey("Posting Date");
            PostedSalesShipmentHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedSalesShipmentHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedSalesShipmentHdr."No.")
                    else
                        FilterText += '|' + Format(PostedSalesShipmentHdr."No.");

                    if Counter = 1000 then begin
                        DeletePostedSalesShipments(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedSalesShipmentHdr.Next() = 0;
            DeletePostedSalesShipments(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Sales Shipment Header", PostedSalesShipmentHdr.TableName);
            Commit();
        end;
        //>>Sales Shipments

        //<<Transfer Shipments
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Transfer Shipment Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Transfer Shipments');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Transfer Shipment Header", 'Posted Transfer Shipments (Headers and Lines)');

            Counter := 0;
            FilterText := '';
            PostedTransferShipmentHdr.SetCurrentKey("Posting Date");
            PostedTransferShipmentHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedTransferShipmentHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedTransferShipmentHdr."No.")
                    else
                        FilterText += '|' + Format(PostedTransferShipmentHdr."No.");

                    if Counter = 1000 then begin
                        DeletePostedTransferShipments(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedTransferShipmentHdr.Next() = 0;
            DeletePostedTransferShipments(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Transfer Shipment Header", PostedTransferShipmentHdr.TableName);
            Commit();
        end;
        //>>Transfer Shipments

        //<<Transfer Receipts
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Transfer Receipt Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Transfer Receipts');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Transfer Receipt Header", 'Posted Transfer Receipts (Headers and Lines)');

            Counter := 0;
            FilterText := '';
            PostedTransferRcptHdr.SetCurrentKey("Posting Date");
            PostedTransferRcptHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedTransferRcptHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedTransferRcptHdr."No.")
                    else
                        FilterText += '|' + Format(PostedTransferRcptHdr."No.");

                    if Counter = 1000 then begin
                        DeletePostedTransferReceipts(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedTransferRcptHdr.Next() = 0;
            DeletePostedTransferReceipts(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Transfer Receipt Header", PostedTransferRcptHdr.TableName);
            Commit();
        end;
        //>>Transfer Receipts

        //<<Warehouse Shipments
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Posted Whse. Shipment Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Warehouse Shipments');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Posted Whse. Shipment Header", 'Posted Warehouse Shipments (Headers and Lines)');

            Counter := 0;
            FilterText := '';
            PostedWarehouseShipmentHdr.SetCurrentKey("Posting Date");
            PostedWarehouseShipmentHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedWarehouseShipmentHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedWarehouseShipmentHdr."No.")
                    else
                        FilterText += '|' + Format(PostedWarehouseShipmentHdr."No.");

                    if Counter = 1000 then begin
                        DeletePostedWhseShipments(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedWarehouseShipmentHdr.Next() = 0;
            DeletePostedWhseShipments(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Posted Whse. Shipment Header", PostedWarehouseShipmentHdr.TableName);
            Commit();
        end;
        //>>Warehouse Shipments

        //<<Warehouse Receipts
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Posted Whse. Receipt Header") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Posted Warehouse Receipts');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Posted Whse. Receipt Header", 'Posted Warehouse Receipts (Headers and Lines)');

            Counter := 0;
            FilterText := '';
            PostedWhseRcptHdr.SetCurrentKey("Posting Date");
            PostedWhseRcptHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedWhseRcptHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(PostedWhseRcptHdr."No.")
                    else
                        FilterText += '|' + Format(PostedWhseRcptHdr."No.");

                    if Counter = 1000 then begin
                        DeletePostedWhseReceipts(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until PostedWhseRcptHdr.Next() = 0;
            DeletePostedWhseReceipts(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Posted Whse. Receipt Header", PostedWhseRcptHdr.TableName);
            Commit();
        end;
        //>>Warehouse Receipts

        //<<Job Queue Log Entries
        CheckExecutionTimeOut();
        if not CheckIfSkipTable(Database::"Job Queue Log Entry") then begin
            NoOfRecordsDeleted := 0;
            UpdateWindow(2, 'Job Queue Log Entries');
            LogEntryNo := 0;
            UpdateCompressionLogEntry(0, LogEntryNo, Database::"Job Queue Log Entry", 'Job Queue Log Entries');

            MaxPostingDateTime := CreateDateTime(CalcDate('<+1D>', MaxPostingDate), 000000T);
            Counter := 0;
            FilterText := '';
            JobQueueLogEntry.SetCurrentKey("Start Date/Time", ID);
            JobQueueLogEntry.SetFilter("Start Date/Time", '<%1', MaxPostingDateTime);
            if JobQueueLogEntry.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    if FilterText = '' then
                        FilterText := Format(JobQueueLogEntry."Entry No.")
                    else
                        FilterText += '|' + Format(JobQueueLogEntry."Entry No.");

                    if Counter = 1000 then begin
                        DeleteJobQEntries(FilterText);

                        Clear(FilterText);
                        Counter := 0;
                        CheckExecutionTimeOut();
                    end;

                until JobQueueLogEntry.Next() = 0;
            DeleteJobQEntries(FilterText);

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Job Queue Log Entry", JobQueueLogEntry.TableName);
            Commit();
        end;
        //>>Job Queue Log Entries

        CloseWindow();
    end;

    local procedure DeletePostedSalesInvoices(DocNosFilter: Text)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if DocNosFilter = '' then exit;

        SalesInvoiceHeader.SetCurrentKey("No.");
        SalesInvoiceHeader.SetFilter("No.", DocNosFilter);
        SalesInvoiceHeader.DeleteAll();

        PostedSalesInvoiceLines.SetCurrentKey("Document No.", "Line No.");
        PostedSalesInvoiceLines.SetFilter("Document No.", DocNosFilter);
        NoOfRecordsDeleted += PostedSalesInvoiceLines.Count;
        PostedSalesInvoiceLines.DeleteAll();

        Commit();
    end;

    local procedure DeletePostedPurchaseInvoices(DocNosFilter: Text)
    var
        PurchInvHdr: Record "Purch. Inv. Header";
    begin
        if DocNosFilter = '' then exit;

        PurchInvHdr.SetCurrentKey("No.");
        PurchInvHdr.SetFilter("No.", DocNosFilter);
        PurchInvHdr.DeleteAll();

        PostedPurchInvLine.SetCurrentKey("Document No.", "Line No.");
        PostedPurchInvLine.SetFilter("Document No.", DocNosFilter);
        NoOfRecordsDeleted += PostedPurchInvLine.Count;
        PostedPurchInvLine.DeleteAll();

        Commit();
    end;

    local procedure DeletePostedSalesShipments(DocNosFilter: Text)
    var
        SalesShipmentHdr: Record "Sales Shipment Header";
    begin
        if DocNosFilter = '' then exit;

        SalesShipmentHdr.SetCurrentKey("No.");
        SalesShipmentHdr.SetFilter("No.", DocNosFilter);
        SalesShipmentHdr.DeleteAll();

        PostedSalesShipmentLine.SetCurrentKey("Document No.", "Line No.");
        PostedSalesShipmentLine.SetFilter("Document No.", DocNosFilter);
        NoOfRecordsDeleted += PostedSalesShipmentLine.Count;
        PostedSalesShipmentLine.DeleteAll();

        Commit();
    end;

    local procedure DeletePostedTransferShipments(DocNosFilter: Text)
    var
        TransferShipmentHdr: Record "Transfer Shipment Header";
    begin
        if DocNosFilter = '' then exit;

        TransferShipmentHdr.SetCurrentKey("No.");
        TransferShipmentHdr.SetFilter("No.", DocNosFilter);
        TransferShipmentHdr.DeleteAll();

        PostedTransferShipmentLine.SetCurrentKey("Document No.", "Line No.");
        PostedTransferShipmentLine.SetFilter("Document No.", DocNosFilter);
        NoOfRecordsDeleted += PostedTransferShipmentLine.Count;
        PostedTransferShipmentLine.DeleteAll();

        Commit();
    end;

    local procedure DeletePostedTransferReceipts(DocNosFilter: Text)
    var
        TransferReceiptHdr: Record "Transfer Receipt Header";
    begin
        if DocNosFilter = '' then exit;

        TransferReceiptHdr.SetCurrentKey("No.");
        TransferReceiptHdr.SetFilter("No.", DocNosFilter);
        TransferReceiptHdr.DeleteAll();

        PostedTransferRcptLine.SetCurrentKey("Document No.", "Line No.");
        PostedTransferRcptLine.SetFilter("Document No.", DocNosFilter);
        NoOfRecordsDeleted += PostedTransferRcptLine.Count;
        PostedTransferRcptLine.DeleteAll();

        Commit();
    end;

    local procedure DeletePostedWhseShipments(DocNosFilter: Text)
    var
        PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header";
    begin
        if DocNosFilter = '' then exit;

        PostedWhseShipmentHeader.SetCurrentKey("No.");
        PostedWhseShipmentHeader.SetFilter("No.", DocNosFilter);
        PostedWhseShipmentHeader.DeleteAll();

        PostedWarehouseShipmentLine.SetCurrentKey("No.", "Line No.");
        PostedWarehouseShipmentLine.SetFilter("No.", DocNosFilter);
        NoOfRecordsDeleted += PostedWarehouseShipmentLine.Count;
        PostedWarehouseShipmentLine.DeleteAll();

        Commit();
    end;

    local procedure DeletePostedWhseReceipts(DocNosFilter: Text)
    var
        PostedWhseReceiptHeader: Record "Posted Whse. Shipment Header";
    begin
        if DocNosFilter = '' then exit;

        PostedWhseReceiptHeader.SetCurrentKey("No.");
        PostedWhseReceiptHeader.SetFilter("No.", DocNosFilter);
        PostedWhseReceiptHeader.DeleteAll();

        PostedWhseRcptLine.SetCurrentKey("No.", "Line No.");
        PostedWhseRcptLine.SetFilter("No.", DocNosFilter);
        NoOfRecordsDeleted += PostedWhseRcptLine.Count;
        PostedWhseRcptLine.DeleteAll();

        Commit();
    end;

    local procedure DeleteJobQEntries(DocNosFilter: Text)
    var
        JobQLogEntry: Record "Job Queue Log Entry";
    begin
        if DocNosFilter = '' then exit;

        JobQLogEntry.SetCurrentKey("Entry No.");
        JobQLogEntry.SetFilter("Entry No.", DocNosFilter);
        JobQLogEntry.DeleteAll();

        Commit();
    end;

    local procedure CheckIfSkipTable(TableNo: Integer): Boolean
    var
        PostedDocsCompressionLog: Record "AQDLC Posted Docs Compress Log";
    begin
        PostedDocsCompressionLog.SetCurrentKey("Schedule No.", "As of Date", "Table ID");
        PostedDocsCompressionLog.SetRange("Schedule No.", ScheduleNo);
        PostedDocsCompressionLog.SetRange("Table ID", TableNo);
        PostedDocsCompressionLog.SetRange("As of Date", MaxPostingDate);
        if PostedDocsCompressionLog.Find('-') then begin
            if SkipCompressedTables then begin
                if PostedDocsCompressionLog."End Date/Time" = 0DT then begin //was incomplete
                    PostedDocsCompressionLog.Delete();
                    exit(false);
                end else
                    exit(true)
            end else begin
                PostedDocsCompressionLog.Delete();
                exit(false);
            end;
        end;
        exit(false);
    end;

    var
        LogEntryNo: Integer;

    local procedure UpdateCompressionLogEntry(vAction: Option Create,Update; var vLogEntryNo: Integer; TableNo: Integer; TableName: Text)
    var
        PostedDocsCompressionLog: Record "AQDLC Posted Docs Compress Log";
    begin
        if ScheduleNo = 0 then exit;
        if (vLogEntryNo = 0) and (vAction = vAction::Update) then
            vAction := vAction::Create;

        if vAction = vAction::Create then begin
            PostedDocsCompressionLog.Init();
            PostedDocsCompressionLog."Schedule No." := ScheduleNo;
            PostedDocsCompressionLog."As of Date" := MaxPostingDate;
            PostedDocsCompressionLog."Table ID" := TableNo;
            PostedDocsCompressionLog."Table Name" := CopyStr(TableName, 1, 50);
            PostedDocsCompressionLog."Start Date/Time" := CurrentDateTime;
            PostedDocsCompressionLog.Insert(true);
            vLogEntryNo := PostedDocsCompressionLog."Entry No.";
        end;

        if vAction = vAction::Update then begin
            PostedDocsCompressionLog.SetCurrentKey("Schedule No.", "As of Date", "Table ID");
            PostedDocsCompressionLog.SetRange("Schedule No.", ScheduleNo);
            PostedDocsCompressionLog.SetRange("Table ID", TableNo);
            PostedDocsCompressionLog.SetRange("As of Date", MaxPostingDate);
            if PostedDocsCompressionLog.Find('-') then begin
                PostedDocsCompressionLog."End Date/Time" := CurrentDateTime;
                PostedDocsCompressionLog."No. of Records Deleted" := NoOfRecordsDeleted;
                PostedDocsCompressionLog.Modify();
            end;
        end;
    end;

    var
        ExecutionStartDt: DateTime;
        ExpectedExecutionEndDt: DateTime;
        ExecutionTimeOutMsg: Text;
        ExecutionTimeOut: Boolean;

    local procedure StartTimeoutCountDown(ExecutionStartDt: DateTime)
    begin
        if MaxRunTimeHrs > 0 then begin
            ExpectedExecutionEndDt := ExecutionStartDt + Round(MaxRunTimeHrs * 3600000, 1, '<');
            ExecutionTimeOutMsg := StrSubstNo('The configured runtime limit of %1 hour(s) has been exhausted. All completed compressions have been committed successfully. Run the report again later to process the remaining entries.', MaxRunTimeHrs);
        end;
    end;

    local procedure CheckExecutionTimeOut(): Boolean
    var
    begin
        if ExpectedExecutionEndDt = 0DT then exit(false);

        if CurrentDateTime >= ExpectedExecutionEndDt then begin
            ExecutionTimeOut := true;
            Error(ExecutionTimeOutMsg);
        end;
    end;
}