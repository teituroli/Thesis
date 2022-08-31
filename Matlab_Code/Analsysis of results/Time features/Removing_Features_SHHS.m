%Removing Features SHHS
%%
clc
clear
%close all
%%

load('SHHS_Features_1_add1.mat')
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

%%
for i = 1:length(Features)
    Features(i).Cohort=2;
end

Org_names={'age_s1','gender','race','educat','COFFEE10','bmi_s1','smokstat_s1','Alcoh','ahi_a0h3','NTCA1','ParRptDiab','Cohort'};
Out_names={'Age','Sex','Race','Education','Coffee','BMI','Smoke_status','Alcohol','AHI','Antidepressant','Diabetes','Cohort'};



%%
for i = 1:length(Features)
    
   for k = 1:length(Org_names)
       Drinks='None';
      if strcmp(Out_names{k},'Alcohol')
          Drinks=Features(i).(Org_names{k}); 
          if Drinks==0
              Drinks_Out=0;
          elseif Drinks>0 && Drinks<1
              Drinks_Out=2;
          elseif Drinks==1 || Drinks ==2
              Drinks_Out=2;
          elseif Drinks>=3 && Drinks<=5
              Drinks_Out=3;
          elseif Drinks>=6 && Drinks<=13
              Drinks_Out=4;
          elseif Drinks>13
              Drinks_Out=5;
          else
              Drinks_Out=Drinks;
          end
          Confounders(i).(Out_names{k})=Drinks_Out;
      elseif strcmp(Out_names{k},'Race')
          if Features(i).(Org_names{k})==3 || Features(i).(Org_names{k})==2
              Confounders(i).(Out_names{k})=1;
          elseif Features(i).(Org_names{k})==1
              Confounders(i).(Out_names{k})=0;
          else
              Confounders(i).(Out_names{k})=Features(i).(Org_names{k});
          end
      elseif strcmp(Out_names{k},'Education') 
          Education = Features(i).(Org_names{k});
          if Education<=3
              Education_Out=1;
          elseif Education>=4 && Education<=5
              Education_Out=2;
          elseif Education>=6 && Education<=8
              Education_Out=3;
          else
              %fprintf([num2str(Education) '\n'])
              Education_Out=Education;
          end
          Confounders(i).(Out_names{k})=Education_Out;
      elseif strcmp(Out_names{k},'Smoke_status') 
          Smoker = Features(i).(Org_names{k});
          if Smoker==1
              Smoker_Out=2;
          elseif Smoker==2
              Smoker_Out=1;
          elseif Smoker==0
              Smoker_Out=0;
          else 
              Smoker_Out=Smoker;
          end
          Confounders(i).(Out_names{k})=Smoker_Out;
      else
          Confounders(i).(Out_names{k})=Features(i).(Org_names{k});   
      end
   end
end
%%
FN1=fieldnames(Features);
NamesOut=FN1(3:find(contains(FN1,'EM_total_N')));

for i = 1:length(Features)
   for k = 1:length(NamesOut)
      Calc_Feats(i).(NamesOut{k})=Features(i).(NamesOut{k});           
   end
end
error('Only if wanna save')
%%

%%
Calc_Feats_SHHS=struct2table(Calc_Feats);
writetable(Calc_Feats_SHHS)
save('Calc_Feats_SHHS.mat','Calc_Feats')

Confounders_SHHS=struct2table(Confounders);
writetable(Confounders_SHHS)
save('Confounders_SHHS.mat','Confounders')
