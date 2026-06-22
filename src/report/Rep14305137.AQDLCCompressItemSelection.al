report 14305137 "AQDLC Compress Item Selection"
{
    ApplicationArea = All;
    Caption = 'Run Compression Item Selection';
    UsageCategory = Administration;
    ProcessingOnly = true;

    Permissions = tabledata "Item Ledger Entry" = rimd;

    dataset
    {
        dataitem(Item; Item)
        {

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := Today;
                if ShowDialog then
                    Window.Open(Text001);

                if (CompressionScheduleNo <> 0) and SkipCompressedItems then
                    SetFilter("AQDLC Last Compression No.", '<>%1', CompressionScheduleNo);
                StartTime := CurrentDateTime;
            end;

            trigger OnAfterGetRecord()
            var
                OrderedVal: Decimal;
                ItemLedgers: Record "Item Ledger Entry";
            begin
                if ShowDialog then
                    Window.Update(1, "No." + ' => ' + Description);

                OrderedVal := 0;
                ItemLedgers.SetRange("Item No.", "No.");
                ItemLedgers.SetFilter("Posting Date", '<=%1', AsOfDate);
                if ItemLedgers.FindSet() then
                    repeat
                        if OrderBy = OrderBy::"No. of Entries" then
                            OrderedVal += 1
                        else if OrderBy = OrderBy::Quantity then begin
                            OrderedVal += ItemLedgers.Quantity;
                        end else if OrderBy = OrderBy::Sales then begin
                            ItemLedgers.CalcFields("Sales Amount (Actual)", "Sales Amount (Expected)");
                            OrderedVal += (ItemLedgers."Sales Amount (Actual)" + ItemLedgers."Sales Amount (Expected)");
                        end;
                    until ItemLedgers.Next() = 0;
                UpdateItemSelectionBuffer(Item, OrderedVal);
            end;

            trigger OnPostDataItem()
            begin
                OrderSelectedItems();
                if not ShowDialog then exit;
                Window.Close();
                Message('Process completed\Start Time: %1 End Time: %2 (%3)', StartTime, CurrentDateTime, ItemLedgerCompCU.getDuration(StartTime, CurrentDateTime));
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
                    field(AsOfDate; AsOfDate)
                    {
                        Caption = 'As at Date';
                        ShowMandatory = true;
                        ApplicationArea = All;
                    }
                    field(NoOfItems; NoOfItems)
                    {
                        Caption = 'No. of Items (Top N)';
                        ApplicationArea = All;
                    }
                    field(OrderBy; OrderBy)
                    {
                        Caption = 'Order By';
                        ApplicationArea = All;
                    }
                    field(CompressionScheduleNo; CompressionScheduleNo)
                    {
                        Caption = 'Schedule No.';
                        TableRelation = "AQDLC ILE Compression Schedule";
                        ToolTip = 'The compression schedule to be executed after this selection';

                        trigger OnValidate()
                        var
                            CompressionSchedule: Record "AQDLC ILE Compression Schedule";
                        begin
                            if CompressionScheduleNo = 0 then exit;

                            if CompressionSchedule.Get(CompressionScheduleNo) then begin
                                SkipCompressedItems := true;
                                CurrReport.RequestOptionsPage.Update(false);
                            end;
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
        AsOfDate := Today;
        NoOfItems := 3;

        if CompressionScheduleNo = 0 then
            GetApplicableCompressionSchedule();

        if CompressionScheduleNo <> 0 then
            SkipCompressedItems := true;
        ShowDialog := GuiAllowed;
    end;

    trigger OnPreReport()
    begin
        _ItemSelectionBuf.DeleteAll();
    end;

    trigger OnPostReport()
    var
        vItemSelection: Record "AQDLC Compression Item Selectn";
    begin
        if GuiAllowed then begin
            vItemSelection.Reset();
            Page.Run(Page::"AQDLC Compression Item Selectn", vItemSelection);
        end;
    end;

    var
        ILECompressionSetup: Record "AQDLC ILE Compression Setup";
        AsOfDate: Date;
        OrderBy: Option "No. of Entries",Quantity,Sales;
        NoOfItems: Integer;
        ItemSelection: Record "AQDLC Compression Item Selectn";
        _ItemSelectionBuf: Record "AQDLC Compression Item Selectn" temporary;
        EntryNo: Integer;
        CompressionScheduleNo: Integer;
        SkipCompressedItems: Boolean;
        StartTime: DateTime;
        ItemLedgerCompCU: Codeunit "AQDLC Item Ledger Compression";
        Window: Dialog;
        Text001: Label 'Processing Item No.  ########1#####';
        ShowDialog: Boolean;

    local procedure UpdateItemSelectionBuffer(vItem: Record Item; OrderByVal: Decimal)
    var
    begin
        EntryNo += 1;
        _ItemSelectionBuf.Init();
        _ItemSelectionBuf."Entry No." := EntryNo;
        _ItemSelectionBuf."Item No." := vItem."No.";
        _ItemSelectionBuf.Description := vItem.Description;
        _ItemSelectionBuf."OrderBy Value" := OrderByVal;
        _ItemSelectionBuf.Insert(true);
    end;

    local procedure OrderSelectedItems()
    var
        vEntryNo: Integer;
    begin
        vEntryNo := 0;
        ItemSelection.DeleteAll();

        _ItemSelectionBuf.SetCurrentKey("OrderBy Value");
        _ItemSelectionBuf.SetAscending("OrderBy Value", false);
        _ItemSelectionBuf.SetFilter("OrderBy Value", '<>%1', 0);
        if _ItemSelectionBuf.FindSet() then
            repeat
                vEntryNo += 1;

                ItemSelection.Init();
                ItemSelection."Entry No." := vEntryNo;
                ItemSelection."Item No." := _ItemSelectionBuf."Item No.";
                ItemSelection."Schedule No." := CompressionScheduleNo;
                ItemSelection.Description := _ItemSelectionBuf.Description;
                ItemSelection."Order By" := OrderBy;
                ItemSelection."OrderBy Value" := _ItemSelectionBuf."OrderBy Value";
                ItemSelection."Number of Items" := NoOfItems;
                ItemSelection."As of Date" := AsOfDate;
                ItemSelection.Insert();
            until (_ItemSelectionBuf.Next() = 0) or (vEntryNo = NoOfItems);
    end;

    local procedure GetApplicableCompressionSchedule()
    var
        CompressionSchedule: Record "AQDLC ILE Compression Schedule";
        MaxCutoffDate: Date;
    begin
        MaxCutoffDate := CalcDate(ILECompressionSetup."Cut-off Period", Today);
        CompressionSchedule.SetCurrentKey("Cut-off Date");
        CompressionSchedule.SetFilter("Cut-off Date", '<=%1', MaxCutoffDate);
        CompressionSchedule.SetAscending("Cut-off Date", false);
        if CompressionSchedule.FindFirst() then
            CompressionScheduleNo := CompressionSchedule."Entry No.";
    end;
}
