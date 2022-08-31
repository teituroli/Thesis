%% A good start
clc
clear
close all
%%
% subplot = @(m,n,p) subtightplot (m, n, p, [0.1 0.05], [0.11 0.15], [0.1 0.05]);
% %set figure size
% set(groot, 'defaultFigureUnits', 'centimeters', 'defaultFigurePosition', [1.0848 13.4938 21.3519 7.3025]);

%%
Study='MrOs';
Modality='EOG_L';%'EOG_L';
%modalities={'EEG','EMG','EOG_R','EOG_L','EOG_L2'};
FN={'REM','N3','N2','N1','Wake'}
%for ww = 1:length(modalities)
%Modality=modalities{ww};

type_models={'SE'};

%OutNames={'Single Effect','Multi Effect'};
%stages={'REM','N3','N2','N1','Wake'}
%for tm = 1:length(OutNames)
%    type_model=type_models{tm};
% OutName=OutNames{tm}%'Single Effect';

%% Get Cox results
for aa = 1:4
    
    for i = 1:length(FN)
        
        Stage=FN{i};
        modeltype=['Model_' num2str(aa)];;
        %sgtitle([Modality ' - SHAP and Cox - ' strrep(modeltype,'_',' ') ' - ' OutName]);
        
        cox_=readtable(['SE_Time_feats_all__' num2str(aa) '.csv']);
        try
            T = renamevars(cox_,["Var1"],["Name"]);
        catch
            T=cox_;
            try
                T.Properties.VariableNames={'Name','HR','LowerCI','UpperCI','P_val','DropPval','CI','LogLik'};
                T.LogLik=repmat(9,length(T.P_val),1);

            catch
                T.DropPval=repmat(1,length(T.P_val),1);
                T.Properties.VariableNames={'Name','HR','LowerCI','UpperCI','P_val','CI','LogLik','DropPval'};
            end
        end
        
        
        for rr= 1:size(T,1)
            T.Name{rr}=strrep(T.Name{rr},"`",'');
            T.Name{rr}=[ T.Name{rr}{1} ];
        end
        
        Cox_Tab=T;
        
        %% Splitting Name into relevant categories
        Names=Cox_Tab.Name;
        %RandFeat_indx=find(contains(Names,'RandomArray'))-1;
        State={}
        LL=[]
        UL=[]
        sleepstage={}
        Modality={}
        for ij = 1:length(Names) %-1 to  not include random feature
            
            
            
            
            %try
            InvStr=Names{ij};
            if strcmp(InvStr,'Age')
                break
            end
            if contains(Names{ij},'REM')
                sleepstage(ij)={'REM'}
            elseif contains(Names{ij},'N3')
                sleepstage(ij)={'N3'}
            elseif contains(Names{ij},'N2')
                sleepstage(ij)={'N2'}
            elseif contains(Names{ij},'N1')
                sleepstage(ij)={'N1'}
            elseif contains(Names{ij},'Wake')
                sleepstage(ij)={'Wake'}
            else
                sleepstage(ij)={'Other'}
            end
            
            if contains(Names{ij},'EEG')
                Modality(ij)={'EEG'}
            elseif contains(Names{ij},'ECG') || contains(Names{ij},'HR')
                Modality(ij)={'ECG'}
            elseif contains(Names{ij},'EMG')
                Modality(ij)={'EMG'}
            else
                Modality(ij)={'Other'}
            end
            % catch
            %end
            
            
        end
        try
            Cox_Tab.Sleepstage=sleepstage';
            Cox_Tab.Modality=Modality';
            %Cox_Tab.UL=UL';
            %Cox_Tab.LL=LL';

        catch
            Cox_Tab=Cox_Tab(1:ij-1,:);
            Cox_Tab.Modality=Modality';
            Cox_Tab.Sleepstage=sleepstage';

        end
        
        outname=['P_data_time_loglik/ P_data_Time_' modeltype '.csv'];
        writetable(Cox_Tab,outname)
    end
end
%end
