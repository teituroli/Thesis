%PlotBands
%Band_To_Table
%% A good start
% clc
% clear
% close all
% %% Load data
EOG_R_O=load('EOG_R_1-10_Bands.mat');
EOG_L_O=load('EOG_L_1-10_Bands.mat');
EEG_O=load('EEG_1-5_Bands.mat');
EMG_O=load('EMG_1-5_Bands.mat');
ECG_O=load('ECG_5_Bands.mat');

%set tight plot format
subplot = @(m,n,p) subtightplot (m, n, p, [0.04 0.05], [0.1 0.1], [0.1 0.01]);
%set figure size
set(groot, 'defaultFigureUnits', 'centimeters', 'defaultFigurePosition', [0 0 28 20]);

%if strcmp(Name,'ECG')
    ECGF=load('FrequencyVec_10-30.mat');
%elseif contains(Name,'EOG')
    EOGF=load('FrequencyVec_1-10_EOG.mat');
%else
    load('FrequencyVec_1-10.mat')
%end

figure(100);
%%
FN1=fieldnames(EEG_O.O);
FNECG=fieldnames(ECG_O.O);
Stages={'REM','N3','N2','N1','Wake'};
for i = 5%:length(FN1)-1
    
    WLvec=FrequencyVector.(FN1{i});
    WLECG=ECGF.FrequencyVector.(FNECG{1});
    WLEOG=EOGF.FrequencyVector.(FN1{i});
    
    
    for j = 1:size(EEG_O.O.(FN1{i}).REM,1)
        close figure 100
        h=figure(100);
        
        sgtitle([num2str(j) ' - Patient ID :' num2str(EEG_O.O.nsrrid(j))])
        subplot(3,2,1)
        for k = 1:length(Stages)
            semilogy(WLvec,EEG_O.O.(FN1{i}).(Stages{k})(j,:))
            hold on
        end
        title('EEG')
        ylabel('Normalized PSD')
        ylim([0.000001 inf])
        xlim([0 60])
        set(gca,'XTick',[]);
        
        subplot(3,2,2)
        for k = 1:length(Stages)
            semilogy(WLvec,EMG_O.O.(FN1{i}).(Stages{k})(j,:))
            hold on
        end
        title('EMG')
        ylim([0.000001 inf])
        xlim([0 60])
        set(gca,'XTick',[]);
        
        subplot(3,2,3)
        for k = 1:length(Stages)
            semilogy(WLECG,ECG_O.O.(FNECG{1}).(Stages{k})(j,:))
            hold on
        end
        title('ECG')
        ylabel('Normalized PSD')
        ylim([0.000001 inf])
        xlim([0 60])
        set(gca,'XTick',[]);
        
        subplot(3,2,4)
        for k = 1:length(Stages)
            semilogy(WLEOG,EOG_L_O.O.(FN1{i}).(Stages{k})(j,:))
            hold on
        end
        title('EOG_L')
        xlabel('Frequency, Hz')
        ylim([0.000001 inf])
        xlim([0 60])
        
        subplot(3,2,5)
        for k = 1:length(Stages)
            semilogy(WLEOG,EOG_R_O.O.(FN1{i}).(Stages{k})(j,:))
            hold on
        end
        title('EOG_R')
        xlabel('Frequency, Hz')
        ylabel('Normalized PSD')
        ylim([0.000001 inf])
        xlim([0 60])
        legend(Stages)
        1
        NameOut=[num2str(j) ' Patient_ID ' num2str(EEG_O.O.nsrrid(j))];
        path='C:\Users\Teitur\Desktop\School\Thesis\Code\Processing Data\Bands\Bands Plots SHHS';
        saveas(h, [path '\' NameOut '-SHHS.png'])
    end
    

end

%%
figure(103)

