%% Stimulate for just stim.
% specify stim pair directly from here

target_time = 0.1; % min. Stimulation duration. You can put 0.5, 0.1, .. but if it's more than 1, just 1,2,3,4,... are allowed. not 1.5

target_amp_1 = 1; % mA
target_freq_1 = 130; % Hz-
stim_anode_1 = [1]; % this can be array like [1,2,3];
stim_cathode_1 = [2];
phase_duration_1 = 90;

target_amp_2 = 5; % mA
target_freq_2 = 130; % Hz-
stim_anode_2 = 65; % manually connect this
stim_cathode_2 = 66;
phase_duration_2 = 60;
%%
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();
pause(.3)
su.AddStimulationSetting(stim_anode_1,stim_cathode_1);
su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();

pause(1)
time = fix(clock);
diary(sprintf('../logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));

gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp_1) %
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq_1) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration_1) % us
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec
pause(0.1)

gEstimPRO_ParameterUpdate(stimbox2, 'Phase Amplitude', target_amp_2) % mA
gEstimPRO_ParameterUpdate(stimbox2, 'Pulse rate', target_freq_2) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox2, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox2, 'Phase Duration', phase_duration_2) % us
gEstimPRO_ParameterUpdate(stimbox2, 'Fade-in time', 0) % msec
pause(0.1)


time = fix(clock);
fprintf('stim1 +%s -%s %.2f mA %d Hz started - for %.1f min at %d/%d/%d %d:%d:%d\n', num2str(stim_anode_1),num2str(stim_cathode_1),target_amp_1, target_freq_1, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
fprintf('stim2 +%s -%s %.2f mA %d Hz started - for %.1f min at %d/%d/%d %d:%d:%d\n', num2str(stim_anode_2),num2str(stim_cathode_2),target_amp_2, target_freq_2, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

if target_time < 1
    gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq_1*target_time*60) % deciding train time
    gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', target_freq_2*target_time*60) % deciding train time
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
    pause(target_time*60);
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
else
    gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq_1*1*60) % deciding train time
    gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', target_freq_2*1*60) % deciding train time
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
    pause(0.1)
    gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
    pause(0.1)
    for iteration = 1:target_time
        fprintf('%d/%d min stim is ongoing\r\n',iteration,target_time);
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
        pause(0.1)
        gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
        pause(60)
        gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
        pause(0.1)
        gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
        pause(0.1);
    end
end

time = fix(clock);
fprintf('stim1 +%s -%s %.2f mA %d Hz finished - for %.1f min at %d/%d/%d %d:%d:%d\n', num2str(stim_anode_1),num2str(stim_cathode_1),target_amp_1, target_freq_1, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
fprintf('stim2 +%s -%s %.2f mA %d Hz finished - for %.1f min at %d/%d/%d %d:%d:%d\n', num2str(stim_anode_2),num2str(stim_cathode_2),target_amp_2, target_freq_2, target_time,time(2),time(3),time(1),time(4),time(5),time(6))


diary off

% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();

