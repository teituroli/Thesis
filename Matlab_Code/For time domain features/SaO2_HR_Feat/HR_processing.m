%% HR
function [O]...
    =HR_processing(HR,Events,fs,IsRem_in)
%hold on
Start=Events.SpO2_arti.Start+1;
Stop=Start+Events.SpO2_arti.Duration;
for i = 1:length(Start)
    HR(floor(Start(i)):ceil(Stop(i)))=nan;
end

Names={'HR_Kurt', 'HR_Skew','HR_Mean','HR_var','HR_RMS'};

fn=fieldnames(IsRem_in);
t_idx=1:length(HR)/fs;
for i = 1:length(fn)
    IsRem=IsRem_in.(fn{i});

    Len=[];

    for k = 1:length(Names)
        Cmp.(Names{k})=[];
    end

    for s = 1:size(IsRem,1)

        %         xline(t_org(IsRem(s,1)),'g','LineWidth',2)
        %         xline(t_org(IsRem(s,2)),'r','LineWidth',2)
        EEG_idx=(IsRem(s,1)*fs:IsRem(s,2)*fs);

        %%Calculating features here
        %Names={'SaO2_U90','SaO2_80','SaO2_U70','SpO2_mean'};
           
        Cmp.HR_Kurt_t=kurtosis(HR(EEG_idx));
        Cmp.HR_Skew_t=skewness(HR(EEG_idx));
        Cmp.HR_Mean_t=nanmean(HR(EEG_idx));
        Cmp.HR_var_t=nanvar(HR(EEG_idx));
        Cmp.HR_RMS_t=sqrt(nanmean(HR(EEG_idx).^2));
        

        Len_v=length(EEG_idx);

        for k = 1:length(Names)
            Cmp.(Names{k})=[Cmp.(Names{k}); Cmp.([Names{k} '_t'])];
        end

        %%
        %         Under90=[Under90,Under90_v];
        %         Under80=[Under80,Under80_v];
        %         Under70=[Under70,Under70_v];
        %         Mean=[Mean, Mean_v];
        Len=[Len; Len_v];

        %EEG_tmp2=[EEG_tmp2;tmp_band_vec];
        %EEG_Power_spec2=[EEG_Power_spec2;The_Power_spec'];


    end
    %Wmean=nansum([Len.*Mean]/nansum(Len));

    %EEG_bandvec2=nanmean(EEG_tmp2,1);

    if isempty(Cmp.HR_Mean)

        for k = 1:length(Names)
            Cmp.(Names{k})=NaN;
        end
    end

    for k = 1:length(Names)
        O.([fn{i} '_' Names{k}])= nansum([Len.*Cmp.(Names{k})]/nansum(Len));
    end

%     for k = 1:length(Names)
%         O.([fn{i} '_' Names{k}])= Cmp.(Names{k});
%     end
%     Out_Mean=[Out_Mean; Wmean];
%     Out_90=[Out_90;sum(Under90)];
%     Out_80=[Out_80;sum(Under80)];
%     Out_70=[Out_70;sum(Under70)];

    %SaO2_Out=[SaO2_Out;EEG_bandvec2];
    %SaO2_data=[SaO2_data;mean(EEG_Power_spec2,1)];
end

O.tot_HR_Kurt=kurtosis(HR);
O.tot_HR_Skew=skewness(HR);
O.tot_HR_Mean=nanmean(HR);
O.tot_HR_var=nanvar(HR);
O.tot_HR_RMS=sqrt(nanmean(HR.^2));

end
