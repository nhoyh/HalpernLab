%% Stimulate for the safety test
%% select stimulation pair map
fnames = dir('../stimulation_channel_map/*.m');
listdlg('ListString', {fnames.name},'ListSize', [300, 300],'SelectionMode', 'single')
run (fullfile(fnames(ans).folder, fnames(ans).name))
%%
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
    gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
    gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec

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
