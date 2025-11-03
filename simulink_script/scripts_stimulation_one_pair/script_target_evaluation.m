%% Target evaluation - structured, and will send Events (same function as digital input) 
 
%% set the stimulation parameters
target_time = 0.1; % min. Stimulation duration. You can put 0.5, 0.1, .. but if it's more than 1, just 1,2,3,4,... are allowed. not 1.5
prestim_recording_time = 5; % sec
poststim_recording_time = 5; % sec
phase_duration = 90; %us

%% select stimulation pair map
fnames = dir('../stimulation_channel_map/*.m');
listdlg('ListString', {fnames.name},'ListSize', [300, 300],'SelectionMode', 'single')
run (fullfile(fnames(ans).folder, fnames(ans).name))
%%
% connect to BCI2000 
t = tcpclient('localhost',3999);
fopen(t);

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
    t.writeline('Pulse event stimtest 5\r\n');
    fprintf('prestim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause(prestim_recording_time);

    % 2. Switching on
    t.writeline('Pulse event stimtest 6\r\n');
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
        fprintf('stim +%s -%s %.2f mA %d Hz started - for %.1f min at %d/%d/%d %d:%d:%d\n',  num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
        pause(0.1)
        gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', stim_pair{i,4}) %
        gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration) % us
        gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', stim_pair{i,3}) % Hz
        pause(1)
        gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
        gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec
        if target_time < 1
            gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', stim_pair{i,3}*target_time*60) % deciding train time
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
            pause(target_time*60);
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
        else
            gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', stim_pair{i,3}*1*60) % deciding train time
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') 
            pause(0.1)
            for iteration = 1:target_time
                fprintf('%d/%d min stim is ongoing\r\n',iteration,target_time);
                gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start') 
                pause(60)
                gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') 
                pause(0.1);
            end
        end
        time = fix(clock);
        fprintf('stim +%s -%s %.2f mA %d Hz finished - for %.1f min at %d/%d/%d %d:%d:%d\n', num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
    elseif stim_pair{i,5} == 1 % SHAM
        fprintf('sham +%s -%s %.2f mA %d Hz started - for %.1f min at %d/%d/%d %d:%d:%d\n',  num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
        pause(0.1)
        gEstimPRO_ParameterUpdate(stimbox2, 'Phase Amplitude', stim_pair{i,4}) %
        gEstimPRO_ParameterUpdate(stimbox2, 'Phase Duration', phase_duration) % us
        gEstimPRO_ParameterUpdate(stimbox2, 'Pulse rate', stim_pair{i,3}) % Hz
        pause(1)
        gEstimPRO_ParameterUpdate(stimbox2, 'Fade type', 'AMPLITUDE')
        gEstimPRO_ParameterUpdate(stimbox2, 'Fade-in time', 0) % msec
        if target_time < 1
            gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', stim_pair{i,3}*target_time*60) % deciding train time
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
            pause(target_time*60);
            gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
        else
            gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', stim_pair{i,3}*1*60) % deciding train time
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort') 
            pause(0.1)
            for iteration = 1:target_time
                fprintf('%d/%d min sham is ongoing\r\n',iteration,target_time);
                gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start') 
                pause(60)
                gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort') 
                pause(0.1);
            end
        end
        time = fix(clock);
        fprintf('stim +%s -%s %.2f mA %d Hz finished - for %.1f min at %d/%d/%d %d:%d:%d\n', num2str(stim_pair{i,1}),num2str(stim_pair{i,2}),stim_pair{i,4}, stim_pair{i,3}, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
    end
    % 4. Switching off
    su.SetState(su.States.READY);
    su.ClearStimulationSettingList();
    su.GetState();
    pause(4)
    % 5. Poststim useful data period
    t.writeline('Pulse event stimtest 7\r\n');
    fprintf('poststim recording started at  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause(poststim_recording_time);

    % 6. Intertrial interval
    t.writeline('Pulse event stimtest 8\r\n');
    fprintf('\r\n\r\n    END OF TRIAL / PLEASE ASK RATING   \r\n\r\n');
    fprintf('Press any key to continue  %d/%d/%d %d:%d:%d \n',time(2),time(3),time(1),time(4),time(5),time(6))
    pause;
end
diary off
%% close connection to BCI
clear t
echotcpip("off")