%% Set pairs and stim channels
% SPEPs params
% Pair 1
speps_anode1 = 1;
speps_cathode1 = 2;
speps_amp1 = 6; % mA
num_reps1 = 5; % how many to run
% Pair 2
speps_anode2 = 3;
speps_cathode2 = 4;
speps_amp2 = 6;
num_reps2 = 5;

% Long stim params
stim_anode = [5];
stim_cathode = [6];
stim_amp = 6; % mA
stim_freq = 130; % Hz
phase_duration = 90; % us


stim_time = 200; % s % don't change it. Regardless of this, it will continuously deliver stim

%% Activate EstimPro
gEstimPRO_ParameterUpdate(stimbox1, 'Active Stop', 'Active')
fprintf('Activated \n');

% connect to BCI2000 
t = tcpclient('localhost',3999);
fopen(t);


%% Run SPEPs - pair 1 round 1
time = fix(clock);
diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));

    runSPEPs(speps_anode1, speps_cathode1, speps_amp1, num_reps1, su, stimbox1, t)

time = fix(clock);
fprintf('SPEPs +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', speps_anode1, speps_cathode1, speps_amp1, time(2), time(3), time(1), time(4), time(5), time(6))
fprintf('\r\n\r\n    SPEPS 1 - FINISHED    \r\n\r\n');

%% Run SPEPs - pair 2 round 1
time = fix(clock);
diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));

    runSPEPs(speps_anode2, speps_cathode2, speps_amp2, num_reps2, su, stimbox1, t)

time = fix(clock);
fprintf('SPEPs +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', speps_anode1, speps_cathode1, speps_amp1, time(2), time(3), time(1), time(4), time(5), time(6))
fprintf('\r\n\r\n    SPEPS 2 - FINISHED    \r\n\r\n');


%% Prep for long stim

su.SetState(su.States.READY);
su.ClearStimulationSettingList();
su.GetState();

% stim
pause(1)
su.AddStimulationSetting(stim_anode, stim_cathode);
% fprintf('\r\n\r\n    PRESS SPACE    \r\n\r\n');
% pause


su.GetStimulationSettingList();
% Set Switching Unit ACTIVE
pause(0.2)
su.SetState(su.States.PREPARED);
pause(1)
su.SetState(su.States.ACTIVE);
su.GetState();

gEstimPRO_ParameterUpdate(stimbox1, 'Number of pulses', stim_freq*stim_time) % deciding train time
pause(1)
time = fix(clock);
diary(sprintf('../logs//stimulation_log_%d_%d_%d.txt',time(2),time(3),time(1)));
fprintf('stim +%s -%s %.2f mA %d Hz started - for %d sec at %d/%d/%d %d:%d:%d\n', num2str(stim_anode),num2str(stim_cathode),stim_amp, stim_freq, stim_time,time(2),time(3),time(1),time(4),time(5),time(6))

gEstimPRO_ParameterUpdate(stimbox1, 'Phase Amplitude', stim_amp) %
gEstimPRO_ParameterUpdate(stimbox1, 'Pulse Rate', stim_freq) % Hz
pause(1)
gEstimPRO_ParameterUpdate(stimbox1, 'Phase Duration', phase_duration);
gEstimPRO_ParameterUpdate(stimbox1, 'Fade type', 'AMPLITUDE')
gEstimPRO_ParameterUpdate(stimbox1, 'Fade-in time', 0) % msec
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')

% Right before stim
fprintf('\r\n\r\n    PRESS SPACE to STIM   \r\n\r\n');
pause
fprintf('\r\n\r\n    STIM STARTED    \r\n\r\n');

% TODO: Increase box size, focus automatically on it
% Display a message box (if it closes, stimulation stops)
hfmsg  = msgbox("Indefinite stim running. Hit ""OK"" in box to stop execution.", "[!] Stimulation delivery ongoing");
ishandle(hfmsg)
tstart = tic();
gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')

while ishandle(hfmsg)

        % If timer is running, do nothing
        if toc(tstart) >= stim_time

            disp('Time passed! restarting')

            % Restart the stim
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort')
            pause(0.1)
            gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Start')
            
            % update timer
            tstart = tic();
        end
        

        % Short pause
        pause(0.5)

end

if ishandle(hfmsg)
    disp('Stim ended normally')
else
    % Manually abort the stim
    gEstimPRO_ParameterUpdate(stimbox1, 'Start Abort', 'Abort') % 1
    disp('[!] Stim ended manually; continuing to SPEPs round 2.')
end


%% Run SPEPs - pair 1 round 2
time = fix(clock);
diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
% time = datetime("now", 'Format', 'MM_dd_yyyy');
% diary(sprintf('logs/CCEP_log_%s.txt', char(time)));


    runSPEPs(speps_anode1, speps_cathode1, speps_amp1, num_reps1, su, stimbox1, t)

time = fix(clock);
fprintf('SPEPs +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', speps_anode1, speps_cathode1, speps_amp1, time(2), time(3), time(1), time(4), time(5), time(6))
fprintf('\r\n\r\n    SPEPS 1 - FINISHED    \r\n\r\n');

%% Run SPEPs - pair 2 round 2
time = fix(clock);
diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));

    runSPEPs(speps_anode2, speps_cathode2, speps_amp2, num_reps2, su, stimbox1, t)

time = fix(clock);
fprintf('SPEPs +%d -%d %.2f mA finished - at %d/%d/%d %d:%d:%d\n', speps_anode1, speps_cathode1, speps_amp1, time(2), time(3), time(1), time(4), time(5), time(6))
fprintf('\r\n\r\n    SPEPS 2 - FINISHED    \r\n\r\n');



% Done.
diary off


%% SPEPs acquisition runs as a local function
function runSPEPs(stim_anode, stim_cathode, stim_amp, repeats, su, stimbox, t)

    su.SetState(su.States.READY);
    su.ClearStimulationSettingList();
    su.GetState();


    % Parameter Update
    su.ClearStimulationSettingList();
    su.AddStimulationSetting(stim_anode, stim_cathode);
    su.GetStimulationSettingList();
    pause(0.2)
    su.SetState(su.States.PREPARED);
    pause(1)
    su.SetState(su.States.ACTIVE);
    pause(3)
    su.GetState();

    time = fix(clock);
    diary(sprintf('../logs/CCEP_log_%d_%d_%d.txt',time(2),time(3),time(1)));
    fprintf('SPEPs +%d -%d %.2f mA started - at %d/%d/%d %d:%d:%d\n', stim_anode, stim_cathode, stim_amp, time(2), time(3), time(1), time(4), time(5), time(6))
    gEstimPRO_ParameterUpdate(stimbox, 'Number of pulses', 1) % deciding train time
    pause(1)
    gEstimPRO_ParameterUpdate(stimbox, 'Phase Amplitude', stim_amp) % mA
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox, 'Pulse Rate', 1) % Hz
    pause(1)
    gEstimPRO_ParameterUpdate(stimbox, 'Fade type', 'AMPLITUDE')
    gEstimPRO_ParameterUpdate(stimbox, 'Fade-in time', 0) % msec
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox, 'Phase Duration', 100)
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox, 'Interphase duration', 0)
    pause(.1)
    gEstimPRO_ParameterUpdate(stimbox, 'Start Abort', 'Abort')
    
    % Ready to go
    % disp('PRESS ANY KEY TO START')
    % pause()
    for i = 1 : repeats
        tic
        t.writeline('Pulse event stimtest 3\r\n');
        gEstimPRO_ParameterUpdate(stimbox, 'Start Abort', 'Start')
        pause(.1)
        gEstimPRO_ParameterUpdate(stimbox, 'Start Abort', 'Abort')
        pause(5)
        toc
    end
    
    % Get back to READY state
    su.SetState(su.States.READY);
    su.ClearStimulationSettingList();
    su.GetState();

end