%% EEG
function [O]...
    =EMG_features(EMG,Events,fs,IsRem_in)
%hold on


Names={'MAV','SSIN','RMS','Var','Var2','WL_n','Mav1','Mav2','SSC_n','TRI','TINN'};


fn=fieldnames(IsRem_in);

t_idx=(1:length(EMG))/fs;

for i = 1:length(fn)

    IsRem=IsRem_in.(fn{i});

    Len=[];

    for k = 1:length(Names)
        Cmp.(Names{k})=[];
    end

    for s = 1:size(IsRem,1)

        %         xline(t_org(IsRem(s,1)),'g','LineWidth',2)
        %         xline(t_org(IsRem(s,2)),'r','LineWidth',2)
        ST_idx=(IsRem(s,1)*fs:IsRem(s,2)*fs);
        
        Data=EMG(ST_idx);
        %%Calculating features here
        N=length(ST_idx);
        % https://reader.elsevier.com/reader/sd/pii/S0957417412001200?token=B16253B3FB1CBD761B3B678D193B9EB00C3B659F324841A2E7FD9C1BA3F9CFD9A694D3C0A5562143C4C6D29D69CBE5EE&originRegion=eu-west-1&originCreation=20220516100440
        % https://www.sciencedirect.com/science/article/pii/S0957417412001200
        % https://arxiv.org/ftp/arxiv/papers/0912/0912.3973.pdf
        Cmp.MAV_t= sum(abs(Data))/N;
        Cmp.SSIN_t=sum((Data.^2))/N;
        Cmp.RMS_t=rms(Data);
        Cmp.Var_t=var(Data);
        Cmp.Var2_t = 1/(N-1)*sum(Data.^2);
        
        summer_1=0;
        for s = 1:length(Data)

            if 0.25*N<= s && s <= 0.75*N
                summer_1=summer_1 + abs(Data(s));
            else 
                summer_1=summer_1 + 0.5*abs(Data(s));
            end

        end

        Cmp.WL_n_t=sum(abs(Data(2:end)-Data(1:end-1)))/N;
                


        Cmp.Mav1_t=1/N*summer_1;

        summer_2=0;
        for s = 1:length(Data)

            if 0.25*N<= s && s <= 0.75*N
                summer_2=summer_2 + abs(Data(s));
            elseif 0.25*N > s 

                summer_2=summer_2 + (4*s)/N * abs(Data(s));
            elseif 0.75*N < s
                summer_2=summer_2 + 4*(s-N)/N * abs(Data(s));
            end

        end

        Cmp.Mav2_t=1/N*summer_2;

        DN_1=Data(1:end-2);
        DN=Data(2:end-1);
        DN1=Data(3:end);

        Fx=((DN-DN_1).*(DN-DN1))*1000;

        Cmp.SSC_n_t=sum(Fx>30)/N; %threshold set at 30..
        
        [Cmp.TRI_t,Cmp.TINN_t]=HRV.triangular_val(Data);
%         Cmp.SaO2_U90_t=nansum(EMG(ST_idx)<90)/60;%minutes
%         Cmp.SaO2_U80_t=nansum(EMG(ST_idx)<80)/60;%minutes
%         Cmp.SaO2_U70_t=nansum(EMG(ST_idx)<70)/60;%minutes

%         Cmp.SaO2_mean_t=nanmean(EMG(ST_idx));
        Len_v=length(ST_idx);

%         for k = 1:length(Names)
%             Cmp.(Names{k})=[Cmp.(Names{k}); Cmp.([Names{k} '_t'])];
%         end

        %%
% 
         Len=[Len; Len_v];
        for s = 1:length(Names)
            Cmp.(Names{s})=[Cmp.(Names{s});Cmp.([Names{s} '_t'])];
        end


    end
%    Cmp.SaO2_mean=nansum([Len.*Cmp.SaO2_mean]/nansum(Len));


    if isempty(Cmp.(Names{1}))

        for k = 1:length(Names)
            Cmp.(Names{k})=NaN;
        end
    end

    for k = 1:length(Names)
        O.([fn{i} '_EMG_' Names{k}])= nansum([Len.*Cmp.(Names{k})]/nansum(Len));
    end


end


end