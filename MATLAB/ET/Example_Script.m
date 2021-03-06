%% Generate path to GP3 subfolders
[mainDir,~,~] = fileparts(mfilename('fullpath'));
addpath(genpath(mainDir));

%% Set-up Matlab to GP3 session1 socket
session1_client = ConnectToGP3;

%% Calibration
StartCalibration(session1_client);
fprintf(session1_client, '<GET ID="CALIBRATE_RESULT_SUMMARY" />');
while  session1_client.BytesAvailable > 0
 dataReceived = fscanf(session1_client);
 disp(dataReceived)
end


%% Spawn a second Matlab session2 that records GP3 data to output file
outputFileName = 'example_output_2.txt';
ExecuteRecordGP3Data(session1_client,outputFileName);



%% Experiment (stimuli presentation) goes here

for n = 1:100
    % Adicionar a coluna do tempo em minutos 
    % time_now = [minute(datetime('now')) + " " + second(datetime('now'))]
    % SendMsgToGP3(session1_client, ['time ' num2str([minute(datetime('now')) + " " + second(datetime('now'))])]); %send msg trigger for start of the trial
    SendMsgToGP3(session1_client,['time ' num2str([hour(datetime('now')) + ":" + minute(datetime('now')) + ":" + second(datetime('now')) + " " +  n])]);
    % pause(1);
    % Present a stimuli here
    % SendMsgToGP3(session1_client,['stimuli' num2str(trial_num)]); %send msg trigger for onset of new stimuli
    % pause(2); 
    pause(1)
end


%% Stop collecting data in client2
fprintf('Stop recording\n')
SendMsgToGP3(session1_client,'STOP_EYETRACKER');

%% Clean-up socket
CleanUpSocket(session1_client);
fclose all;
