%% EEG
function [O]...
    =SaO2_processing(SaO2,Events,fs,IsRem_in)
%hold on
Start=Events.SpO2_arti.Start+1;
Stop=Start+Events.SpO2_arti.Duration;
for i = 1:length(Start)
    SaO2(floor(Start(i)):ceil(Stop(i)))=nan;
end

Names={'SaO2_U90','SaO2_U80','SaO2_U70','SaO2_mean'};


Out_Mean=[];
Out_90=[];
Out_80=[];
Out_70=[];
SaO2_Out=[];
SaO2_data=[];
fn=fieldnames(IsRem_in);
t_idx=1:length(SaO2)/fs;
for i = 1:length(fn)
    IsRem=IsRem_in.(fn{i});
    EEG_tmp2=[];
    EEG_Power_spec2=[];
    Under90=[];
    Under80=[];
    Under70=[];
    Mean=[];
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

        Cmp.SaO2_U90_t=nansum(SaO2(EEG_idx)<90)/60;%minutes
        Cmp.SaO2_U80_t=nansum(SaO2(EEG_idx)<80)/60;%minutes
        Cmp.SaO2_U70_t=nansum(SaO2(EEG_idx)<70)/60;%minutes

        Cmp.SaO2_mean_t=nanmean(SaO2(EEG_idx));
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
    Cmp.SaO2_mean=nansum([Len.*Cmp.SaO2_mean]/nansum(Len));
    %Wmean=nansum([Len.*Mean]/nansum(Len));

    %EEG_bandvec2=nanmean(EEG_tmp2,1);

    if isempty(Cmp.SaO2_U90) || Cmp.SaO2_mean==0

        for k = 1:length(Names)
            Cmp.(Names{k})=NaN;
        end
    end

    for k = 1:length(Names)
        O.([fn{i} '_' Names{k}])= sum(Cmp.(Names{k}));
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

Max_1=structfun(@max, IsRem_in, 'UniformOutput', false);
Max_2=structfun(@max, Max_1, 'UniformOutput', false);
Max_3=struct2cell(Max_2);
maxval=max([Max_3{:}]);

Min_1=structfun(@min, IsRem_in, 'UniformOutput', false);
Min_2=structfun(@min, Min_1, 'UniformOutput', false);
Min_3=struct2cell(Min_2);
minval=min([Min_3{:}]);



O.SpO2_Tot_90=nansum(SaO2<90)/60;
O.SpO2_Tot_80=nansum(SaO2<90)/60;
O.SpO2_Tot_70=nansum(SaO2<90)/60;
O.SpO2_Tot_mean=nanmean(SaO2);

Tot_sleep_time=(maxval-minval)/60;

for k = 1:length(fn)
    try
    O.(['Time_in_' fn{k}])=sum(IsRem_in.(fn{k})(:,2)-IsRem_in.(fn{k})(:,1))/(60); %minutes of sleep in each stage
    catch
        O.(['Time_in_' fn{k}])=NaN;
    end
end

O.Total_sleep_time=Tot_sleep_time;

end