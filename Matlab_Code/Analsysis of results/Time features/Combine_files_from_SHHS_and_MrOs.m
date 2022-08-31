%% Combine files from SHHS and MrOs

%%
error('Only if you want to read and save censlabels')
%%
SHHS_cens=readtable('SHHS_cens_lab.txt');
MrOs_cens=readtable('MrOs_cens_lab.txt');

Comb_cens=[MrOs_cens;SHHS_cens];
writetable(Comb_cens,'Comb_cens.txt');

%%
error('Run and save EEG')
%%
path_SHHS='C:\Users\Teitur\Desktop\School\Thesis\Code\Processing Data\Bands\SHHS\Step3_mat';
SHHS_ECG=load([path_SHHS,'\ECG\ECG_WL_1.mat'])
%SHHS_EEG=load([path_SHHS,'\EEG\EEG_WL_4.mat'])
%SHHS_EOG_R=load([path_SHHS,'\EOG_R\EOG_R_WL_4.mat'])
%SHHS_EOG_L=load([path_SHHS,'\EOG_L\EOG_L_WL_4.mat'])
%SHHS_EMG=load([path_SHHS,'\EMG\EMG_WL_1.mat'])

%%
path_MrOs='C:\Users\Teitur\Desktop\School\Thesis\Code\Processing Data\Bands\Step3_mat'
MrOs_ECG=load([path_MrOs,'\ECG\ECG_WL_1.mat'])
%MrOs_EEG=load([path_MrOs,'\EEG\EEG_WL_4.mat'])
%MrOs_EOG_R=load([path_MrOs,'\EOG_R\EOG_R_WL_4.mat'])
%MrOs_EOG_L=load([path_MrOs,'\EOG_L\EOG_L_WL_4.mat'])
%MrOs_EMG=load([path_MrOs,'\EMG\EMG_WL_1.mat'])

%%
Combined_ECG=[MrOs_ECG.OutTab;SHHS_ECG.OutTab];

Labels_ECG=Combined_ECG.Properties.VariableNames
NewECGLable = cellfun(@(c)['ECG_' c],Labels_ECG,'uni',false)
Combined_ECG.Properties.VariableNames=NewECGLable;

writetable(Combined_ECG,'Combined_ECG_WL1.txt');

%Combined_EEG=[MrOs_EEG.OutTab;SHHS_EEG.OutTab];
%Labels_EEG=Combined_EEG.Properties.VariableNames
%NewEEGLable = cellfun(@(c)['EEG_' c],Labels_EEG,'uni',false)
%Combined_EEG.Properties.VariableNames=NewEEGLable;
% 
% writetable(Combined_EEG,'Combined_EEG.txt');
% 
% 
% Combined_EOG_R=[MrOs_EOG_R.OutTab;SHHS_EOG_R.OutTab];
% Labels_EOG_R=Combined_EOG_R.Properties.VariableNames
% NewEOG_RLable = cellfun(@(c)['EOG_R' c],Labels_EOG_R,'uni',false)
% Combined_EOG_R.Properties.VariableNames=NewEOG_RLable;
% 
% writetable(Combined_EOG_R,'Combined_EOG_R.txt');
% 
% 
% Combined_EOG_L=[MrOs_EOG_L.OutTab;SHHS_EOG_L.OutTab];
% Labels_EOG_L=Combined_EOG_L.Properties.VariableNames
% NewEOG_LLable = cellfun(@(c)['EOG_L' c],Labels_EOG_L,'uni',false)
% Combined_EOG_L.Properties.VariableNames=NewEOG_LLable;
% 
% writetable(Combined_EOG_L,'Combined_EOG_L.txt');
% 
% %%
% Combined_EMG=[MrOs_EMG.OutTab;SHHS_EMG.OutTab];
% Labels_EMG=Combined_EMG.Properties.VariableNames
% NewEMGLable = cellfun(@(c)['EMG_' c],Labels_EMG,'uni',false)
% Combined_EMG.Properties.VariableNames=NewEMGLable;
% 
% writetable(Combined_EMG,'Combined_EMG.txt');
% 
% %%
% 
%%
error('Do you want to combine all of these bands?')
%%
AllBandsInOne=[Combined_ECG,Combined_EEG,Combined_EMG,Combined_EOG_R,Combined_EOG_L];
writetable(AllBandsInOne,'AllBandsInOne.txt');
