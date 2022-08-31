%Removing Features
%%
clc
clear
close all
%%

load('mrOz__Features_1.mat')
%load('SHHS_Features_1_add1.mat')
indexsaver=[];
for i = 1:size(Features,2)
    
    if isempty(Features(i).fail)
        indexsaver(i)=true;
    else
        indexsaver(i)=false;
    end
    
end

fprintf([num2str(sum(indexsaver)) ' removed\n'])
Features(logical(indexsaver))=[];

%% Removing N4 Fields
Features=rmfield(Features,'Time_in_N4');

%% Removing all that do not have all stages of sleep
stages={'REM','Wake','N1','N2','N3'};
idxremover2=[];
for i = 1:length(Features)
    for k=5:length(stages)
        if isempty(Features(i).(['Time_in_' stages{k}]))
            idxremover2=[idxremover2;i];
            %fprintf(num2str(Features(i).(['Time_in_' stages{k}])))
        elseif isnan(Features(i).(['Time_in_' stages{k}]))
            idxremover2=[idxremover2;i];
        elseif isnumeric(Features(i).(['Time_in_' stages{k}]))
        else
            fprintf('help')
        end
        fprintf([num2str(Features(i).(['Time_in_' stages{k}])) '\n'])
    end
end
fprintf([num2str(length(idxremover2)) ' removed\n'])
Features(idxremover2)=[];

%%
idxremover3=[];
for i = 1:length(Features)
    
    if Features(i).ECG_Tot_HR > 130
        idxremover3=[idxremover3;i];
    end
    
end

fprintf([num2str(length(idxremover3)) ' removed\n'])
Features(idxremover3)=[];
%% Removing ECG which are empty fields
% idxremover4=[];
% for i = 1:length(Features)
%    if isempty(Features(i).REM_ECG_HR)
%        idxremover4=[idxremover4;i];
%    end
% end
% fprintf([num2str(length(idxremover4)) ' removed\n'])
% Features(idxremover4)=[];
%%
FN1=fieldnames(Features);
LastElement=ismember(FN1,'EM_total_N');

for k = 1:find(LastElement)
    IdxRem5=[];
    IdxRem6=[];
    for i = 1:length(Features)
        if isempty(Features(i).(FN1{k}))
            IdxRem5=[IdxRem5;i];
        elseif isnan(Features(i).(FN1{k}))
            IdxRem6=[IdxRem6;i];
        end
    end
    if ~isempty(IdxRem5) || ~isempty(IdxRem6)
        fprintf([num2str(length(IdxRem5)) 'Empty removed in' FN1{k} '\n'])
        fprintf([num2str(length(IdxRem6)) 'NaNs removed in' FN1{k} '\n'])
        Features(IdxRem5)=[];
        Features(IdxRem6)=[];
    end
end

%% Adjusting Sleep Onset and Lights out
%
% for i = 1:length(Features)
%
%     Features(i).Lights_Out
%
%     Features(i).Sleep_Onset
%
% end


%% see nsrrid that are left
for i = 1:length(Features)
    
    nsrrid_left(i)=Features(i).nsrrid;
    
end

%% mros
for i = 1:length(Features)
    cens(i).isdead=Features(i).IsDead;
    cens(i).days=Features(i).Days_From_First_To_Last_Visit;
    if isnan(cens(i).isdead) %should be removed, but this is quick fix until we find more features that need to be removed.
        cens(i).isdead=0;
    end
end
tabcens=struct2table(cens);
%%
error('only if willing to save table')

writetable(tabcens,['MrOs_cens_lab.txt'])

%% shhs
for i = 1:length(Features)
    cens(i).isdead=Features(i).isdead;
    cens(i).days=Features(i).censdate;
    if isnan(cens(i).isdead) %should be removed, but this is quick fix until we find more features that need to be removed.
        cens(i).isdead=0;
    end
end
tabcens=struct2table(cens);
%%
for i = 1:size(tabcens)
    
    if isempty(tabcens.days{i})
        tabcens.days(i)={NaN}
        tabcens.isdead(i)={NaN}
    end
    
end
error('only if willing to save table')
%%
writetable(tabcens,['SHHS_cens_lab2.txt'])
%%
%Features2=struct2table(Features);

%Viewer=[[Features.Time_in_REM];[Features.Time_in_Wake];[Features.Time_in_N1];[Features.Time_in_N2];[Features.Time_in_N3]]';
% Viewer=[[Features.REM_ECG_HR];[Features.REM_HR_Mean]]
%Viewver2=[[Features.Time_in_REM];[Features.REM_sleepTime]]';
%Viewver2=[[Features.Time_in_REM];[Features.timerem]]';
%Features.timerem