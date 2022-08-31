function [O]=ECG_features(ECG,fs,Events,State_idx)


[~,qrs_idx,delay]=pan_tompkin(ECG,fs,0);

index2sec=(qrs_idx/fs);

rrint=index2sec(2:end)-index2sec(1:end-1);

RR=HRV.RRfilter(rrint);

fn=fieldnames(State_idx);

Names={'HR','SDNN','SDSD','RMSSD','pNN50','TRI','TINN'};

% for k = 1:length(Names)
%     O.([Names{k}])=[];
% end

for i = 1:length(fn)
    State=State_idx.(fn{i});

    for k = 1:length(Names)
        Cmp.(Names{k})=[];
    end

    Len=[];

    for s = 1:size(State,1)

        Lowidx=State(s,1)*fs;
        Highidx=State(s,2)*fs;
        
        Area_idx=find( Lowidx <= qrs_idx & qrs_idx <= Highidx);
        
        timeperiod=(Highidx-Lowidx)/fs;
        minpulse=timeperiod*30/60; %30 beats pr minute is lower limit otherwise categorized as artefact
        
        if ~isempty(Area_idx) 
            if length(Area_idx)>minpulse
        try
        
            if Area_idx(end)>length(RR)  %remove last index as it is removed in the RR calculation
                Area_idx(end)=[];
            end
        catch
            fprintf('error')
        end
        Anal_data=RR(Area_idx);

        Anal_data(isnan(Anal_data))=[];
        
        if ~isempty(Anal_data) && sum(isnan(Anal_data))==0
        Cmp.HR_t=HRV.HR(Anal_data);
        Cmp.SDNN_t=HRV.SDNN(Anal_data);
        Cmp.SDSD_t=HRV.SDSD(Anal_data);
        Cmp.RMSSD_t=HRV.RMSSD(Anal_data);
        Cmp.pNN50_t=HRV.pNN50(Anal_data);
        [Cmp.TRI_t,Cmp.TINN_t]=HRV.triangular_val(Anal_data);
        
        for k = 1:length(Names)
            Cmp.(Names{k})=[Cmp.(Names{k}); Cmp.([Names{k} '_t'])];
        end
%         HR=[HR;HR_t];
%         SDNN=[SDNN; SDNN_t];
%         SDSD=[SDSD; SDSD_t];
%         RMSSD=[RMSSD; RMSSD_t];
%         pNN50=[pNN50; pNN50_t];
%         TRI=[TRI;TRI_t];
%         TINN=[TINN;TINN_t];
        
        Len=[Len;length(Anal_data)];
        end
            end
        end
    end

    for k = 1:length(Names)
        Cmp.(['w' Names{k}])=[nansum(Len.*Cmp.(Names{k})/nansum(Len))];
    end

    if isempty(Cmp.wHR) || Cmp.wHR==0
      for k = 1:length(Names)
        Cmp.(['w' Names{k}])=NaN;
      end
    end

%     for k = 1:length(Names)
%         O.([Names{k}])=[ O.([Names{k}]); Cmp.(['w' Names{k}])];
%     end
    for k = 1:length(Names)
        O.([fn{i} '_ECG_' Names{k}])= Cmp.(['w' Names{k}]);
    end
end

tot_Area_idx=find( min(min(State))*fs <= qrs_idx & qrs_idx <= max(max(State))*fs);

if tot_Area_idx(end)>length(RR)  %remove last index as it is removed in the RR calculation
    tot_Area_idx(end)=[];
end

Tot_rr=RR(tot_Area_idx);
O.ECG_Tot_HR=HRV.HR(Tot_rr);
O.ECG_Tot_SDNN=HRV.SDNN(Tot_rr);
O.ECG_Tot_SDSD=HRV.SDSD(Tot_rr);
O.ECG_Tot_RMSSD=HRV.RMSSD(Tot_rr);
O.ECG_Tot_pNN50=HRV.pNN50(Tot_rr);
[O.ECG_Tot_TRI,O.ECG_Tot_TINN]=HRV.triangular_val(Tot_rr);



% 
% t_idx=1:length(SaO2)/fs;
% for i = 1:length(fn)
%     IsRem=IsRem_in.(fn{i});
%     EEG_tmp2=[];
%     EEG_Power_spec2=[];
%     Under90=[];
%     Under80=[];
%     Under70=[];
%     Mean=[];
%     Len=[];
%     for s = 1:size(IsRem,1)
% 
%         %         xline(t_org(IsRem(s,1)),'g','LineWidth',2)
%         %         xline(t_org(IsRem(s,2)),'r','LineWidth',2)
%         EEG_idx=(IsRem(s,1)*fs:IsRem(s,2)*fs);
% 
%         %%Calculating features here
% 
%         Under90_v=nansum(SaO2(EEG_idx)<90)/60;%minutes
%         Under80_v=nansum(SaO2(EEG_idx)<80)/60;%minutes
%         Under70_v=nansum(SaO2(EEG_idx)<70)/60;%minutes
% 
%         Mean_v=nanmean(SaO2(EEG_idx));
%         Len_v=length(EEG_idx);
% 
% 
% 
%         %%
%         Under90=[Under90,Under90_v];
%         Under80=[Under80,Under80_v];
%         Under70=[Under70,Under70_v];
%         Mean=[Mean, Mean_v];
%         Len=[Len, Len_v];
% 
%         %EEG_tmp2=[EEG_tmp2;tmp_band_vec];
%         %EEG_Power_spec2=[EEG_Power_spec2;The_Power_spec'];
% 
% 
%     end
%     Wmean=nansum([Len.*Mean]/nansum(Len));
% 
%     %EEG_bandvec2=nanmean(EEG_tmp2,1);
% 
%     if isempty(Wmean) || Wmean==0
%         Wmean=NaN;
%         Under90=NaN;
%         Under80=NaN;
%         Under70=NaN;
%         %EEG_bandvec2=zeros(1,5)*NaN;
%         %EEG_Power_spec2=zeros(1,249)*NaN; %Change Here
%     end
%     Out_Mean=[Out_Mean; Wmean];
%     Out_90=[Out_90;sum(Under90)];
%     Out_80=[Out_80;sum(Under80)];
%     Out_70=[Out_70;sum(Under70)];
% 
%     %SaO2_Out=[SaO2_Out;EEG_bandvec2];
%     %SaO2_data=[SaO2_data;mean(EEG_Power_spec2,1)];
% end




end