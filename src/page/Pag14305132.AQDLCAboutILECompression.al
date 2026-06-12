page 14305132 "AQDLC About ILE Compression"
{
    ApplicationArea = All;
    Caption = 'About Acumens Item Ledger Compression';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(Version)
            {
                field(Version1; AQDICVersion)
                {
                    Caption = '';
                }
            }
            group("About the App")
            {
                field(AboutTheApp; AboutTheApp)
                {
                    Caption = '';
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                }

            }
            group("Key Features")
            {
                Caption = 'Features';
                field("ILE Compression"; 'Item Ledger Compression')
                {
                    Caption = '';
                    Style = Strong;
                }
                field("ILE Compression Description"; AboutILECompression)
                {
                    Caption = '';
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                }


            }
            group(CopyRightInfo)
            {
                ShowCaption = false;
                field(i; CopyRightInfo)
                {
                    Caption = '';
                }
            }
            group(BC)
            {
                Caption = 'Dynamics 365 Business Central / NAV';
                field(BCVersion; BCVersion)
                {
                    Caption = 'Version';
                }
                field(BCBuildVersion; BCBuildVersion)
                {
                    Caption = 'Build';
                }
                field(BCPlatform; BCPlatform)
                {
                    Caption = 'Platform';
                }
                field(BCApplicationBuild; BCApplicationBuild)
                {
                    Caption = 'Application';
                }

            }
        }
    }
    var
        AQDICVersion: Text;
        BCVersion: Text;
        AppSysConstants: Codeunit "Application System Constants";
        ModuleInfo: ModuleInfo;
        CopyRightInfo: Text;
        BCBuildVersion: Text;
        BCApplicationBuild: Text;
        BCBuildBranch: Text;
        BCPlatform: Text;
        BCPlatformFile: Text;
        AboutTheApp: Text;
        AboutILECompression: Text;

    trigger OnOpenPage()
    begin
        UpdatePageData();
    end;

    procedure UpdatePageData()
    begin
        BCVersion := AppSysConstants.ApplicationVersion();
        BCApplicationBuild := AppSysConstants.ApplicationBuild();
        BCBuildVersion := AppSysConstants.ApplicationBuild();
        //BCBuildBranch := AppSysConstants.BuildBranch();
        BCPlatform := AppSysConstants.PlatformProductVersion();
        //BCPlatformFile := AppSysConstants.PlatformFileVersion();

        AQDICVersion := GetMyExtensionVersion();

        CopyRightInfo := GetCopyrightNotice();

        //About texts
        AboutTheApp := 'Acumens Item Ledger Compression streamlines the management and optimization of Item Ledger Entries in Microsoft Dynamics 365 Business Central. The app enables controlled compression of historical inventory entries based on configurable rules such as date cut-offs, item filters, and batch parameters, helping organizations reduce database size, improve system performance, and maintain data integrity. It provides structured logging, execution tracking, and error handling to ensure transparency and reliability during compression processes, ultimately enhancing system efficiency and long-term maintainability of inventory data.';
        AboutILECompression := 'Allows you to compress Item Ledger Entries as per schedules and cut-off dates, helping reduce database size, improve system performance, and maintain efficient inventory data management with full traceability.';
    end;

    procedure GetMyExtensionVersion(): Text
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        exit(Format(ModuleInfo.AppVersion));
    end;

    procedure GetCopyrightNotice(): Text
    var
        CurrentYear: Integer;
    begin
        CurrentYear := Date2DMY(Today, 3);
        if CurrentYear <> CurrentYear then
            exit(StrSubstNo('© 2025-%1 SBC Dynamics ERP', CurrentYear))
        else
            exit(StrSubstNo('© %1 SBC Dynamics ERP', CurrentYear));
    end;

    procedure BuildFileVersion() BuildFileVersion: Text[248];
    var
        thisModule: ModuleInfo;
        completeVersion: Version;
    begin
        // Will return a string similar to '14.2.12345.12349'
        NavApp.GetCurrentModuleInfo(thisModule);
        completeVersion := thisModule.AppVersion;

        BuildFileVersion := CopyStr(Format(completeVersion), 1, MaxStrLen(BuildFileVersion));
    end;
}