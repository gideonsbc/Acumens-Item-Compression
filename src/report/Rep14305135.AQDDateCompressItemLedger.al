report 14305135 "AQD Date Compress Item Ledger"
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
            begin
                if EndingDate = 0D then
                    Error('Ending Date must be set!');

                StartTime := Time;
                Window.Open(Txt000);
                if StartingDate <> 0D then
                    Window.Update(1, Format(StartingDate) + '..' + Format(EndingDate))
                else
                    Window.Update(1, '..' + Format(EndingDate));
            end;

            trigger OnAfterGetRecord()
            begin
                Window.Update(2, Item."No." + ' - ' + Item.Description);
                Window.Update(3, 'Checking cost adjustments (1/8)');
                //Check and confirm that adjustment has been run for items in the set range
                AvgCostAdjustmentEntryPoints.SetRange("Item No.", Item."No.");
                AvgCostAdjustmentEntryPoints.SetRange("Valuation Date", StartingDate, EndingDate);
                AvgCostAdjustmentEntryPoints.SetRange("Cost Is Adjusted", false);
                if AvgCostAdjustmentEntryPoints.Find('-') then
                    Error('Please run cost adjustment for item %1', Item."No.");

                PostValueEntryToGl.SetRange("Item No.", Item."No.");
                PostValueEntryToGl.SetRange("Posting Date", StartingDate, EndingDate);
                if PostValueEntryToGl.Find('-') then
                    Error('Please run "Post Inventory Costs to G/L" for item %1 to and including date %2', Item."No.", EndingDate);

                StartingILENumber := 0;
                StartingVENumber := 0;
                ILE.SetCurrentKey("Entry No.");
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                if ILE.FindFirst() then
                    StartingILENumber := ILE."Entry No.";

                VE.SetCurrentKey("Entry No.");
                VE.SetRange("Item No.", Item."No.");
                VE.SetFilter("Posting Date", '<=%1', EndingDate);
                if VE.FindFirst() then
                    StartingVENumber := VE."Entry No.";

                Window.Update(3, 'Generating Quantity on Hand (2/8)');
                Clear(GenerateQoHRpt);
                GenerateQoHRpt.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                GenerateQoHRpt.SetTableView(ILE);
                GenerateQoHRpt.SetRunParameters(EndingDate, false);
                GenerateQoHRpt.UseRequestPage := false;
                GenerateQoHRpt.RunModal();

                Window.Update(3, 'Deleting Item Ledger and Value Entries (3/8)');
                Clear(RptDeleteILEandVLE);
                RptDeleteILEandVLE.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                RptDeleteILEandVLE.SetTableView(ILE);
                RptDeleteILEandVLE.SetRunParameters(EndingDate, false);
                RptDeleteILEandVLE.UseRequestPage := false;
                RptDeleteILEandVLE.RunModal();

                Window.Update(3, 'Create Missing Item Ledger Entries (4/8)');
                Clear(RptCreateMissingILEs);
                RptCreateMissingILEs.SetTableView(Item);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                RptCreateMissingILEs.SetTableView(ILE);
                RptCreateMissingILEs.SetRunParameters(EndingDate, false);
                RptCreateMissingILEs.UseRequestPage := false;
                RptCreateMissingILEs.RunModal();

                Window.Update(3, 'Create Item Ledger Entries using Quantity on Hand (5/8)');
                Clear(RptCrateILEEntriesUsingQoH);
                QoH.SetRange("Item No.", Item."No.");
                RptCrateILEEntriesUsingQoH.SetTableView(QoH);
                RptCrateILEEntriesUsingQoH.SetRunParameters(StartingILENumber, StartingVENumber, EndingDate, false);
                RptCrateILEEntriesUsingQoH.UseRequestPage := false;
                RptCrateILEEntriesUsingQoH.RunModal();

                Window.Update(3, 'Delete Orphan Item Application Entries (6/8)');
                Clear(RptDeleteOrphanItemApplEntry);
                ItemApplicationEntry.SetRange("Item No.", Item."No.");
                ItemApplicationEntry.SetFilter("Posting Date", '<=%1', EndingDate);
                RptDeleteOrphanItemApplEntry.SetTableView(ItemApplicationEntry);
                RptDeleteOrphanItemApplEntry.SetRunParameters(EndingDate, false);
                RptDeleteOrphanItemApplEntry.UseRequestPage := false;
                RptDeleteOrphanItemApplEntry.RunModal();

                Window.Update(3, 'Create Item Application (7/8)');
                Clear(RptCreateItemApplication);
                ILE.SetRange("Item No.", Item."No.");
                ILE.SetFilter("Posting Date", '<=%1', EndingDate);
                RptCreateItemApplication.SetTableView(ILE);
                RptCreateItemApplication.SetRunParameters(EndingDate, false);
                RptCreateItemApplication.UseRequestPage := false;
                RptCreateItemApplication.RunModal();

                Item."Cost is Adjusted" := false;
                Item.Modify();
            end;

            trigger OnPostDataItem()
            begin
                Window.Update(1, '');

                Window.Update(3, 'Compress Related Tables (8/8)');
                RptCompressAdditionalTablesRec.SetRunParameters(EndingDate, false);
                RptCompressAdditionalTablesRec.UseRequestPage := false;
                RptCompressAdditionalTablesRec.RunModal();

                Message('Item Ledger Compression Completed Successfully!\Start Time: %1 End Time: %2', StartTime, TIME);
                Window.Close();
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
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
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
        if ILECompressionSetup.Get() and (Format(ILECompressionSetup."Cut-off Period") <> '') then
            EndingDate := CalcDate(ILECompressionSetup."Cut-off Period", Today)
        else
            EndingDate := CalcDate('-7Y', Today);
    end;

    var
        ILECompressionSetup: Record "AQD ILE Compression Setup";
        StartingILENumber: Integer;
        StartingVENumber: Integer;
        ILE: Record "Item Ledger Entry";
        VE: Record "Value Entry";
        GenerateQoHRpt: Report "Generate Quantity On Hand";
        AvgCostAdjustmentEntryPoints: Record "Avg. Cost Adjmt. Entry Point";
        PostValueEntryToGl: Record "Post Value Entry to G/L";
        RptDeleteILEandVLE: Report "Delete ILE and VLE";
        RptCreateMissingILEs: Report "Create Missing ILEs";
        RptCrateILEEntriesUsingQoH: Report "Create ILE Entries using QoH";
        RptDeleteOrphanItemApplEntry: Report "Delete Orphan Item Appl. Entry";
        RptCompressAdditionalTablesRec: Report "Compress Additional Tables Rec";
        RptCreateItemApplication: Report "Create Item Application";
        RptOpenAllItemsForAdjustment: Report "Open All Items for Adjustment";
        StartTime: Time;
        QoH: Record "AQD Quantity on Hand";
        ItemApplicationEntry: Record "Item Application Entry";
        StartingDate: Date;
        EndingDate: Date;
        Window: Dialog;
        Txt000: Label 'Compressing Item Ledger Entries\Period: #1#####\Processing Item: #2#####\Status: #3#####';
}
