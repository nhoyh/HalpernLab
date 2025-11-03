%% RUN impedance_check.m first before running this %%
%% START THE SIMULKINK FILE
surface_area1 =  6.1871; 
surface_area2 = 4.5616; % subcortical
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

    for amp = [0.5 1 2 3 4 5 6]
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
target_amp = 3; % mA
target_time = 180; % sec
target_freq = 130; % Hz
phase_duration = 90; % us
stim_anode = 73; % this can be array like [1,2,3];
stim_cathode = 74;
su.ClearStimulationSettingList();
su.AddStimulationSetting(stim_anode,stim_cathode);
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
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 100) % msec
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
% target_amp = 6; % mA
% target_freq = 1; % Hz
% stim_pair ='1+2-';
%
% time = fix(clock);
% diary(sprintf('logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
% fprintf('CCEP %s %.2f mA %d Hz started - at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp, target_freq,time(2),time(3),time(1),time(4),time(5),time(6))
% gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) % mA
% gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
% gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 200)
% gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
% pause(0.5)
% gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
% for i = 1 :10%: 30
%     gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes almost 0 less than 0
%     gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
%     pause(3 +rand(1)*2) % 1.4+1.6 +0~2
% end
% time = fix(clock);
% fprintf('CCEP %s %.2f mA %d Hz finished - at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp, target_freq,time(2),time(3),time(1),time(4),time(5),time(6))
%
% diary off

%% INTERLEAVE CCEP
%% INTERLEAVE CCEP
%% INTERLEAVE CCEP
%% 15s recording 2min CCEP and 1min stim
% configuration
ccep_target_amp = 6; % mA
ccep_stim_pair ='33+3-';

target_amp = 3; % mA
target_time = 60; % sec
target_freq = 130; % Hz-
stim_pair = '33+3-';

% 15s recording        %%%%%%%%%% 1st round %%%%%%%%%%
time = fix(clock);
diary(sprintf('logs/15s_recording_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('15s recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
pause(15)

% 2min ccep
time = fix(clock);
diary(sprintf('logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP %s %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_pair,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 200)
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
for i = 1 : 30
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(1.6 +rand(1)*2) % 1.4+1.6 +0~2
end
time = fix(clock);
fprintf('CCEP %s %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_pair,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
pause(15)
% 1min stim
time = fix(clock);
diary(sprintf('logs/stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('stim %s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 90)
%gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
%gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 5000) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
pause(target_time);
time = fix(clock);
fprintf('stim %s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp,target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

% 15s recording        %%%%%%%%%% 2nd round %%%%%%%%%%
time = fix(clock);
diary(sprintf('logs/15s_recording_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('15s recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
pause(15)

% 2min ccep
time = fix(clock);
diary(sprintf('logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP %s %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_pair,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 200)
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
for i = 1 : 30
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(1.6 +rand(1)*2) % 1.4+1.6 +0~2
end
time = fix(clock);
fprintf('CCEP %s %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_pair,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
pause(15)
% 1min stim
time = fix(clock);
diary(sprintf('logs/stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('stim %s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 90)
%gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
%gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 5000) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
pause(target_time);
time = fix(clock);
fprintf('stim %s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp,target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

% 15s recording        %%%%%%%%%% 3rd round %%%%%%%%%%
time = fix(clock);
diary(sprintf('logs/15s_recording_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('15s recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
pause(15)

% 2min ccep
time = fix(clock);
diary(sprintf('logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP %s %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_pair,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 200)
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
for i = 1 : 30
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(1.6 +rand(1)*2) % 1.4+1.6 +0~2
end
time = fix(clock);
fprintf('CCEP %s %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_pair,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))

diary off

%% TARGET EVALUATION
%% TARGET EVALUATION
%% TARGET EVALUATION
%% Target evaluation - structured, and will send Events (same function as digital input) 
% connect to BCI2000 
t = tcpclient('localhost',3999);
fopen(t);
%% and set the stimulation parameters
target_time = 60; % sec. Stimulation duration
prestim_recording_time = 5; % sec
poststim_recording_time = 5; % sec
%% select stimulation pair map
fnames = dir('stimulation_channel_map\*.m');
listdlg('ListString', {fnames.name},'ListSize', [300, 300],'SelectionMode', 'single')
run (fullfile(fnames(ans).folder, fnames(ans).name))
%% for-loop of stimulation pairs
time = fix(clock);
%diary(sprintf('logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
for i = size(stim_pair,1)
    % 1. Prestim useful data period 
    fprintf('\r\n\r\n    START TRIAL    \r\n\r\n');
    fprintf(t,'Pulse event stimtest 1 \r\n');
    fprintf('prestim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause(prestim_recording_time);

    % 2. Switching on2
    fprintf(t,'Pulse event stimtest 2 \r\n');
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
    fprintf(t,'Pulse event stimtest 3 \r\n');
    fprintf('poststim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause(poststim_recording_time);

    % 6. Intertrial interval
    fprintf(t,'Pulse event stimtest 4 \r\n');
    fprintf('\r\n\r\n    END OF TRIAL / PLEASE ASK RATING   \r\n\r\n');
    fprintf('Press any key to continue  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause;
end
diary off
%% close connection to BCI
clear t
echotcpip("off")