%% RUN impedance_check.m first before running this %%
%% START THE SIMULINK FILE
surface_area1 =  6.1871; 
% surface_area2 = 4.5616; % subcortical
surface_area2 = surface_area1;
% gEstimPRO_ParameterUpdate(stimbox1, 'Resulting electrode surface area', 6)
% gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 90)
stimbox1 = 'ES-2020.04.02';
% StimLogViewer
%% select stimulation pair map
fnames = dir('stimulation_channel_map\*.m');
listdlg('ListString', {fnames.name},'ListSize', [300, 300],'SelectionMode', 'single')
run (fullfile(fnames(ans).folder, fnames(ans).name))


%% Activate EstimPro
gEstimPRO_ParameterUpdate(stimbox1, 'Active Stop', 'Active')
fprintf('Activated \n');


%% Stimulate for the safety test
% load stim pairs from "stimulation_channel_map.m"
target_freq = 100; % Hz
for i = 1 :size(stim_pair,1)
    % Set stimulation pair from this
    su.ClearStimulationSettingList();
    su.AddStimulationSetting(stim_pair{i,1},stim_pair{i,2}); % order is + and -
    su.GetStimulationSettingList();
    % Set Switching Unit ACTIVE
    pause(0.2)
    su.SetState(su.States.PREPARED);
    pause(1)
    su.SetState(su.States.ACTIVE);
    su.GetState();

    for amp = [1 3 6]%[0.5 1 2 3 4 5 6]
        pause(1);
        fprintf('Current Amp: %.1fmA\n',amp)
        gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', amp) % mA
        gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 90 ) % us
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
        gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
        pause(0.5)
        gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1*target_freq) % 1s
        pause(0.5)
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
        pause(4)
        fprintf('%.1fmA 1s stim is finished \n',amp)
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')

        pause(0.5)
        gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 5*target_freq) % 5s
        pause(0.5)
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
        pause(8);
        fprintf('%.1fmA 5s stim is finished \n',amp)
    end
    % Get back to READY state
    su.SetState(su.States.READY);
    su.ClearStimulationSettingList();
    su.GetState();
    fprintf('Press any key to continue \n')
    pause;
end


%% Stimulate for just stim.
% specify stim pair directly from here
target_amp = 1; % mA
target_time = 5; % sec % time*freq <=30000. max time is 220s
target_freq = 130; % Hz
phase_duration = 90; % us
stim_anode = 129; % this can be array like [1,2,3];
stim_cathode = 130;
su.ClearStimulationSettingList();
su.AddStimulationSetting(stim_anode,stim_cathode);
pause(0.1)
su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();

gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time) % deciding train time
pause(1)
time = fix(clock);
diary(sprintf('logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('stim +%s -%s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration) % us
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 10000) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
pause(target_time);
time = fix(clock);
fprintf('stim +%s -%s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

diary off

% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
%% SHAM
% specify stim pair directly from here
target_amp = 0.05; % mA
target_time = 5; % sec
target_freq = 130; % Hz-
stim_anode = 1; % this can be array like [1,2,3];
stim_cathode = 2;
su.ClearStimulationSettingList();
su.AddStimulationSetting(stim_anode,stim_cathode);
su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();

time = fix(clock);
diary(sprintf('logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('SHAM stim +%d -%d %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', stim_anode,stim_cathode,target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time) % deciding train time
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 90) % us
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 500) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
pause(target_time);
time = fix(clock);
fprintf('SHAM stim +%d -%d %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', stim_anode,stim_cathode,target_amp,target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

diary off

% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();

%% CCEP (120s 6mA 4s interval +- 1)
ccep_target_amp = 6; % mA
ccep_stim_anode = 1;
ccep_stim_cathode = 2;
target_freq = 1; % Hz
a = 2; % lower bound between ccep interval
b = 3; % upper bound

time = fix(clock);
diary(sprintf('logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
su.ClearStimulationSettingList();
su.AddStimulationSetting(ccep_stim_anode,ccep_stim_cathode);
su.GetStimulationSettingList();
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();
time = fix(clock);
diary(sprintf('logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', 1) % Hz
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 100)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Interphase duration', 0)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')

for i = 1 : 5
    tic
    randomNumber = (a + (b-a) * rand); % 0.2-0.3
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec'
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(randomNumber)
    toc
end
time = fix(clock);
fprintf('CCEP +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))

diary off

%% INTERLEAVE CCEP
%% INTERLEAVE CCEP
%% INTERLEAVE CCEP - REMEMBER to CHANGE 4800HZ and GND
%% Target evaluation - structured, and will send Events (same function as digital input) 
% connect to BCI2000 
t = tcpclient('localhost',3999);
fopen(t);
%%
% configuration
ccep_target_amp = 0.1; % mA
ccep_stim_anode = 129;
ccep_stim_cathode = 130;

target_amp = 0.1; % mA
target_time = 5; % sec  .. 
% if you put 300, it will run 150 s twice. Also, if you uncomment the part
% up to 8 then it will run for 1200 s although the target time is 300!
target_freq = 130; % Hz
phase_duration = 60; % us
stim_anode = 129; % this can be array like [1,2,3];
stim_cathode = 130;

a = 2; % lower bound between ccep interval
b = 3; % upper bound

% ccep
pause(1)
fprintf('\r\n\r\n    START BASELINE CCEP    \r\n\r\n');
su.ClearStimulationSettingList();
pause(1)
su.AddStimulationSetting(ccep_stim_anode,ccep_stim_cathode);
fprintf('\r\n\r\n    PRESS SPACE    \r\n\r\n');
pause
su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();
time = fix(clock);
diary(sprintf('logs/stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', 1) % Hz
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 100)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Interphase duration', 0)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
for i = 1 : 5
    tic
    randomNumber = (a + (b-a) * rand); % 2-3
    t.writeline('Pulse event stimtest 1\r\n');    
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec'
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(randomNumber)
    toc
end
time = fix(clock);
fprintf('CCEP +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
fprintf('\r\n\r\n    CCEP FINISHED    \r\n\r\n');

% stim
su.ClearStimulationSettingList();
pause(1)
su.AddStimulationSetting(stim_anode,stim_cathode);
fprintf('\r\n\r\n    PRESS SPACE    \r\n\r\n');
% pause

su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();
if target_time == 300
    gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time/2) % deciding train time
else
    gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time) % deciding train time
end
pause(1)
time = fix(clock);
diary(sprintf('logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('stim +%s -%s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration);
% gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
% gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 100) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
pause % Before stim
fprintf('\r\n\r\n    STIM STARTED    \r\n\r\n');
t.writeline('Pulse event stimtest 2\r\n')
if target_time == 300
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % 1
    pause(target_time/2);
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 2
    pause(0.1);
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    pause(target_time/2);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 3
    % pause(0.1);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    % pause(target_time/2);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 4
    % pause(0.1);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    % pause(target_time/2);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 5
    % pause(0.1);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    % pause(target_time/2);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 6
    % pause(0.1);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    % pause(target_time/2);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 7
    % pause(0.1);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    % pause(target_time/2);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 8
    % pause(0.1);
    % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    % pause(target_time/2);
else
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    pause(target_time);
end
time = fix(clock);
fprintf('stim +%s -%s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
fprintf('\r\n\r\n    STIM FINISHED    \r\n\r\n');
fprintf('\r\n\r\n    PRESS SPACE    \r\n\r\n');
% pause

% ccep
fprintf('\r\n\r\n    START CCEP    \r\n\r\n');
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
pause(0.1)
su.AddStimulationSetting(ccep_stim_anode,ccep_stim_cathode);
% Set Switching Unit ACTIVE
pause(0.1)
su.SetState(su.States.PREPARED);
pause(0.1)
su.SetState(su.States.ACTIVE);
su.GetState();
pause(0.1)
su.GetStimulationSettingList();

gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
pause(0.1);
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', 1) % Hz
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 100)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Interphase duration', 0)

time = fix(clock);
diary(sprintf('logs/stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))

gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
pause(0.1)

pause % before starting CCEPs
for i = 1 : 5
    tic
    randomNumber = (a + (b-a) * rand); % 0.2-0.3
    t.writeline('Pulse event stimtest 1\r\n');
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec'
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(randomNumber)
    toc
end

time = fix(clock);
fprintf('CCEP +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
fprintf('\r\n\r\n    CCEP FINISHED    \r\n\r\n');

diary off
%% close connection to BCI
clear t
echotcpip("off")

%% TARGET EVALUATION
%% TARGET EVALUATION
%% TARGET EVALUATION
%% Target evaluation - structured, and will send Events (same function as digital input) 
% connect to BCI2000 
t = tcpclient('localhost',3999);
fopen(t);
%% and set the stimulation parameters
target_time = 150; % sec. Stimulation duration
prestim_recording_time = 10; % sec
poststim_recording_time = 10; % sec
%% select stimulation pair map
fnames = dir('stimulation_channel_map\*.m');
listdlg('ListString', {fnames.name},'ListSize', [300, 300],'SelectionMode', 'single')
run (fullfile(fnames(ans).folder, fnames(ans).name))
%% for-loop of stimulation pairs
time = fix(clock);
%diary(sprintf('logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
for i = 1:size(stim_pair,1)

    % Print and pause
    fprintf('stim +%s -%s %.2f mA %d Hz - for %d sec at %d/%d/%d %d:%d:%d\n',  num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
    fprintf('\r\n\r\n    PRESS SPACE    \r\n\r\n');
    pause

    % 1. Prestim useful data period
    fprintf('\r\n\r\n    START TRIAL    \r\n\r\n');
    t.writeline('Pulse event stimtest 1\r\n');
    fprintf('prestim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause(prestim_recording_time);

    % 2. Switching on
    t.writeline('Pulse event stimtest 2\r\n');
    su.ClearStimulationSettingList();
    su.AddStimulationSetting(stim_pair{i,1},stim_pair{i,2}); % order is + and -
    su.GetStimulationSettingList();
    % Set Switching Unit ACTIVE
    pause(0.2)
    su.SetState(su.States.PREPARED);
    pause(1)
    su.SetState(su.States.ACTIVE);
    su.GetState();
    pause(1); % wait until switiching artifact is eliminated

    % 3. Deliver stimulation
    time = fix(clock);
    if stim_pair{i,5} == 0 % STIM
        fprintf('stim +%s -%s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n',  num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
        gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', stim_pair{i,3}*target_time) % deciding train time
        pause(1)
        gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', stim_pair{i,4}) %
        gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 60) % us
        gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', stim_pair{i,3}) % Hz
        gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
        gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 500) % msec
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
        pause(0.1)
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
        pause(target_time);
        time = fix(clock);
        fprintf('stim +%s -%s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
    elseif stim_pair{i,5} == 1 % SHAM
        fprintf('stim +%s -%s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n',  num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
        gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', stim_pair{i,3}*target_time) % deciding train time
        pause(1)
        gEstimPRO_ParameterUpdate(stimbox2, 'Phase Amplitude', 0.05) %
        gEstimPRO_ParameterUpdate(stimbox2, 'Phase Duration', 90) % us
        gEstimPRO_ParameterUpdate(stimbox2, 'Pulse rate', stim_pair{i,3}) % Hz
        gEstimPRO_ParameterUpdate(stimbox2, 'Fade type', 'AMPLITUDE')
        gEstimPRO_ParameterUpdate(stimbox2, 'Fade-in time', 500) % msec
        gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
        pause(0.1)
        gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
        pause(target_time);
        time = fix(clock);
        fprintf('stim +%s -%s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
    end
    % 4. Switching off
    su.SetState(su.States.READY);
    su.ClearStimulationSettingList();
    su.GetState();
    pause(5)
    % 5. Poststim useful data period
    t.writeline('Pulse event stimtest 3\r\n');
    fprintf('poststim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause(poststim_recording_time);

    % 6. Intertrial interval
    t.writeline('Pulse event stimtest 4\r\n');
    fprintf('\r\n\r\n    END OF TRIAL / PLEASE ASK RATING   \r\n\r\n');
    fprintf('Press any key to continue  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause;
end
diary off
%% close connection to BCI
clear t
echotcpip("off")