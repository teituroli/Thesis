%% EOG
function [EOG_Ratio,tot_EOG,tot_EOG_n]=EOG_function(T_EM,EM_Val,fs,InterpVal,IsRem_in)
sum_EOG=0;
sum_minutes=0;
EOG_tmp3=0;
%hold on
EOG_Ratio=[];
EOG_vec=[];
sum_vec=[];
EOG_vec_min=[];
fn=fieldnames(IsRem_in);
tindx=1:length(T_EM);
for k = 1:length(fn)
    IsRem=IsRem_in.(fn{k});
    EOG_tmp2=[];
    for s = 1:size(IsRem,1)
        %         xline(t_org(IsRem(s,1)),'g','LineWidth',2)
        %         xline(t_org(IsRem(s,2)),'r','LineWidth',2)
        %EOG_idx=isbetween(T_EM,IsRem(s,1),IsRem(s,2));
try
        EOG_idx=(IsRem(s,1)*InterpVal^-1:IsRem(s,2)*InterpVal^-1);
catch
   fprintf('help') 
end
        EOG_tmp=(sum(EM_Val(EOG_idx))*InterpVal)/60; %minutes
        EOG_tmp2=[EOG_tmp2;EOG_tmp];

    end

    %%analyse here%%
    try
        EOG_tmp3=[EOG_tmp3;EOG_tmp2];
        MinEOG=nansum(EOG_tmp2);
        minutes_REM=nansum((IsRem(:,2)-IsRem(:,1)))/60; %minutes
        EOG_SR=nansum(EOG_tmp2)/minutes_REM; %minutes EM in REM pr hour
    catch
        EOG_tmp3=[EOG_tmp3;EOG_tmp2];
        minutes_REM=0;
        EOG_SR=0; %minutes EM in REM pr hour
        MinEOG=0;
    end

    
    if isempty(EOG_SR) || isnan(EOG_SR)
        EOG_SR=0;
        MinEOG=0;
    end

    EOG_Ratio.([fn{k} '_EM' '_N'])=EOG_SR;
    EOG_Ratio.([fn{k} '_EM'])=MinEOG;

    %EOG_vec=[EOG_vec;EOG_SR];
    EOG_vec_min=[EOG_vec_min;MinEOG];
    sum_minutes=sum_minutes+minutes_REM;
    sum_vec=[sum_vec;minutes_REM];
end
tot_EOG=sum(EOG_vec_min);
tot_EOG_n=tot_EOG/sum_minutes;
end