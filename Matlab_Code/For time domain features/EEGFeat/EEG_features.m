%% EEG
function [O]...
    =EEG_features(EEG,Events,fs,IsRem_in)
%hold on


varnames={'min','max','md','var','sd','am','re','le','sh','te','lrssv','mte','me','mcl','n2d','2d','n1d','1d','kurt','skew','hc','hm','ha','bpd','bpt','bpa','bpb','bpg','rba'};

Names={'Min','Max','Median','Var','Std','Mean','Renyi_Entropy','Log_Entropy','Shannon_Entropy','Tsallis_Entropy','Log_variation','Teager_energy','Mean_Energy','Curve_length','Second_diff_N','Second_diff','First_diff_N','First_diff','Kurtosis','Skewness','Hj_Complexity','Hj_Mobility','Hjort_activity','Delta','Theta','Alpha','Beta','Gamma','A_B_Ratio'};
fn=fieldnames(IsRem_in);

t_idx=(1:length(EEG))/fs;

        opts.order=4;
        opts.fs=fs;
        opts.alpha=2;

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
        
        Data=EEG(ST_idx);
        %%Calculating features here

        for z = 1 : length(varnames)
            Cmp.([Names{z} '_t'])=jfeeg(varnames{z},Data,opts);
        end


%         dEEG = diff([0;EEG]);
%         ddEEG = diff([0;dEEG]);
%         mx2 = mean(EEG.^2);
%         mdx2 = mean(dEEG.^2);
%         mddx2 = mean(ddEEG.^2);
% 
%         mob = mdx2 / mx2;
%         complexity = sqrt(mddx2 / mdx2 - mob);
%         mobility = sqrt(mob);


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
        O.([fn{i} '_EEG_' Names{k}])= nansum([Len.*Cmp.(Names{k})]/nansum(Len));
    end


end


end