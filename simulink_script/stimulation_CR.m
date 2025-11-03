% Surface area: 4.5616 mm^2
clc
close all

stimbox1 = 'ES-2020.04.02';
stimbox2 = 'ES-2021.06.02';

%% Activate
gEstimPRO_ParameterUpdate(stimbox1, 'Active Stop', 'Active')
pause(0.2)
gEstimPRO_ParameterUpdate(stimbox2, 'Active Stop', 'Active')
pause(0.2)

%% Stimulate for CR - repeats
% specify stim pair directly from here
target_time = 300; % sec
nCycles = [3, 2]; % ON / OFF

% Stim. 1
stim_anode_1 = 65; % this can be array like [1,2,3];
stim_cathode_1 = 66;
target_amp_1 = 5; % mA
target_freq_1 = 130; % Hz
phase_time_1 = 60;

% Stim. 2
stim_anode_2 = 66; % manually connect this
stim_cathode_2 = 67; % and this
target_amp_2 = 5; % mA
target_freq_2 = 130; % Hz
phase_time_2 = 60;

% Timings
ptime = 0.1; % "positive" time (i.e. stim. 1 ON duration)
ntime = 0.1; % "negative" time (i.e. stim. 2 ON duration)
pausetime = 0.025; % pause time between stims (i.e. stim 1/2 OFF duration)
ctime = 0.25; % cycle total time - must be (ctime > ptime + ntime + pausetime)
rtime = ctime - ptime - ntime - pausetime; % remaining time at the end of each block (must be positive)
if rtime < 0
    error("[!] Cannot accommodate this duration. Change timing parameters.")
end

% Prepare the switching unit (stimulator 1)
disp('Preparing switching unit (stim1)')
% Prepare the switching unit (stimulator 1)
su.ClearStimulationSettingList();
su.AddStimulationSetting(stim_anode_1,stim_cathode_1);
su.GetStimulationSettingList();

% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();
pause(1); % wait until switiching artifact is eliminated

% Setup the parameters for the two stimulators
fprintf('[1] Number of pulses : %d\n', 20e3) % deciding train time
gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', 20e3) % fixed train time
pause(1)
fprintf('[2] Number of pulses : %d\n', 20e3) % deciding train time
gEstimPRO_ParameterUpdate(stimbox2, 'Number of pulses', 20e3) % fixed train time
pause(1)
time = fix(clock);
diary(sprintf('logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));

gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', target_amp_1) %
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse rate', target_freq_1) % Hz
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_time_1) % us
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
pause(0.1)
fprintf('[1] Phase Amplitude : %d mA\n', target_amp_1)
fprintf('[1] Pulse rate : %d Hz\n', target_freq_1)
fprintf('[1] Fade type : AMPLITUDE\n')
fprintf('[1] Phase Duration : %d us\n', phase_time_1)
fprintf('[1] Fade-in time : %d ms\n', 0)
fprintf('---------------\n')

gEstimPRO_ParameterUpdate(stimbox2, 'Phase Amplitude', target_amp_2) % mA
gEstimPRO_ParameterUpdate(stimbox2, 'Pulse rate', target_freq_2) % Hz
gEstimPRO_ParameterUpdate(stimbox2, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox2, 'Phase Duration', phase_time_2) % us
gEstimPRO_ParameterUpdate(stimbox2, 'Fade-in time', 0) % msec
gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
pause(0.1)
fprintf('[2] Phase Amplitude : %d mA\n', target_amp_2)
fprintf('[2] Pulse rate : %d Hz\n', target_freq_2)
fprintf('[2] Fade type : AMPLITUDE\n')
fprintf('[2] Phase Duration : %d us\n', phase_time_2)
fprintf('[2] Fade-in time : %d ms\n', 0)

time = fix(clock);
fprintf('stim1 +%s -%s %.2f mA %d Hz %dus - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode_1),num2str(stim_cathode_1),target_amp_1, target_freq_1, phase_time_1, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
fprintf('stim2 +%s -%s %.2f mA %d Hz %dus- for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode_2),num2str(stim_cathode_2),target_amp_2, target_freq_2, phase_time_2, target_time,time(2),time(3),time(1),time(4),time(5),time(6))
pause

% If true -> stim 1; else -> stim2
switchval = true; % initialize this
tic; % get current time
% contord = randperm(ncontacts); % stim contact order
cycle_cnt = 1;
while toc <= target_time
    
    % % Check where to deliver stim now
    % stim_curr = contord(1);

    if cycle_cnt < nCycles(1)
        % stim!
        if switchval
            % stim 1 delivery
            fprintf('[*] Stim delivery - pair 1!\n')
            % gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
            pause(ptime);
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
            % pause(pausetime)
        else
            % stim 2 delivery
            fprintf('[*] Stim delivery - pair 2!\n')
            % gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
            gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Start')
            pause(ntime);
            gEstimPRO_ParameterUpdate(stimbox2, 'Start Abort', 'Abort')
            % pause(pausetime);
    
            % Cycle update
            cycle_cnt = cycle_cnt + 1;
            fprintf('[>] Cycle updated : %d\n', cycle_cnt)
        end
        pause(pausetime);
    
        % trigger the other side next
        switchval = ~switchval;
        pause(rtime);

        % % Check if there is something left for next turn
        % contord(1) = [];
        % if isempty(contord)
        %     contord = randperm(ncontacts);
        % end
    elseif cycle_cnt < sum(nCycles)
        pause(ctime); % wait for a whole cycle
        cycle_cnt = cycle_cnt+1;
        fprintf('[>] Cycle updated : %d\n', cycle_cnt)
    else
        cycle_cnt = 0; % Reset!
    end
end

% Get back to READY state
fprintf('[!] Done! Back to READY\n')
% Get back to READY state
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();