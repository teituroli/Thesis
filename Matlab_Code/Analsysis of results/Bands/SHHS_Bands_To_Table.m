%Band_To_Table
%% A good start
clc
clear
close all
%% Load data
load('ECG_1-20_Bands.mat')

Name='ECG';

if strcmp(Name,'ECG')
    %load('FrequencyVec_10-30.mat')
    load('FrequencyVec_1-10.mat')
elseif contains(Name,'EOG')
    load('FrequencyVec_1-10_EOG.mat')
else
    load('FrequencyVec_1-10.mat')
end


%%
FN1=fieldnames(O);
for i = 1:length(FN1)-1
        
    Tmp_Struct=[O.(FN1{i}).REM,O.(FN1{i}).N3,O.(FN1{i}).N2,O.(FN1{i}).N1,O.(FN1{i}).Wake];

    WLvec=FrequencyVector.(FN1{i});
    for j = 1:length(WLvec)
       ColNames_REM{j}= ['REM_' num2str(WLvec(j))];
       ColNames_N3{j}=['N3_' num2str(WLvec(j))];
       ColNames_N2{j}=['N2_' num2str(WLvec(j))];
       ColNames_N1{j}=['N1_' num2str(WLvec(j))];
       ColNames_Wake{j}=['Wake_' num2str(WLvec(j))];
    end
    
    ColNames=[ColNames_REM,ColNames_N3,ColNames_N2,ColNames_N1,ColNames_Wake];
    
    OutTab=array2table(Tmp_Struct,'VariableNames',ColNames);
    
    writetable(OutTab,[Name '_' FN1{i} '.txt'])
    save([Name '_' FN1{i} '.mat'],'OutTab')
end
