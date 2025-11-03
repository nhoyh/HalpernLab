% specify stim pair directly from here
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();

target_amp = 0.05; % mA
target_time = 5; % sec % time*freq <=30000. max time is 220s
target_freq = 130; % Hz
phase_duration = 90; % us
stim_anode = [1]; % this can be array like [1,2,3];
stim_cathode = [4];

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
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', target_freq*target_time) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq) % Hz
pause(1)
time = fix(clock);
diary(sprintf('../logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('stim +%s -%s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration) % us
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
pause(target_time);
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
time = fix(clock);
fprintf('stim +%s -%s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),target_amp, target_freq, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

diary off

% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();