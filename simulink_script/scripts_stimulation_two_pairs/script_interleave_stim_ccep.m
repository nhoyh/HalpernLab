%% structured, and will send Events (same function as digital input)
% connect to BCI2000
t = tcpclient('localhost',3999);
fopen(t);
%%
% configuration
prestim_recording_time = 1; % sec
poststim_recording_time = 1; % sec

ccep_target_amp = 6; % mA
ccep_stim_anode = 1;
ccep_stim_cathode = 2;

target_amp = 3; % [mA] put exactly 0.05 for SHAM. It uses Stimulator #2
target_time = 1; % min integer only (1,2,3,....)
target_freq = 130; % Hz
phase_duration = 60; % us
stim_anode = 3; % this can be array like [1,2,3];
stim_cathode = 4;

a = 2; % lower bound between ccep interval
b = 4; % upper bound

%%

% ccep
pause(1)
fprintf('\r\n\r\n    START BASELINE CCEP    \r\n\r\n');
su.ClearStimulationSettingList();
pause(1)
su.AddStimulationSetting(ccep_stim_anode,ccep_stim_cathode);
% fprintf('\r\n\r\n    PRESS SPACE    \r\n\r\n');
% pause
su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(0.1)
su.SetState(su.States.ACTIVE);
pause(3)
su.GetState();
time = fix(clock);
diary(sprintf('../logs/stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', 1) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 100)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Interphase duration', 0)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
for i = 1 : 2
    tic
    randomNumber = (a + (b-a) * rand); % 2-3
    t.writeline('Pulse event stimtest 3\r\n');
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec'
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(randomNumber)
    toc
end
time = fix(clock);
fprintf('CCEP +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
% Get back to READY state
pause(4)
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
fprintf('\r\n\r\n    CCEP FINISHED    \r\n\r\n');

% stim
su.ClearStimulationSettingList();
pause(0.1)
su.AddStimulationSetting(stim_anode,stim_cathode);
su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.1)
su.SetState(su.States.PREPARED);
pause(0.1)
su.SetState(su.States.ACTIVE);
su.GetState();
pause(4)

t.writeline('Pulse event stimtest 5\r\n');
fprintf('prestim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
pause(prestim_recording_time);

t.writeline('Pulse event stimtest 6\r\n');
pause(0.1)
time = fix(clock);
diary(sprintf('../logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));



fprintf('\r\n\r\n    PRESS SPACE to STIM   \r\n\r\n');
pause % Before stim
fprintf('\r\n\r\n    STIM STARTED    \r\n\r\n');
fprintf('stim +%s -%s %.2f mA %d Hz started - for %d min at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

if target_amp ~= 0.05
    gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*1*60) % deciding train time
    pause(1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
    pause(1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration);
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    for iteration = 1:target_time
        fprintf('%d/%d min stim is ongoing\r\n',iteration,target_time);
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
        pause(60)
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
        pause(0.1);
    end
else
    gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', target_freq*1*60) % deciding train time
    pause(1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Phase Amplitude', target_amp) %
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Pulse rate', target_freq) % Hz
    pause(1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Phase Duration', phase_duration);
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
    for iteration = 1:target_time
        fprintf('%d/%d min SHAM is ongoing\r\n',iteration,target_time);
        gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
        pause(60)
        gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
        pause(0.1);
    end

end
time = fix(clock);
fprintf('stim +%s -%s %.2f mA %d Hz finished - for %d min at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
% pause(3);
% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
fprintf('\r\n\r\n    STIM FINISHED    \r\n\r\n');
pause(4)

t.writeline('Pulse event stimtest 7\r\n');
fprintf('poststim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
pause(poststim_recording_time);

t.writeline('Pulse event stimtest 8\r\n');
pause(0.1)
% ccep
fprintf('\r\n\r\n    START CCEP    \r\n\r\n');
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
pause(0.1)
su.AddStimulationSetting(ccep_stim_anode,ccep_stim_cathode);
% Set Switching Unit ACTIVE
pause(2)
su.SetState(su.States.PREPARED);
pause(0.1)
su.SetState(su.States.ACTIVE);
pause(4)
su.GetState();
pause(0.1)
su.GetStimulationSettingList();

gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
pause(0.1);
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', 1) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 100)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Interphase duration', 0)

time = fix(clock);
diary(sprintf('../logs/stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))

gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
pause(0.1)

for i = 1 : 2
    tic
    randomNumber = (a + (b-a) * rand); % 0.2-0.3
    t.writeline('Pulse event stimtest 3\r\n');
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') % takes 1.4sec'
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(randomNumber)
    toc
end

time = fix(clock);
fprintf('CCEP +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
% Get back to READY state
pause(4)
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
fprintf('\r\n\r\n    All Blocks are FINISHED    \r\n\r\n');

diary off
%% close connection to BCI
clear t
echotcpip("off")