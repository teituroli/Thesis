%% Combining_Categories
clc
clear
close all
%%
Feats.MrOs=load('Calc_Feats_MrOs.mat');
Feats.MrOs=struct2table(Feats.MrOs.Calc_Feats);
Feats.SHHS=load('Calc_Feats_SHHS.mat');
Feats.SHHS=struct2table(Feats.SHHS.Calc_Feats);

Conf.MrOs=load('Confounders_MrOs.mat');
Conf.MrOs=struct2table(Conf.MrOs.Confounders);

Conf.SHHS=load('Confounders_SHHS.mat');
Conf.SHHS=struct2table(Conf.SHHS.Confounders);
%%

CombFeats=[Feats.MrOs;Feats.SHHS];
CombConf=[Conf.MrOs;Conf.SHHS];

%%
error('OnlyIfPrint')
%%
save('CombFeats.mat','CombFeats')
writetable(CombFeats)
writetable(CombConf)
save('CombConf.mat','CombConf')







%AllBandsInOne=[Combined_ECG,Combined_EEG,Combined_EMG,Combined_EOG_R,Combined_EOG_L];
