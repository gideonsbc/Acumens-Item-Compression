report 14305135 "AQDLC Date Compress Item Ledg"
{
    ApplicationArea = All;
    Caption = 'Date Compress Item Ledger';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    Permissions = tabledata "Item Ledger Entry" = rimd,
                    tabledata "Avg. Cost Adjmt. Entry Point" = rimd,
                    tabledata "Post Value Entry to G/L" = rimd,
                    tabledata "Value Entry" = rimd,
                    tabledata "Item Application Entry" = rimd;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
                ExecutionStartDt: DateTime;
            begin
                if EndingDate = 0D then
                    Error('Cut-off Date must be set!');
                ValidateCutoffDate();

                SomethingCompressed := false;
                if CompressionScheduleNo = 0 then begin
                    if GuiAllowed then
                        Error('You must select a compression schedule!');
                    CurrReport.Quit();
                end else begin
                    if SkipCompressedItems then
                        SetFilter("AQDLC Last Compression No.", '<>%1', CompressionScheduleNo);
                    if ScheduleDescription = '' then begin
                        if (CompressionSchedule.Get(CompressionScheduleNo) and (CompressionSchedule.Description <> '')) then
                            ScheduleDescription := CompressionSchedule.Description
                        else
                            ScheduleDescription := 'Date Compressed';
                    end;
                end;

                ExecutionStartDt := CurrentDateTime;
                ILECompressionCU.CreateILECompressionLog(GetFilters, EndingDate, ExecutionStartDt, CalledFromRegisterNo, RegNo, CompressionScheduleNo, PostingDateRunNo);
                StartTimeoutCountDown(ExecutionStartDt);
                StartTime := CurrentDateTime;
                OpenWindow();
                ILECompressionSingleInst.SetILECompressionParams(EndingDate, PostingDateRunNo, RegNo, CalledFromRegisterNo, ScheduleDescription);
            end;

            trigger OnAfterGetRecord()
            begin
                if CheckExecutionTimeOut() then
                    CurrReport.Break();

                UpdateWindow(2, Item."No." + ' - ' + Item.Description);
                ClearLastError();
                Commit();
                if Codeunit.Run(Codeunit::"AQDLC Item Ledger Compression", Item) then begin
                    SomethingCompressed := true;
                    Commit();
                end else begin
                    UpdateExecutionSummary(GetLastErrorText)
                end;
            end;

            trigger OnPostDataItem()
            begin
                UpdateWindow(1, '');
                if SomethingCompressed then begin
                    UpdateWindow(3, 'Compress Related Tables (8/8)');
                    ILECompressionSingleInst.SetILECompressionTask('CompressAdditionalRecs');
                    ClearLastError();
                    if Codeunit.Run(Codeunit::"AQDLC Item Ledger Compression", Item) then
                        ILECompressionCU.CloseILECompressionLog(2, ExecutionTimeOut, ExecutionTimeOutMsg)
                    else begin
                        UpdateExecutionSummary(GetLastErrorText);
                        ILECompressionCU.CloseILECompressionLog(1, ExecutionTimeOut, ExecutionTimeOutMsg);
                    end;
                end else
                    ILECompressionCU.CloseILECompressionLog(1, ExecutionTimeOut, ExecutionTimeOutMsg);

                if ExecutionTimeOut then
                    ExecutionSummaryTxt := ExecutionTimeOutMsg + '\\' + ExecutionSummaryTxt;

                Message('Item Ledger Compression Ended! Please review logs for details.\Start Time: %1 End Time: %2 (%3)\\' + ExecutionSummaryTxt, StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
                CloseWindow();
            end;
        }
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
                        ToolTip = 'The compression schedule to be executed after this selection';
                        ShowMandatory = true;
                        NotBlank = true;

                        trigger OnValidate()
                        var
                            CompressionSchedule: Record "AQDLC ILE Compression Schedule";
                        begin
                            if CompressionScheduleNo = 0 then exit;

                            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                                EndingDate := CompressionSchedule."Cut-off Date";
                                ValidateCutoffDate();
                                CurrReport.RequestOptionsPage.Update(false);
                                SkipCompressedItems := true;
                            end;
                        end;
                    }
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field(EndingDate; EndingDate)
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
                    group(SkipCompressedItemsGrp)
                    {
                        ShowCaption = false;
                        Visible = (CompressionScheduleNo <> 0);
                        field(SkipCompressedItems; SkipCompressedItems)
                        {
                            Caption = 'Skip Compressed Items';
                            ApplicationArea = All;
                            ToolTip = 'Items already compressed in the selected schedule will be skipped';
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
        actions
        {
            area(Processing)
            {
            }
        }
    }
    trigger OnInitReport()
    begin
        if not (ILECompressionSetup.Get() and ILECompressionSetup."Enable App") then
            Error('Acumens Item Ledger Compression App is not enabled');
        ILECompressionSetup.TestField("Cut-off Period");

        ILECompressionSetup.UpdateLatestValidDec31();
        EndingDate := ILECompressionSetup."Latest Valid December 31";
        if EndingDate = 0D then
            EndingDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);

        if CompressionScheduleNo = 0 then
            GetApplicableCompressionSchedule();
        if CompressionScheduleNo <> 0 then
            SkipCompressedItems := true;

        if not GuiAllowed then begin
            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                EndingDate := CompressionSchedule."Cut-off Date";
                ScheduleDescription := CompressionSchedule.Description;
            end;
        end;

        MaxRunTimeHrs := ILECompressionSetup."Maximum Runtime (Hours)";
    end;

    trigger OnPostReport()
    var
        CompressionRegister: Record "AQDLC ILE Compression Register";
    begin
        if GuiAllowed then begin
            CompressionRegister.Reset();
            CompressionRegister.SetRange("Entry No.", RegNo);
            if CompressionRegister.Find('-') then
                Page.Run(Page::"AQDLC ILE Compression Register", CompressionRegister);
        end;
    end;

    procedure SetRunParameters(vCompressionScheduleNo: Integer)
    begin
        CompressionScheduleNo := vCompressionScheduleNo;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        StartingDate: Date;
        EndingDate: Date;
        Window: Dialog;
        Txt000: Label 'Compressing Item Ledger Entries\Period: #1#####\Processing Item: #2#####\Status: #3#####';
        CalledFromRegisterNo: Integer;
        RegNo: Integer;
        PostingDateRunNo: Integer;
        ExecutionSummaryTxt: Text;
        SomethingCompressed: Boolean;
        ScheduleDescription: Text;
        CompressionScheduleNo: Integer;
        SkipCompressedItems: Boolean;
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
        ILECompressionCU: Codeunit "AQDLC Item Ledger Compression";
        ILECompressionSingleInst: Codeunit "AQDLC ILE Compress Single Inst";

    procedure SetCalledFromEntryNo(vCalledFromRegisterNo: Integer)
    begin
        CalledFromRegisterNo := vCalledFromRegisterNo;
        RegNo := CalledFromRegisterNo;
    end;


    var
        SummaryTxtFull: Boolean;

    local procedure UpdateExecutionSummary(Msg: Text)
    begin
        if SummaryTxtFull then exit;
        if (StrLen(ExecutionSummaryTxt + Msg) > 500) then begin
            SummaryTxtFull := true;
            exit;
        end;

        if ExecutionSummaryTxt = '' then
            ExecutionSummaryTxt := 'Errors Encountered:\ - ' + Msg
        else
            ExecutionSummaryTxt += '\ - ' + Msg;
    end;


    var
        ExecutionTimeOut: Boolean;
        ExpectedExecutionEndDt: DateTime;
        MaxRunTimeHrs: Decimal;
        ExecutionTimeOutMsg: Text;


    local procedure StartTimeoutCountDown(ExecutionStartDt: DateTime)
    var
        IleCompressionReg: Record "AQDLC ILE Compression Register";
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
            exit(true);
        end;
    end;

    local procedure ValidateCutoffDate()
    var
        CutOffDate: Date;
    begin
        if EndingDate = 0D then exit;
        CutOffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
        if EndingDate > CutOffDate then
            Error('The cut-off date %1 is not valid. The latest allowed cut-off date is %2.', EndingDate, CutOffDate);
    end;


    local procedure GetApplicableCompressionSchedule()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
    begin
        CompressionSchedule.SetCurrentKey("Cut-off Date");
        CompressionSchedule.SetFilter("Cut-off Date", '<=%1', EndingDate);
        CompressionSchedule.SetAscending("Cut-off Date", false);
        if CompressionSchedule.FindFirst() then
            CompressionScheduleNo := CompressionSchedule."Entry No.";
    end;

    local procedure OpenWindow()
    begin
        if not GuiAllowed then exit;
        Window.Open(Txt000);
        if StartingDate <> 0D then
            Window.Update(1, Format(StartingDate) + '..' + Format(EndingDate))
        else
            Window.Update(1, '..' + Format(EndingDate));
    end;

    local procedure UpdateWindow(No: Integer; Msg: Text)
    begin
        if not GuiAllowed then exit;

        Window.Update(No, Msg);
    end;

    local procedure CloseWindow()
    begin
        if GuiAllowed then
            Window.Close();
    end;
}
