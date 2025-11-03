%% Activate Switching Unit - UNPLUG ALL THE CONNECTORS FROM SWITCHING UNIT 
clear
close all
clc
addpath functions\
su = SwitchingUnit();
su.GetState();

su.SetState(su.States.SELFTEST);
su.PollSelftestResult();


%% PLUG ALL THE CONNECTORS
% Parameters
f_start = 20;
f_end   = 1e3;
f_steps = 20;
channel_number = 176;

k_vec = 1:channel_number; % channel vector. one-based index!
% f_vec = linspace(f_start,f_end,f_steps); % lin spaced f
% f_vec = logspace(log10(f_start),log10(f_end),f_steps); % log spaced f
f_vec = f_end;
N_r = 1; % repetitions
use_profile = 0; % 0 ... screening; 1 ... profile mode

% Setup
% su = SwitchingUnit;
su.SetState(su.States.READY);
su.ClearStimulationSettingList();
err = su.ConfigureImpedanceCheck(k_vec,f_vec,N_r,use_profile);
if(err ~= su.Errors.NONE)
    error('Failed to configure impedance check.');
end

% Perform Measurement
err = su.SetState(su.States.IMPEDANCE_CHECK);
if(err ~= su.Errors.NONE)
    error('Failed to start impedance check.');
end

prog = 0;
t = tic;
fprintf('Performing impedance measurement... %7.2f%% (%5.2f minutes remaining)\n',0,60);
while(prog < 1)
    [err,z,prog,~,~] = su.GetImpedanceCheckResult();
    if(err ~= su.Errors.NONE)
        error('Failed to get impedance check results.');
    end

    tt = toc(t);
    t_rem = min(tt/prog*(1-prog),3600);
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%7.2f%% (%5.2f minutes remaining)\n',prog*100,t_rem/60);
    pause(0.25);
end

% z ... Impedance values in kOhm (N_k x N_f x N_r, where N_k = length(k_vec) and N_f = length(f_vec))

% MAKE THE HEAPMAP and SAVE IT
% ch_strings_1 = arrayfun(@(x) sprintf('LA%d', x), 1:16, 'UniformOutput', false);
% ch_strings_2 = arrayfun(@(x) sprintf('RA%d', x), 1:16, 'UniformOutput', false);
% ch_strings_3 = arrayfun(@(x) sprintf('LB%d', x), 1:16, 'UniformOutput', false);
% ch_strings_4 = arrayfun(@(x) sprintf('RB%d', x), 1:16, 'UniformOutput', false); % headbox 1
% ch_strings_5 = arrayfun(@(x) sprintf('LC%d', x), 1:8, 'UniformOutput', false);
% ch_strings_6 = arrayfun(@(x) sprintf('RC%d', x), 1:8, 'UniformOutput', false);
% ch_strings_7 = arrayfun(@(x) sprintf('LD%d', x), 1:16, 'UniformOutput', false);
% ch_strings_8 = arrayfun(@(x) sprintf('RD%d', x), 1:16, 'UniformOutput', false);
% ch_strings_9 = arrayfun(@(x) sprintf('LE%d', x), 1:16, 'UniformOutput', false); % headbox 2
% ch_strings_10 = arrayfun(@(x) sprintf('RE%d', x), 1:16, 'UniformOutput', false);
% ch_strings_11 = arrayfun(@(x) sprintf('LF%d', x), 1:16, 'UniformOutput', false);
% ch_strings_12 = arrayfun(@(x) sprintf('RF%d', x), 1:16, 'UniformOutput', false);
% ch_strings_13 = arrayfun(@(x) sprintf('LG%d', x), 1:16, 'UniformOutput', false); % headbox 3
% ch_strings_14 = arrayfun(@(x) sprintf('RG%d', x), 1:16, 'UniformOutput', false); 
% ch_strings_15 = arrayfun(@(x) sprintf('LH%d', x), 1:16, 'UniformOutput', false); 
% ch_strings_16 = arrayfun(@(x) sprintf('RH%d', x), 1:16, 'UniformOutput', false); % headbox 4
% params.labels = [ch_strings_1 ch_strings_2 ch_strings_3 ch_strings_4 ch_strings_5 ...
%     ch_strings_6 ch_strings_7 ch_strings_8 ch_strings_9 ch_strings_10 ch_strings_11 ...
%     ch_strings_12 ch_strings_13 ch_strings_14 ch_strings_15 ch_strings_16];

ch_strings_1 = arrayfun(@(x) sprintf('LA%d', x), 1:16, 'UniformOutput', false);
ch_strings_2 = arrayfun(@(x) sprintf('RA%d', x), 1:16, 'UniformOutput', false);
ch_strings_3 = arrayfun(@(x) sprintf('LB%d', x), 1:16, 'UniformOutput', false);
ch_strings_4 = arrayfun(@(x) sprintf('LC%d', x), 1:8, 'UniformOutput', false);
ch_strings_5 = arrayfun(@(x) sprintf('RC%d', x), 1:8, 'UniformOutput', false);
ch_strings_6 = arrayfun(@(x) sprintf('LD%d', x), 1:16, 'UniformOutput', false);
ch_strings_7 = arrayfun(@(x) sprintf('RD%d', x), 1:16, 'UniformOutput', false);
ch_strings_8 = arrayfun(@(x) sprintf('LE%d', x), 1:16, 'UniformOutput', false); % headbox 2
ch_strings_9 = arrayfun(@(x) sprintf('RE%d', x), 1:16, 'UniformOutput', false);
ch_strings_10 = arrayfun(@(x) sprintf('LG%d', x), 1:16, 'UniformOutput', false); % headbox 3
ch_strings_11 = arrayfun(@(x) sprintf('RG%d', x), 1:16, 'UniformOutput', false); 
ch_strings_12 = arrayfun(@(x) sprintf('RH%d', x), 1:16, 'UniformOutput', false); % headbox 4
params.labels = [ch_strings_1 ch_strings_2 ch_strings_3 ch_strings_4 ch_strings_5 ...
    ch_strings_6 ch_strings_7 ch_strings_8 ch_strings_9 ch_strings_10 ch_strings_11 ...
    ch_strings_12];

% impedances = rand(1,240)*4;
impedances = z;
params.nChans = channel_number; % params.nChans

plot_image_impedances_NV_v2(impedances, params)
% close all