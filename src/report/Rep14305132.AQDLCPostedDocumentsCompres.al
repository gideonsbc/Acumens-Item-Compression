report 14305132 "AQDLC Posted Documents Compres"
{
    ApplicationArea = All;
    Caption = 'Posted Documents Compression';
    UsageCategory = Administration;

    ProcessingOnly = true;
    dataset
    {
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(CompressionScheduleNo; CompressionScheduleNo)
                    {
                        Caption = 'Schedule No.';
                        TableRelation = "AQDLC ILE Compression Schedule";
                        ToolTip = 'The compression schedule to be executed';
                        ShowMandatory = true;
                        NotBlank = true;

                        trigger OnValidate()
                        var
                            CompressionSchedule: Record "AQDLC ILE Compression Schedule";
                        begin
                            if CompressionScheduleNo = 0 then exit;

                            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                                CutoffDate := CompressionSchedule."Cut-off Date";
                                ValidateCutoffDate();
                                CurrReport.RequestOptionsPage.Update(false);
                                SkipCompressedTables := true;
                            end;
                        end;
                    }
                    field(CutoffDate; CutoffDate)
                    {
                        Caption = 'Cut-off Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = false;
                        Enabled = false;

                        trigger OnValidate()
                        begin
                            if CompressionScheduleNo <> 0 then
                                Error('When a Schedule No. is selected as above, the Cut-off date is picked from the schedule!');
                            ValidateCutoffDate();
                        end;
                    }
                    group(SkipCompressedTablesGrp)
                    {
                        ShowCaption = false;
                        Visible = (CompressionScheduleNo <> 0);
                        field(SkipCompressedTables; SkipCompressedTables)
                        {
                            Caption = 'Skip Compressed Tables';
                            ApplicationArea = All;
                            ToolTip = 'Tables already compressed in the selected schedule will be skipped';
                        }
                    }
                    field(MaxRunTimeHrs; MaxRunTimeHrs)
                    {
                        Caption = 'Maximum Runtime (Hours)';
                        DecimalPlaces = 0 : 10;
                    }
                }
            }
        }
    }

    trigger OnInitReport();
    begin
        if not (ILECompressionSetup.Get() and ILECompressionSetup."Enable App") then
            Error('Acumens Item Ledger Compression App is not enabled');
        ILECompressionSetup.TestField("Cut-off Period");

        ILECompressionSetup.UpdateLatestValidDec31();
        CutoffDate := ILECompressionSetup."Latest Valid December 31";
        if CutoffDate = 0D then
            CutoffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);

        if CompressionScheduleNo = 0 then
            GetApplicableCompressionSchedule();
        if CompressionScheduleNo <> 0 then
            SkipCompressedTables := true;

        if not GuiAllowed then begin
            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                CutoffDate := CompressionSchedule."Cut-off Date";
            end;
        end;

        MaxRunTimeHrs := ILECompressionSetup."Maximum Runtime (Hours)";
    end;

    trigger OnPreReport();
    begin
        //if ShowDialog then
        //Window.Open('Compressing Posted Documents...');
        if CompressionScheduleNo = 0 then begin
            if GuiAllowed then
                Error('You must select a compression schedule!');
            CurrReport.Quit();
        end;
        if CutoffDate = 0D then begin
            if GuiAllowed then
                Error('You must select the cut-off date!');
            CurrReport.Quit();
        end;

        ExecutionSummaryTxt := '';
        ClearLastError();
        StartTime := CurrentDateTime;
        PostedDocsCompressionCU.SetRunParameter(CutoffDate, CompressionScheduleNo, SkipCompressedTables, MaxRunTimeHrs, StartTime);
        if not PostedDocsCompressionCU.Run() then begin
            if not GuiAllowed then
                AcumensErrorReportingCU.AddErrorLogNoAttachmentV2('ILE Compression', 'Posted Documents Compression', 3, Report::"AQDLC Posted Documents Compres"
                , 'Posted Documents Compression' + ' Error: Schedule No.' + Format(CompressionScheduleNo), 'developer@sbcdynamicserp.com', '', '', GetLastErrorText)
            else
                ExecutionSummaryTxt := CopyStr(GetLastErrorText, 1, 2000);
        end;
        ShowDialog := GuiAllowed;
    end;

    trigger OnPostReport();
    var
        PostedDocsCompLog: Record "AQDLC Posted Docs Compress Log";
    begin
        if not ShowDialog then exit;
        //Window.Close();
        if ExecutionSummaryTxt = '' then
            ExecutionSummaryTxt := 'Successfully'
        else
            ExecutionSummaryTxt := ' With Error: \\' + ExecutionSummaryTxt;
        Message('Posted Documents Compression Ended ' + ExecutionSummaryTxt + '\\Start Time: %1 End Time: %2\Duration: %3', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));

        PostedDocsCompLog.SetRange("Schedule No.", CompressionScheduleNo);
        if PostedDocsCompLog.Find('-') then
            Page.Run(Page::"AQDLC Posted Docs Compress Log", PostedDocsCompLog);
    end;

    procedure SetRunParameters(vCutoffDate: Date; vCompressionScheduleNo: Integer; vShowDialog: Boolean)
    begin
        CutoffDate := vCutoffDate;
        CompressionScheduleNo := vCompressionScheduleNo;
        ShowDialog := vShowDialog;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        Window: Dialog;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        CutoffDate: Date;
        ShowDialog: Boolean;
        CompressionScheduleNo: Integer;
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
        PostedDocsCompressionCU: Codeunit "AQDLC Posted Documents Comp";
        ExecutionSummaryTxt: Text;
        SkipCompressedTables: Boolean;
        MaxRunTimeHrs: Decimal;
        AcumensErrorReportingCU: Codeunit "AQD Error Reporting Functions";

    local procedure ValidateCutoffDate()
    var
        CutOffDate: Date;
    begin
        if CutoffDate = 0D then exit;
        CutOffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
        if CutoffDate > CutOffDate then
            Error('The cut-off date %1 is not valid. The latest allowed cut-off date is %2.', CutoffDate, CutOffDate);
    end;


    local procedure GetApplicableCompressionSchedule()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        CompressionSchedule.SetCurrentKey("Cut-off Date");
        CompressionSchedule.SetFilter("Cut-off Date", '<=%1', CutoffDate);
        CompressionSchedule.SetAscending("Cut-off Date", false);
        if CompressionSchedule.FindFirst() then
            CompressionScheduleNo := CompressionSchedule."Entry No.";
    end;
}