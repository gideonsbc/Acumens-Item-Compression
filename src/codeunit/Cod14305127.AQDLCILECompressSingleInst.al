codeunit 14305127 "AQDLC ILE Compress Single Inst"
{
    SingleInstance = true;

    var
        ILECompressionTask: Text;

    procedure SetILECompressionTask(vILECompressionTask: Text)
    begin
        ILECompressionTask := vILECompressionTask;
    end;

    procedure GetILECompressionTask(var vILECompressionTask: Text)
    begin
        vILECompressionTask := ILECompressionTask;
    end;

    var
        EndingDate: Date;
        RegNo: Integer;
        CalledFromRegisterNo: Integer;
        ScheduleDescription: Text;
        PostingDateRunNo: Integer;

    procedure SetILECompressionParams(vEndingDate: Date; vPostingDateRunNo: Integer; vRegNo: Integer; vCalledFromRegisterNo: Integer; vScheduleDescription: Text)
    begin
        EndingDate := vEndingDate;
        PostingDateRunNo := vPostingDateRunNo;
        RegNo := vRegNo;
        CalledFromRegisterNo := vCalledFromRegisterNo;
        ScheduleDescription := vScheduleDescription;
    end;



    procedure GetILECompressionParams(var vEndingDate: Date; var vPostingDateRunNo: Integer; var vRegNo: Integer; var vCalledFromRegisterNo: Integer; var vScheduleDescription: Text)
    begin
        vEndingDate := EndingDate;
        vPostingDateRunNo := PostingDateRunNo;
        vRegNo := RegNo;
        vCalledFromRegisterNo := CalledFromRegisterNo;
        vScheduleDescription := ScheduleDescription;
    end;

    var
        VEDeleteCount: Integer;

    procedure SetVEDeleteCount(vVEDeleteCount: Integer)
    begin
        VEDeleteCount := vVEDeleteCount;
    end;

    procedure IncrementVEDeleteCount()
    begin
        VEDeleteCount += 1;
    end;

    procedure GetVEDeleteCount(var vVEDeleteCount: Integer)
    begin
        vVEDeleteCount := VEDeleteCount;
    end;

    var
        VEsFilterText: Text;
        VEDeleteCounter: Integer;

    procedure ResetVEDeleteFilter()
    begin
        Clear(VEsFilterText);
        Clear(VEDeleteCounter);
    end;

    procedure UpdateVEDeleteFilter(VeNo: Integer)
    begin
        VEDeleteCounter += 1;
        if VEsFilterText = '' then
            VEsFilterText := Format(VeNo)
        else
            VEsFilterText += '|' + Format(VeNo);
    end;

    procedure GetVEDeleteFilter(var vVEsFilterText: Text; var vVEDeleteCounter: Integer)
    begin
        vVEsFilterText := VEsFilterText;
        vVEDeleteCounter := VEDeleteCounter;
    end;
}
