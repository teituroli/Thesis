%% SHHS variable fixer

load('SHHS__Features_1')

tableadd=readtable('shhs-cvd-summary-dataset-0.13.0.csv');
%%
for i = 1:length(Features)
   
    for k = 1:size(tableadd,1)
        
        if Features(i).nsrrid==tableadd.nsrrid(k)
           
            Features(i).censdate=tableadd.censdate(k);
            Features(i).isdead=abs(tableadd.vital(k)-1);
           
           break
        end
        
    end
    fprintf([num2str(i) ' \n'])
    
end

%
%% remove fields i dont need
%load('SHHS_Corrected_State_5')

OldFeatures=Features;

Features=struct;

fntemp=fieldnames(OldFeatures);
idxtmp=find(contains(fntemp,'q1'));
strtmp=fntemp{idxtmp};

Str=strtmp(1:end-3);
%invstr={'nsrrid','age_s1'}
%{'subj_id','ageatvisit','SEX','is_Nonwhite','EDU','bmi_new','smoker','smoker','alcohol','caffeine','antidep','sedative_drug'...
%    'pcttststage2','waso','ess','EMPHYSEMA_YND','DIABETES_YND','HEARTATTACK_YND','STROKE_YND'...
%    'tst','REM_LATENCY','SLEEP_LATENCY','pcttststagerem','tst_rem','ahia'...
%    'DADEAD','Censored','DACANCER','DACARDIO','DAOTHER','FUTIME'}
% invstr=[{'nsrrid'},{'age_s1'},{'gender'},{'race'},{'educat'},{'bmi_s1'},{'smokstat_s1'}...
%     ,{'Alcoh'},{'COFFEE15'},{'NTCA1'},{'timerem'},{'timeremp'},{'timest2p'},{'WASO'},{'ESS_s1'}...
%     ,{'EMPHYS15'},{'ParRptDiab'},{'prev_hx_stroke'},{'prev_hx_mi'},{'rem_lat1'},{'Sleep_Latency'},{'ahi_a0h3a'}...
%     ,{'alive'},{'censdate'},...
%     {[Str '_' 'Mean_Beta']},{'Total_Sleep_Time'},{[Str '_' 'Tot_EOG']}...
%     ,{[Str '_' 'Time_RQ2']},{[Str '_' 'Mean_Gamma']},{[Str '_' 'Time_RQ4']}...
%     ,{[Str '_' 'Number_Of']},{[Str '_' 'Mean_Alpha']},...
%     {[Str '_' 'Dur_Pr_Num']},{[Str '_' 'Var_dur']},...
%     {[Str '_' 'Time_SQ1']},{[Str '_' 'Mean_Delta']},{[Str '_' 'Mean_Theta']}...
%     ,{[Str '_' 'Max_dur']},{[Str '_' 'Time_SQ3']},{[Str '_' 'Time_RQ3']},...
%     {[Str '_' 'Time_SQ2']},{[Str '_' 'Time_SQ4']},{[Str '_' 'Mean_duration']},...
%     {[Str '_' 'Time_RQ1']},{[Str '_' 'q2']},{[Str '_' 'q3']},{[Str '_' 'q4']},{[Str '_' 'q1']}];

%no sedatives, unless 

invstr=invstrings(Str);

%load('gothroughnames.mat')

% for i = 1:length(gothroughnames)
%     if ~sum(ismember(gothroughnames{i},invstr))==1
%         invstr{end+1}=gothroughnames{i};
%     end
% end
    
for i = 1:length(invstr)
    if ~strcmp(invstr{i},'alive')
        for k = 1:length(OldFeatures)
            Features(k).(invstr{i}) = OldFeatures(k).(invstr{i});
        end
        fprintf(['notalive' invstr{i} '\n'])
    else
        for k = 1:length(OldFeatures)
            Features(k).isdead = abs(OldFeatures(k).(invstr{i})-1);
        end
        fprintf(['alive' invstr{i} '\n'])
    end
end
save('SHHS_Corrected_State_7','Features')
% 
% OldFeatures.nsrrid
% OldFeatures.age_s1
% OldFeatures.gender
% OldFeatures.race
% OldFeatures.educat
% OldFeatures.bmi_s1
% OldFeatures.smokstat_s1
% OldFeatures.Alcoh
% OldFeatures.COFFEE1 %check
% OldFeatures.timerem
% OldFeatures.timeremp
% OldFeatures.timest2p
% OldFeatures.WASO
% OldFeatures.ESS_s1
% OldFeatures.EMPHYS15%check
% OldFeatures.STROKE15%check
% OldFeatures.ANGINA15%check
% OldFeatures.rem_lat1
% OldFeatures.Sleep_Latency
% OldFeatures.ahi_c0h3 %check
% OldFeatures.alive
% OldFeatures.censdate %followup time

%%
function invstring=invstrings(Str)

invstring=[
    {'nsrrid'}
    {'age_s1'}
    {'gender'}
    {'race'}
    {'educat'}
    {'bmi_s1'}
    {'smokstat_s1'}
    {'Alcoh'}
    {'COFFEE15'}
    {'NTCA1'}
    {'timerem'}
    {'timeremp'}
    {'timest2p'}
    {'WASO'}
    {'ESS_s1'}
    {'EMPHYS15'}
    {'ParRptDiab'}
    {'prev_hx_stroke'}
    {'prev_hx_mi'}
    {'rem_lat1'}
    {'Sleep_Latency'}
    {'ahi_a0h3a'}
    {'alive'}
    {'censdate'}
{['LightOff']}
%{['Sleep_Onset']}
{['Sleep_Latency']}
%{['Scored_sleepTime']}
{['Scored_sleep_time_c']}
%{['P_REM_sleep']}
%{[Str '_latency']}
{['Total_Sleep_Time_c']}
%{[Str '_sleepTime']}
{[Str '_SleepTime_c']}
{[Str '_P_Sleep_c']}
{[Str '_latency_c']}
{[Str '_Number_Of']}
{[Str '_Mean_duration']}
{[Str '_Dur_Pr_Num']}
{[Str '_Var_dur']}
{[Str '_Max_dur']}
{[Str '_Mean_Delta']}
{[Str '_Mean_Theta']}
{[Str '_Mean_Alpha']}
{[Str '_Mean_Beta']}
{[Str '_Mean_Gamma']}
{['Total_sig_Delta']}
{['Total_sig_Theta']}
{['Total_sig_Alpha']}
{['Total_sig_Beta']}
{['Total_sig_Gamma']}
{[Str '_Delta_RQ1']}
{[Str '_Delta_SQ1']}
{[Str '_Delta_RQ2']}
{[Str '_Delta_SQ2']}
{[Str '_Delta_RQ3']}
{[Str '_Delta_SQ3']}
{[Str '_Delta_RQ4']}
{[Str '_Delta_SQ4']}
{[Str '_Theta_RQ1']}
{[Str '_Theta_SQ1']}
{[Str '_Theta_RQ2']}
{[Str '_Theta_SQ2']}
{[Str '_Theta_RQ3']}
{[Str '_Theta_SQ3']}
{[Str '_Theta_RQ4']}
{[Str '_Theta_SQ4']}
{[Str '_Alpha_RQ1']}
{[Str '_Alpha_SQ1']}
{[Str '_Alpha_RQ2']}
{[Str '_Alpha_SQ2']}
{[Str '_Alpha_RQ3']}
{[Str '_Alpha_SQ3']}
{[Str '_Alpha_RQ4']}
{[Str '_Alpha_SQ4']}
{[Str '_Beta_RQ1']}
{[Str '_Beta_SQ1']}
{[Str '_Beta_RQ2']}
{[Str '_Beta_SQ2']}
{[Str '_Beta_RQ3']}
{[Str '_Beta_SQ3']}
{[Str '_Beta_RQ4']}
{[Str '_Beta_SQ4']}
{[Str '_Gamma_RQ1']}
{[Str '_Gamma_SQ1']}
{[Str '_Gamma_RQ2']}
{[Str '_Gamma_SQ2']}
{[Str '_Gamma_RQ3']}
{[Str '_Gamma_SQ3']}
{[Str '_Gamma_RQ4']}
{[Str '_Gamma_SQ4']}
{[Str '_Time_SQ1']}
{[Str '_Time_RQ1']}
{[Str '_Time_SQ2']}
{[Str '_Time_RQ2']}
{[Str '_Time_SQ3']}
{[Str '_Time_RQ3']}
{[Str '_Time_SQ4']}
{[Str '_Time_RQ4']}
{[Str '_q1']}
{[Str '_q2']}
{[Str '_q3']}
{[Str '_q4']}
{[Str '_Tot_EOG']}
{[Str '_EyeMov_SQ1']}
{[Str '_EyeMov_RQ1']}
{[Str '_EyeMov_SQ2']}
{[Str '_EyeMov_RQ2']}
{[Str '_EyeMov_SQ3']}
{[Str '_EyeMov_RQ3']}
{[Str '_EyeMov_SQ4']}
{[Str '_EyeMov_RQ4']}]

end




