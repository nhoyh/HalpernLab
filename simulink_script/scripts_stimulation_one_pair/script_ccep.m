%% CCEP (120s 6mA 4s interval +- 1)

su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();

ccep_target_amp = 6; % mA
ccep_stim_anode = 3;
ccep_stim_cathode = 4;
target_freq = 1; % Hz
a = 2; % lower bound between ccep interval
b = 2.5; % upper bound
reps = 10; % number of speps to deliver

time = fix(clock);
diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
su.ClearStimulationSettingList();
su.AddStimulationSetting(ccep_stim_anode,ccep_stim_cathode);
su.GetStimulationSettingList();
pause(0.2)
su.SetState(su.States.PREPARED); % makes artifact
pause(0.1)
su.SetState(su.States.ACTIVE); % makes artifact
pause(4)
su.GetState();
time = fix(clock);
diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('CCEP +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', ccep_stim_anode,ccep_stim_cathode,ccep_target_amp,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 1) % deciding train time
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', ccep_target_amp) % mA
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', 1) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', 100)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Interphase duration', 0)
pause(.1)
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
for i = 1 : reps
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

pause(5)
su.SetState(su.States.READY);  % makes artifact
su.ClearStimulationSettingList();
su.GetState();
diary off