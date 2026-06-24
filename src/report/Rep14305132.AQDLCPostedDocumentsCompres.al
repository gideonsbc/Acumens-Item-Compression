report 14305132 "AQDLC Posted Documents Compres"
{
    ApplicationArea = All;
    Caption = 'Posted Documents Compression';
    UsageCategory = Administration;
    Permissions = tabledata "Item Ledger Entry" = RIMD,
    tabledata "Value Entry" = RIMD,
    tabledata "Item Register" = rimd,
    tabledata "G/L - Item Ledger Relation" = rimd,
    tabledata "G/L Entry" = rimd,
    tabledata "Item Application Entry" = rimd;

    ProcessingOnly = true;
    dataset
    {
    }
    trigger OnInitReport();
    begin
        StartTime := CurrentDateTime;
    end;

    trigger OnPreReport();
    var
        DateToFilter: Date;
        DeleteRecord: Boolean;
    begin
        if ShowDialog then
            Window.Open('Compressing Posted Documents...');
        DateToFilter := MaxPostingDate;
        if DateToFilter = 0D then
            Error('You must select the end date!');

        PostedDocsCompressionCU.SetRunParameter(MaxPostingDate);
        if PostedDocsCompressionCU.Run() then
            Message('Success!');


    end;

    trigger OnPostReport();
    begin
        if not ShowDialog then exit;
        Window.Close();
        //Message('Report processing is completed.\Start Time: %1 End Time: %2 (%3)', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
    end;

    procedure SetRunParameters(vMaxPostingDate: Date; vCompressionRegNo: Integer; vShowDialog: Boolean)
    begin
        MaxPostingDate := vMaxPostingDate;
        CompressionRegNo := vCompressionRegNo;
        ShowDialog := vShowDialog;
    end;


    var
        Window: Dialog;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        MaxPostingDate: Date;
        ShowDialog: Boolean;
        CompressionRegNo: Integer;
        PostedDocsCompressionCU: Codeunit "AQDLC Posted Documents Comp";
}