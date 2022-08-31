clc
clear
close all
%%
NName='MrOs_ECG_Spectrums.mat';
load(['C:\Users\Teitur\Desktop\School\Thesis\Code\Processing Data\Bands\Step1\' NName])



%% rem features

load('MrOs_nsrrid.mat') %nsrrid_left
nsrrids=[Out.Other.nsrrid];
Didxrem1(length(nsrrids))=false;
for i = 1:length(nsrrid_left)
    id=find(ismember(nsrrids,nsrrid_left(i)));
    if ~isempty(id)
        Didxrem1(id)=true;
    end
end
idxrem=logical(abs(Didxrem1-1));


%%
WLs=fieldnames(Out);

StageInv={'REM','N3','N2','N1','Wake'};

for i = 1:length(WLs)-1
    
    for j = 1:length(StageInv)
        
        for k = 1:size(Out.(WLs{i}).(StageInv{j}),1)
            Sig=Out.(WLs{i}).(StageInv{j})(k,:);
            % min max normalization
            Out2.(WLs{i}).(StageInv{j})(k,:)=Sig/sum(Sig);
        end
        Out2.(WLs{i}).(StageInv{j})(idxrem,:)=[];
    end

end

Out2.nsrrid=[Out.Other.nsrrid];
Out2.nsrrid(idxrem)=[];

%%
error('Run this seperately if you want to save the file')
%%
O=Out2;
save('MrOs_ECG_Bands_2','O')
%%







