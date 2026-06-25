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
        Txt000: Label 'Compressing Posted Documents\Period: #1##############################\Processing Table: #2##############################\No. of Records Deleted: #3##############################';

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
        Counter2: Integer;
        MaxPostingDateTime: DateTime;
        StartEntryNo: Integer;
        LastEntryNo: Integer;
        EndEntryNo: Integer;
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
            PostedSalesInvoices.SetCurrentKey("Posting Date");
            PostedSalesInvoices.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedSalesInvoices.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedSalesInvoiceLines.SetCurrentKey("Document No.", "Line No.");
                    PostedSalesInvoiceLines.SetRange("Document No.", PostedSalesInvoices."No.");
                    NoOfRecordsDeleted += PostedSalesInvoiceLines.Count;
                    PostedSalesInvoiceLines.DeleteAll();

                    PostedSalesInvoices.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedSalesInvoices.Next() = 0;

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
            PostedPurchInvHdr.SetCurrentKey("Posting Date");
            PostedPurchInvHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedPurchInvHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedPurchInvLine.SetCurrentKey("Document No.", "Line No.");
                    PostedPurchInvLine.SetRange("Document No.", PostedPurchInvHdr."No.");
                    NoOfRecordsDeleted += PostedPurchInvLine.Count;
                    PostedPurchInvLine.DeleteAll();

                    PostedPurchInvHdr.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedPurchInvHdr.Next() = 0;

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
            PostedSalesShipmentHdr.SetCurrentKey("Posting Date");
            PostedSalesShipmentHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedSalesShipmentHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedSalesShipmentLine.SetCurrentKey("Document No.", "Line No.");
                    PostedSalesShipmentLine.SetRange("Document No.", PostedSalesShipmentHdr."No.");
                    NoOfRecordsDeleted += PostedSalesShipmentLine.Count;
                    PostedSalesShipmentLine.DeleteAll();

                    PostedSalesShipmentHdr.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedSalesShipmentHdr.Next() = 0;

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
            PostedTransferShipmentHdr.SetCurrentKey("Posting Date");
            PostedTransferShipmentHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedTransferShipmentHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedTransferShipmentLine.SetCurrentKey("Document No.", "Line No.");
                    PostedTransferShipmentLine.SetRange("Document No.", PostedTransferShipmentHdr."No.");
                    NoOfRecordsDeleted += PostedTransferShipmentLine.Count;
                    PostedTransferShipmentLine.DeleteAll();

                    PostedTransferShipmentHdr.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedTransferShipmentHdr.Next() = 0;

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
            PostedTransferRcptHdr.SetCurrentKey("Posting Date");
            PostedTransferRcptHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedTransferRcptHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedTransferRcptLine.SetCurrentKey("Document No.", "Line No.");
                    PostedTransferRcptLine.SetRange("Document No.", PostedTransferRcptHdr."No.");
                    NoOfRecordsDeleted += PostedTransferRcptLine.Count;
                    PostedTransferRcptLine.DeleteAll();

                    PostedTransferRcptHdr.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedTransferRcptHdr.Next() = 0;

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
            PostedWarehouseShipmentHdr.SetCurrentKey("Posting Date");
            PostedWarehouseShipmentHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedWarehouseShipmentHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedWarehouseShipmentLine.SetCurrentKey("No.", "Line No.");
                    PostedWarehouseShipmentLine.SetRange("No.", PostedWarehouseShipmentHdr."No.");
                    NoOfRecordsDeleted += PostedWarehouseShipmentLine.Count;
                    PostedWarehouseShipmentLine.DeleteAll();

                    PostedWarehouseShipmentHdr.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedWarehouseShipmentHdr.Next() = 0;

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
            PostedWhseRcptHdr.SetCurrentKey("Posting Date");
            PostedWhseRcptHdr.SetFilter("Posting Date", '<=%1', MaxPostingDate);
            if PostedWhseRcptHdr.FindSet() then
                repeat
                    Counter += 1;
                    NoOfRecordsDeleted += 1;

                    PostedWhseRcptLine.SetCurrentKey("No.", "Line No.");
                    PostedWhseRcptLine.SetRange("No.", PostedWhseRcptHdr."No.");
                    NoOfRecordsDeleted += PostedWhseRcptLine.Count;
                    PostedWhseRcptLine.DeleteAll();

                    PostedWhseRcptHdr.Delete();

                    if Counter = 1000 then begin
                        UpdateWindow(3, Format(NoOfRecordsDeleted));
                        Counter := 0;
                        Commit();
                        CheckExecutionTimeOut();
                    end;

                until PostedWhseRcptHdr.Next() = 0;

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
            LastEntryNo := 0;
            JobQueueLogEntry.SetCurrentKey("Start Date/Time", ID);
            JobQueueLogEntry.SetFilter("Start Date/Time", '<%1', MaxPostingDateTime);
            if JobQueueLogEntry.FindLast() then
                LastEntryNo := JobQueueLogEntry."Entry No.";

            if LastEntryNo > 0 then begin
                StartEntryNo := 0;
                EndEntryNo := 0;
                repeat
                    StartEntryNo := EndEntryNo + 1;
                    EndEntryNo += 5000;
                    if EndEntryNo >= LastEntryNo then
                        EndEntryNo := LastEntryNo;

                    JobQueueLogEntry.Reset();
                    JobQueueLogEntry.SetRange("Entry No.", StartEntryNo, EndEntryNo);
                    JobQueueLogEntry.DeleteAll(false);

                    NoOfRecordsDeleted += EndEntryNo;
                    UpdateWindow(3, Format(NoOfRecordsDeleted));

                    Commit();
                    CheckExecutionTimeOut();

                until EndEntryNo >= LastEntryNo;
            end;

            UpdateCompressionLogEntry(1, LogEntryNo, Database::"Job Queue Log Entry", JobQueueLogEntry.TableName);
            Commit();
        end;
        //>>Job Queue Log Entries

        CloseWindow();
    end;

    local procedure DeletePostedWhseReceipts(DocNosFilter: Text)
    var
        PostedWhseReceiptHeader: Record "Posted Whse. Shipment Header";
    begin
        if DocNosFilter = '' then exit;

        PostedWhseReceiptHeader.SetCurrentKey("No.");
        PostedWhseReceiptHeader.SetFilter("No.", DocNosFilter);
        PostedWhseReceiptHeader.DeleteAll();

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