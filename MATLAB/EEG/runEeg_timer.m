%run this function to connect and plot raw EEG data
%make sure to change portnum1 to the appropriate COM port
clear all
close all

addpath('C:\Users\anapa\Documents\TEST')

main_data = table(); %data as empty table

%%

portnum1 =      3;      %COM port#
comPortName1 =  sprintf('\\\\.\\COM%d', portnum1);

TG_BAUD_57600 = 57600;
TG_STREAM_PACKETS =       0;

%data type that can be requested from TG_GetValue().
TG_DATA_RAW =             4;
TG_DATA_POOR_SIGNAL =     1;
TG_DATA_ATTENTION =       2;
TG_DATA_MEDITATION =      3;
TG_DATA_DELTA =           5; 
TG_DATA_THETA =           6;
TG_DATA_ALPHA1 =          7;
TG_DATA_ALPHA2 =          8;
TG_DATA_BETA1 =           9;
TG_DATA_BETA2 =          10;
TG_DATA_GAMMA1 =         11;
TG_DATA_GAMMA2 =         12;
TG_DATA_BLINK_STRENGTH = 37;

%load thinkgear dll
loadlibrary('thinkgear.dll');
fprintf('thinkgear.dll loaded\n');

%get dll version
%dllVersion = calllib('thinkgear', 'TG_GetVersion');
%fprintf('thinkgear DLL version: %d\n', dllVersion );

%%
%get a connection ID handle to thinkgear
connectionId1 = calllib('thinkgear', 'TG_GetNewConnectionId');
if ( connectionId1 < 0 )
    error ('ERROR: TG_GetNewConnectionId() returned %d.\n', connectionId1)
end

%set/open stream (raw bytes) log file for connection
errCode = calllib('thinkgear', 'TG_SetStreamLog', connectionId1, 'streamLog.txt' )
if( errCode < 0 )
    error( 'ERROR: TG_SetStreamLog() returned %d.\n', errCode )
end

%set/open data (thinkgear values) log file for connection
errCode = calllib('thinkgear', 'TG_SetDataLog', connectionId1, 'dataLog.txt' );
if( errCode < 0 )
    error( 'ERROR: TG_SetDataLog() returned %d.\n', errCode );
end

%enable Blink Detection
%errCode = calllib('thinkgear', 'TG_EnableBlinkDetection', connectionId1, 1);
%if( errCode < 0 )
%    error( 'ERROR: TG_EnableBlinkDetection() returned %d.\n', errCode );
%end

%attempt to connect the connection ID handle to serial port "COM3"
errCode = calllib('thinkgear', 'TG_Connect',  connectionId1,comPortName1,TG_BAUD_57600,TG_STREAM_PACKETS);
if ( errCode < 0 )
    error( 'ERROR: TG_Connect() returned %d.\n', errCode);
end

fprintf( 'Connected.  Reading Packets...\n' );

%%
%record data
j = 0;
i = 0;
z = 0;
data = table();
while (i < 1000) %46080
    if (calllib('thinkgear','TG_ReadPackets',connectionId1,1) == 1) 
        
        if (calllib('thinkgear','TG_GetValueStatus',connectionId1,TG_DATA_RAW) ~= 0) 
            j = j + 1;
            i = i + 1;
            
            if(i == 1)
                tic;
                data.time = 0;   %output time as 0 when first started
            else
                data.time = toc; %output time since tic
            end
            
            z = z+1;
            
            %raw data
            data.raw = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_RAW));
            %signal clarity
            data.poorsig = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_POOR_SIGNAL));
            %attention level
            data.atten = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_ATTENTION));
            %mediditation level
            data.medit = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_MEDITATION));
            %delta
            data.delta = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_DELTA));
            %theta
            data.theta = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_THETA));
            %low alpha
            deta.low_alpha = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_ALPHA1));
            %high alpha
            data.high_alpha = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_ALPHA2));
            %low beta
            data.low_beta = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_BETA1));
            %high beta
            data.high_beta = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_BETA2));
            %low gamma
            data.low_gamma = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_GAMMA1));
            %high gamma
            data.high_gamma = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_GAMMA2));
            %blink strength
            data.blink = int16(calllib('thinkgear','TG_GetValue',connectionId1,TG_DATA_BLINK_STRENGTH));
            %get current date
            data.date = datenum(datetime('today'));
            %hour
            data.hour = int16(hour(datetime('now')));
            %minuts
            data.minute = int16(minute(datetime('now')));
            %seconds
            data.seconds = int64(second(datetime('now')));
            %seconds loop
            data.seconds_loop = z;
            % close
            main_data = [main_data;data]
        end
    end
end


%disconnect             
calllib('thinkgear', 'TG_FreeConnection', connectionId1 );


