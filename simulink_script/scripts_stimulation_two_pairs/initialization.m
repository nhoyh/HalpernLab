surface_area = 4.5616; 
stimbox1 = 'ES-2020.04.02';
stimbox2 = 'ES-2021.06.02';


%% Activate EstimPro
gEstimPRO_ParameterUpdate(stimbox1, 'Active Stop', 'Active')
% gEstimPRO_ParameterUpdate(stimbox2, 'Active Stop', 'Active')
fprintf('Activated \n');
