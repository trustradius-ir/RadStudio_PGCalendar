//Copyright 2018 © By Alireza Nourbakhsh
//www.sasharadius.ir
//Convert Jalali To Miladi , Miladi To Jalali
//Support Year From 1/1/1 To 9999/12/29
//Support Leap Year Small/Big
unit PGCalendarClass;

interface
uses System.SysUtils;
const
  MiladiDaysInMonth:Array [0..12] of Byte = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  MiladiDaysInMonthLeap:Array [0..12] of Byte = (0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  JalaliDaysInMonth:Array [0..12] of Byte = (0, 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);
  JalaliDaysInMonthLeap:Array [0..12] of Byte = (0, 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30);


  SumMiladiDaysInMonth:Array [0..12] of Word = (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365);
  SumMiladiDaysInMonthLeap:Array [0..12] of Word = (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);
  SumJalaliDaysInMonth:Array [0..12] of Word = (0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 365);
  SumJalaliDaysInMonthLeap:Array [0..12] of Word = (0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 366);

  MaxYear = 9999;
type
  TCalendarType = (ctUseClass,ctMiladi,ctJalali);
  TPGDateTime = record
    DatePart:Integer;
    TimePart:Integer;
  end;
  TPGCalendar = class(TObject)
  private
    CalendarType:TCalendarType;
    function PGConvertDays(Days:Integer;FromCalendarType:TCalendarType = ctUseClass;ToCalendarType:TCalendarType = ctUseClass):Integer;
  public
    constructor Create(DestCalendarType:TCalendarType);
    function GetWeekName(DayInWeek:Integer;ShortName:Boolean = False;OverideCalendarType:TCalendarType = ctUseClass):String;
    function GetMonthName(Month:Integer;ShortName:Boolean = False;OverideCalendarType:TCalendarType = ctUseClass):String;
    function GetHourName(AmPm:Byte;OverideCalendarType:TCalendarType = ctUseClass):String;
    function ISLeapYear(Year:Integer;OverideCalendarType:TCalendarType = ctUseClass):Boolean;
    function PGEncodeDate(Year,Month,Day:Integer;OverideCalendarType:TCalendarType = ctUseClass):Integer;
    procedure PGDecodeDate(Days:Integer;var Year,Month,Day,DayOfWeek,WeekOfYear:Integer;OverideCalendarType:TCalendarType = ctUseClass);
    function PGEncodeTime(Hour,Minute,Second,MiliSecond:Integer):Integer;
    procedure PGDecodeTime(TotalMiliSeconds:Integer;var Hour,Minute,Second,MiliSecond:Integer);
    function FormatPGDateTime(PGDateTime:TPGDateTime;FormatString:String;OverideCalendarType:TCalendarType = ctUseClass):String;
    function PGConvertFromDateTime(SourceTime:TDateTime = 0;OverideCalendarType:TCalendarType = ctUseClass):TPGDateTime;
    function PGConvertToDateTime(SourceTime:TPGDateTime;OverideCalendarType:TCalendarType = ctUseClass):TDateTime;
    function PGTimeCalculate(PGDateTime:TPGDateTime;Year,Month,Day,Hour,Minute,Second,MiliSecond:Integer;OverideCalendarType:TCalendarType = ctUseClass):TPGDateTime;
  end;


implementation

constructor TPGCalendar.Create(DestCalendarType:TCalendarType);
begin
  if (DestCalendarType = ctUseClass) Then raise Exception.Create('Invalid CalendarType');

  CalendarType := DestCalendarType
end;

function TPGCalendar.GetHourName(AmPm:Byte;OverideCalendarType:TCalendarType = ctUseClass):String;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  if OverideCalendarType = ctMiladi then
  begin
    case AmPm of
      1:Result := 'AM';
      2:Result := 'PM';
    end;
  end
  else
  begin
    case AmPm of
      1:Result := 'GZ';
      2:Result := 'BZ';
    end;
  end

end;

function TPGCalendar.GetWeekName(DayInWeek:Integer;ShortName:Boolean = False;OverideCalendarType:TCalendarType = ctUseClass):String;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  if OverideCalendarType = ctMiladi then
  begin
    case DayInWeek of
      0:Result := 'Saturday';
      1:Result := 'Sunday';
      2:Result := 'Monday';
      3:Result := 'Tuesday';
      4:Result := 'Wednesday';
      5:Result := 'Thursday';
      6:Result := 'Friday';
    end;
  end
  else
  begin
    case DayInWeek of
      0:Result := 'Shanbeh';
      1:Result := '1Shanbeh';
      2:Result := '2Shanbeh';
      3:Result := '3Shanbeh';
      4:Result := '4Shanbeh';
      5:Result := '5Shanbeh';
      6:Result := 'Jomeh';
    end;
  end;
  if ShortName then Result := Copy(Result,1,3);
end;

function TPGCalendar.GetMonthName(Month:Integer;ShortName:Boolean = False;OverideCalendarType:TCalendarType = ctUseClass):String;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  if OverideCalendarType = ctMiladi then
  begin
    case Month of
      1:Result := 'January';
      2:Result := 'February';
      3:Result := 'March';
      4:Result := 'April';
      5:Result := 'May';
      6:Result := 'June';
      7:Result := 'July';
      8:Result := 'August';
      9:Result := '	September';
      10:Result := 'October';
      11:Result := 'November';
      12:Result := 'December';
    end;
  end
  else
  begin
    case Month of
      1:Result := 'Farvardin';
      2:Result := 'Ordibehesht';
      3:Result := 'Khordad';
      4:Result := 'Tir';
      5:Result := 'Mordad';
      6:Result := 'Shahrivar';
      7:Result := 'Mehr';
      8:Result := 'Aban';
      9:Result := 'Azar';
      10:Result := 'Dey';
      11:Result := 'Bahman';
      12:Result := 'Esfand';
    end;
  end;
  if ShortName then Result := Copy(Result,1,3);
end;

function TPGCalendar.ISLeapYear(Year:Integer;OverideCalendarType:TCalendarType = ctUseClass):Boolean;
var Leap:Integer;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  Result := False;

  if (Year < 1) Then raise Exception.Create(format('Invalid Year %d',[Year]));

  if OverideCalendarType = ctMiladi  then
    Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));

  if OverideCalendarType = ctJalali  then
  begin
    Result := (Year+11) Mod 33 = 0;
    if Result then Exit;

    Leap := (Year + 11) - 33 * ( (Year + 11) Div 33 );
    if Leap in [4,8,12,16,20,24,28] Then Result := True;
  end;
end;





function TPGCalendar.PGEncodeDate(Year,Month,Day:Integer;OverideCalendarType:TCalendarType = ctUseClass):Integer;
var LeapYearsCount,DaysInMonth:Integer;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  Result := 0;

  if (Year < 1) Then raise Exception.Create(format('Invalid Year %d',[Year]));

  if (Month < 1) OR (Month > 12) Then raise Exception.Create(format('Invalid Month %d',[Month]));

  if OverideCalendarType = ctMiladi then
  begin
    if ISLeapYear(Year,OverideCalendarType) then
      DaysInMonth  := MiladiDaysInMonthLeap[Month]
    else
      DaysInMonth  := MiladiDaysInMonth[Month];
  end
  else
  begin
    if ISLeapYear(Year,OverideCalendarType) then
      DaysInMonth  := JalaliDaysInMonthLeap[Month]
    else
      DaysInMonth  := JalaliDaysInMonth[Month];
  end;

  if (Day < 1) OR (Day > DaysInMonth) Then raise Exception.Create(format('Invalid Day In Month %d/%d/%d',[Year,Month,Day]));


  Year := Year - 1;

  if OverideCalendarType = ctMiladi  then
  begin
    LeapYearsCount := ((Year div 4)-(Year div 100)+(Year div 400));
    Result := (LeapYearsCount * 366) + ((Year - LeapYearsCount) * 365);
    if ISLeapYear(Year+1,OverideCalendarType) then
      Result := Result + SumMiladiDaysInMonthLeap[Month-1]
    else
      Result := Result + SumMiladiDaysInMonth[Month-1];

    Result := Result + Day;
  end;

  if OverideCalendarType = ctJalali  then
  begin
    if Year >= 22 then
    begin
      LeapYearsCount := ((Year+11) Div 33) + ((((Year+11) Div 33) * 7) - 2);
      LeapYearsCount := LeapYearsCount + ((Year - ((33 * ((Year+11) Div 33))-11)) Div 4);
    end
    else
    begin
      LeapYearsCount := (Year+3) Div 4;
    end;
    Result := (LeapYearsCount * 366) + ((Year - LeapYearsCount) * 365);
    if ISLeapYear(Year+1,OverideCalendarType) then
      Result := Result + SumJalaliDaysInMonthLeap[Month-1]
    else
      Result := Result + SumJalaliDaysInMonth[Month-1];

    Result := Result + Day;
    if ((Year+12) Mod 33) = 0 then Dec(Result);
  end;

end;




procedure TPGCalendar.PGDecodeDate(Days:Integer;var Year,Month,Day,DayOfWeek,WeekOfYear:Integer;OverideCalendarType:TCalendarType = ctUseClass);
var Y33,Y4,Y1,MonthL:Integer;
    Y400,Y100:Integer;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  if OverideCalendarType = ctMiladi then
  begin
    DayOfWeek := (Days+1) Mod 7;

    Y400 := Days Div 146097; //(97 * 366) + (303 * 365)
    Days := Days Mod 146097;

    if Days <= 109572 Then
    begin
      Y100 := Days Div 36524; //(24 * 366) + (76 * 365)
      Days := Days Mod 36524;
    end
    else
    begin
      Y100 := 3;
      Days := Days - 109572;
    end;

    Y4 :=  Days Div (1461); //(1 * 366) + (3 * 365)
    Days := Days Mod (1461);

    if Days <= 1095 Then
    begin
      Y1 :=  Days Div (365);
      Days := (Days Mod (365));
    end
    else
    begin
      Y1 := 3;
      Days := Days - 1095;
    end;

    Year := (Y400 * 400)+(Y100 * 100)+(Y4 * 4)+Y1;

    if  (Days > 0)  then
    begin
      Inc(Year) ;
    end
    else
    begin
      if ISLeapYear(Year,OverideCalendarType) then
        Days :=SumMiladiDaysInMonthLeap[12]
      else
        Days :=SumMiladiDaysInMonth[12];
    end;

    WeekOfYear := ((Days) Div 7) + 1;

    for MonthL := 12 downto 1 do
    if ISLeapYear(Year,OverideCalendarType) then
    begin
      if Days > SumMiladiDaysInMonthLeap[MonthL-1] then
      begin
        Days := Days - SumMiladiDaysInMonthLeap[MonthL-1];
        Break;
      end;
    end
    else
    begin
      if Days > SumMiladiDaysInMonth[MonthL-1] then
      begin
        Days := Days - SumMiladiDaysInMonth[MonthL-1];
        Break;
      end;
    end;
    Month := MonthL;
    Day := Days;
  end
  else
  begin
    DayOfWeek := (Days+4) Mod 7;

    Days := Days + (4017); //(2 * 366) + (9 * 365) - Add 11 Year Temporary
    Y33 :=  Days Div (12053); //(8 * 366) + (25 * 365)
    Days := Days Mod (12053);

    if Days <= 10227 Then
    begin
      Y4 :=  Days Div (1461); //(1 * 366) + (3 * 365)
      Days := Days Mod (1461);
    end
    else
    begin
      Y4 := 7;
      Days := Days - 10227;
    end;

    if Days <= 1095 Then
    begin
      Y1 :=  Days Div (365);
      Days := (Days Mod (365));
    end
    else
    begin
      Y1 := 3;
      Days := Days - 1095;
    end;

    Year := ((Y33 * 33)+(Y4 * 4) - 11 ) + Y1;

    if (Days > 365) then
    begin
      Inc(Year);
      Days := Days - 365;
    end;

    if  (Days > 0)  then
    begin
      Inc(Year) ;
    end
    else
    begin
      if ISLeapYear(Year,OverideCalendarType) then
        Days :=SumJalaliDaysInMonthLeap[12]
      else
        Days :=SumJalaliDaysInMonth[12];
    end;

    WeekOfYear := ((Days) Div 7) + 1;

    for MonthL := 12 downto 1 do
    if ISLeapYear(Year,OverideCalendarType) then
    begin
       if Days > SumJalaliDaysInMonthLeap[MonthL-1] then
       begin
         Days := Days - SumJalaliDaysInMonthLeap[MonthL-1];
         Break;
       end;
    end
    else
    begin
       if Days > SumJalaliDaysInMonth[MonthL-1] then
       begin
         Days := Days - SumJalaliDaysInMonth[MonthL-1];
         Break;
       end;
    end;
    Month := MonthL;
    Day := Days;
  end;

end;


function TPGCalendar.FormatPGDateTime(PGDateTime:TPGDateTime;FormatString:String;OverideCalendarType:TCalendarType = ctUseClass):String;
var Year,Month,Day,Hour,Minute,Second,MiliSecond:Integer;
    FIndex:Integer;
    Pattern:String;
    DayOfWeek,WeekOfYear:Integer;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;
  if (PGDateTime.TimePart < 0) OR (PGDateTime.TimePart >= 86400000) Then raise Exception.Create(format('Invalid PGDateTime TimePart %d',[PGDateTime.TimePart]));
  if (PGDateTime.DatePart < 1) Then raise Exception.Create(format('Invalid PGDateTime DatePart %d',[PGDateTime.DatePart]));
  Year := 0;
  Month := 0;
  Day := 0;
  Hour := 0;
  Minute := 0;
  Second := 0;
  MiliSecond := 0;
  PGDecodeDate(PGDateTime.DatePart,Year,Month,Day,DayOfWeek,WeekOfYear,OverideCalendarType);
  PGDecodeTime(PGDateTime.TimePart,Hour,Minute,Second,MiliSecond);
  {
    yy 	= Year last 2 digits
    yyyy 	= Year as 4 digits
    m 	= Month number no-leading 0
    mm 	= Month number as 2 digits
    mmm 	= Month using ShortDayNames (Jan)
    mmmm 	= Month using LongDayNames (January)
    d 	= Day number no-leading 0
    dd 	= Day number as 2 digits
    ddd 	= Day using ShortDayNames (Sun)
    dddd 	= Day using LongDayNames  (Sunday)

    h 	= Hour number no-leading 0
    hh 	= Hour number as 2 digits
    n	= Minute number no-leading 0
    nn 	= Minute number as 2 digits
    s 	= Second number no-leading 0
    ss 	= Second number as 2 digits
    z	= Milli-sec number no-leading 0s
    zzz 	= Milli-sec number as 3 digits
    AmPm 	= Use after h : gives 12 hours + am/pm
  }
  Result := '';
  FIndex := 1;
  while FIndex < Length(FormatString) do
  begin
    if (FormatString[FIndex] = '/') OR (FormatString[FIndex] = ':') OR (FormatString[FIndex] = '.') OR (FormatString[FIndex] = ' ') then
    begin
      //----
      // Date
      //----
      if Copy(Pattern,Length(Pattern)-4,4) = 'yyyy' then
      begin
        Result := Result + Format('%.*d',[4, Year]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-2,2) = 'yy' then
      begin
        Result := Result + Format('%.*d',[2, Year Mod 100]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-4,4) = 'mmmm' then
      begin
        Result := Result + GetMonthName(Month,False,OverideCalendarType);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-3,3) = 'mmm' then
      begin
        Result := Result + GetMonthName(Month,True,OverideCalendarType);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-2,2) = 'mm' then
      begin
        Result := Result + Format('%.*d',[2, Month]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-1,1) = 'm' then
      begin
        Result := Result + Format('%d',[Month]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-4,4) = 'dddd' then
      begin
        Result := Result + GetWeekName(DayOfWeek,False,OverideCalendarType);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-3,3) = 'ddd' then
      begin
        Result := Result + GetWeekName(DayOfWeek,True,OverideCalendarType);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-2,2) = 'dd' then
      begin
        Result := Result + Format('%.*d',[2, Day]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-1,1) = 'd' then
      begin
        Result := Result + Format('%d',[Day]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-2,2) = 'ww' then
      begin
        Result := Result + Format('%.*d',[2, WeekOfYear]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-1,1) = 'w' then
      begin
        Result := Result + Format('%d',[WeekOfYear]);
        Pattern := '';
      end;
      //----
      // Time
      //----

     if Pos('AmPm',FormatString) > 0 then
      begin
        if Hour > 12 then
        begin
          Hour := Hour - 12;
          if Copy(Pattern,Length(Pattern)-4,4) = 'AmPm' then
          begin
            Result := Result + GetHourName(1,OverideCalendarType);
            Pattern := '';
          end;
        end
        else
        begin
          if Copy(Pattern,Length(Pattern)-4,4) = 'AmPm' then
          begin
            Result := Result + GetHourName(2,OverideCalendarType);
            Pattern := '';
          end;
        end;
      end;

      if Copy(Pattern,Length(Pattern)-2,2) = 'hh' then
      begin
        Result := Result + Format('%.*d',[2, Hour]);
        Pattern := '';
      end;

      if Copy(Pattern,Length(Pattern)-1,1) = 'h' then
      begin
        Result := Result + Format('%d',[Hour]);
        Pattern := '';
      end;

      //----
      if Copy(Pattern,Length(Pattern)-2,2) = 'nn' then
      begin
        Result := Result + Format('%.*d',[2, Minute]);
        Pattern := '';
      end;

      if Copy(Pattern,Length(Pattern)-1,1) = 'n' then
      begin
        Result := Result + Format('%d',[Minute]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-2,2) = 'ss' then
      begin
        Result := Result + Format('%.*d',[2, Second]);
        Pattern := '';
      end;

      if Copy(Pattern,Length(Pattern)-1,1) = 's' then
      begin
        Result := Result + Format('%d',[Second]);
        Pattern := '';
      end;
      //----
      if Copy(Pattern,Length(Pattern)-3,3) = 'zzz' then
      begin
        Result := Result + Format('%.*d',[3, MiliSecond]);
        Pattern := '';
      end;

      if Copy(Pattern,Length(Pattern)-1,1) = 'z' then
      begin
        Result := Result + Format('%d',[MiliSecond]);
        Pattern := '';
      end;
      //----
      Result := Result + FormatString[FIndex];
    end
    else
      Pattern := Pattern + FormatString[FIndex];
    Inc(FIndex);
  end;


end;

function TPGCalendar.PGConvertDays(Days:Integer;FromCalendarType:TCalendarType = ctUseClass;ToCalendarType:TCalendarType = ctUseClass):Integer;
begin
  if FromCalendarType = ctUseClass then
    if CalendarType = ctMiladi then FromCalendarType := ctJalali Else  FromCalendarType := ctMiladi;

  if ToCalendarType = ctUseClass then ToCalendarType := CalendarType;

  if (FromCalendarType = ctMiladi) And (ToCalendarType = ctJalali) And (Days < 226894) then
    raise Exception.Create(format('Invalid Date for Convert To Jalali %d',[Days]));

  if (FromCalendarType = ctMiladi) And (ToCalendarType = ctJalali) then Dec(Days,226894);
  if (FromCalendarType = ctJalali) And (ToCalendarType = ctMiladi) then Inc(Days,226894);

  Result := Days;
end;


function TPGCalendar.PGEncodeTime(Hour,Minute,Second,MiliSecond:Integer):Integer;
begin
  if (Hour < 0) OR (Hour > 23) Then raise Exception.Create(format('Invalid Hour (0-23) %d',[Hour]));
  if (Minute < 0) OR (Minute > 59) Then raise Exception.Create(format('Invalid Minute (0-59) %d',[Minute]));
  if (Second < 0) OR (Second > 59) Then raise Exception.Create(format('Invalid Second (0-59) %d',[Second]));
  if (MiliSecond < 0) OR (MiliSecond > 999) Then raise Exception.Create(format('Invalid MiliSecond (0-999) %d',[MiliSecond]));
  Result := (Hour * 3600000);
  Result := Result + Minute * 60000;
  Result := Result + Second * 1000;
  Result := Result + MiliSecond;
end;

procedure TPGCalendar.PGDecodeTime(TotalMiliSeconds:Integer;var Hour,Minute,Second,MiliSecond:Integer);
begin
  if (TotalMiliSeconds > 86400000) Then raise Exception.Create(format('Invalid MiliSeconds Of 24 Hours Time %d',[TotalMiliSeconds]));
  Hour := TotalMiliSeconds Div 3600000;
  TotalMiliSeconds := TotalMiliSeconds Mod 3600000;

  Minute := TotalMiliSeconds Div 60000;
  TotalMiliSeconds := TotalMiliSeconds Mod 60000;

  Second := TotalMiliSeconds Div 1000;
  MiliSecond := TotalMiliSeconds Mod 1000;
end;


function TPGCalendar.PGConvertFromDateTime(SourceTime:TDateTime = 0;OverideCalendarType:TCalendarType = ctUseClass):TPGDateTime;
var Year,Month,Day:Word;
    Hour,Minute,Second,MiliSecond:Word;
    TotalDays:Integer;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;
  if SourceTime = 0 then SourceTime := Now;


  DecodeDate(SourceTime,Year,Month,Day);
  DecodeTime(SourceTime,Hour,Minute,Second,MiliSecond);

  TotalDays := PGEncodeDate(Year,Month,Day,ctMiladi);
  if OverideCalendarType = ctJalali then TotalDays := PGConvertDays(TotalDays,ctMiladi);
  Result.DatePart := TotalDays;
  Result.TimePart := PGEncodeTime(Hour,Minute,Second,MiliSecond);
end;


function TPGCalendar.PGConvertToDateTime(SourceTime:TPGDateTime;OverideCalendarType:TCalendarType = ctUseClass):TDateTime;
var Year,Month,Day,DayOfWeek,WeekOfYear:Integer;
    Hour,Minute,Second,MiliSecond:Integer;
    ET:TDateTime;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;
  if OverideCalendarType = ctJalali then SourceTime.DatePart := PGConvertDays(SourceTime.DatePart,OverideCalendarType,ctMiladi);
  PGDecodeDate(SourceTime.DatePart,Year,Month,Day,DayOfWeek,WeekOfYear,ctMiladi);
  Result := EncodeDate(Year,Month,Day);
  PGDecodeTime(SourceTime.TimePart,Hour,Minute,Second,MiliSecond);
  ET := EncodeTime(Hour,Minute,Second,MiliSecond);
  ReplaceTime(Result,ET);
end;

function TPGCalendar.PGTimeCalculate(PGDateTime:TPGDateTime;Year,Month,Day,Hour,Minute,Second,MiliSecond:Integer;OverideCalendarType:TCalendarType = ctUseClass):TPGDateTime;
var cYear,cMonth,cDay,cDayOfWeek,cWeekOfYear:Integer;
    cHour,cMinute,cSecond,cMiliSecond:Integer;
begin
  if OverideCalendarType = ctUseClass then OverideCalendarType := CalendarType;

  Result.DatePart := PGDateTime.DatePart;
  Result.TimePart := PGDateTime.TimePart;

  if (Hour <> 0) OR (Minute <> 0) OR (Second <> 0) OR (MiliSecond <> 0) then
  begin
    PGDateTime.TimePart := PGDateTime.TimePart + MiliSecond;
    PGDateTime.TimePart := PGDateTime.TimePart + (Second * 1000);
    PGDateTime.TimePart := PGDateTime.TimePart + (Minute * 60000);
    PGDateTime.TimePart := PGDateTime.TimePart + (Hour * 3600000);
    Day := PGDateTime.TimePart Div 86400000;
    PGDateTime.TimePart := PGDateTime.TimePart  Mod 86400000;
    if PGDateTime.TimePart < 0 then
    begin
     Dec(Day);
     PGDateTime.TimePart := 86400000 - (PGDateTime.TimePart * -1);
    end;
    Result.TimePart := PGDateTime.TimePart;
  end;


  if (Year <> 0) OR (Month <> 0) OR (Day <> 0) then
  begin
    //Day
    if Day <> 0 then
      if Day < 0 then Dec(PGDateTime.DatePart,Day * -1) else Inc(PGDateTime.DatePart,Day);
    if PGDateTime.DatePart < 1 then raise Exception.Create(format('Invalid day After Decrease %d',[PGDateTime.DatePart]));

    PGDecodeDate(PGDateTime.DatePart,cYear,cMonth,cDay,cDayOfWeek,cWeekOfYear,OverideCalendarType);

    //Month
    if Month <> 0 then
    begin
      if Month < 0 then Dec(Year,((Month * -1) Div 12)) else Inc(Year,Month Div 12);
      Month := Month Mod 12;
      if Month <> 0 then
      begin
        if Month < 0 then Dec(cMonth,Month * -1) else Inc(cMonth,Month);
        Inc(Year,cMonth Div 13);
        cMonth := (cMonth Mod 13);
        if (Year > 0) Then Inc(cMonth);
      end;
      if cYear > MaxYear then raise Exception.Create(format('Invalid Year After Increase %d',[cYear]));
    end;

    //Year
    if Year <> 0 then
      if Year < 0 then Dec(cYear,Year * -1) else Inc(cYear,Year);

    if cYear < 1 then raise Exception.Create(format('Invalid Year After Decrease %d',[cYear]));
    if cYear > MaxYear then raise Exception.Create(format('Invalid Year After Increase %d',[cYear]));

    //Check Month
    if cDay > 28 then
    begin
      if CalendarType = ctMiladi then
      begin
        if ISLeapYear(cYear,OverideCalendarType) then
        begin
          if cDay > MiladiDaysInMonthLeap[cMonth] Then cDay := MiladiDaysInMonthLeap[cMonth];
        end
        else
        begin
          if cDay > MiladiDaysInMonth[cMonth] Then cDay := MiladiDaysInMonth[cMonth];
        end;
      end
      else
      begin
        if ISLeapYear(cYear,OverideCalendarType) then
        begin
          if cDay > JalaliDaysInMonthLeap[cMonth] Then cDay := JalaliDaysInMonthLeap[cMonth];
        end
        else
        begin
          if cDay > JalaliDaysInMonth[cMonth] Then cDay := JalaliDaysInMonth[cMonth];
        end;
      end;
    end;

    Result.DatePart := PGEncodeDate(cYear,cMonth,cDay,OverideCalendarType);
  end;


end;

end.
