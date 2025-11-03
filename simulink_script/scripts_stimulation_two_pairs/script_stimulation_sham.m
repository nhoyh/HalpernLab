%% SHAM 
target_amp_1 = 1; % mA
target_time = 180; % sec
target_freq_1 = 130; % Hz
stim_pair ='sham is stimbox2';

time = fix(clock);
diary(sprintf('stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('sham %s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp_1, target_freq_1, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', target_freq_1*target_time) % deciding train time
pause(1);
gEstimPRO_ParameterUpdate(stimbox2, 'Phase Amplitude', target_amp_1) % mA
gEstimPRO_ParameterUpdate(stimbox2, 'Pulse rate', target_freq_1) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
pause(target_time);
time = fix(clock);
fprintf('sham %s %.2f mA %d Hz finished - for %d sec at %d/%d/%d %d:%d:%d\n', stim_pair,target_amp_1, target_freq_1, target_time,time(2),time(3),time(1),time(4),time(5),time(6))

diary off