function [Features,Pspects]=Features_M_bands(data_raw,HDR,SSC,Info,toplot,Events)

%% This function combines the features wished to investigate.
% The features contain:
% Sleep onset,
% x Percent of REM Sleep in each quarter of the night. X
% x Measure the number of eye-movements per minutes of REM sleep
% Spectrogram of REM sleep for different queaters
% x Power-Spectrum (regular frequency bands, delta, alpha ...)
% x Percent power (percent power to reduce influence of sex)
% Median EEG power
% Variance of EEG power

% QUESTIONS
% meaning of this?
% How are we going to define REM SLEEP start and stop (We only take the
% only last 30 seconds, last epoch we only take 15 seconds).
% When you score REM for the last 15 seconds

%% Standard Easy Features
%EasyFeatStrings={'Age_V1','NonWhite','Education','BMI','SmokeStat',...
%    'WeeklyAlcohol','Caffine','AntiDepr','Benzo','SleepMed','Sleep_onset'...
%    ,'REM_sleepTime','REM_latency','Sleep_latency'};
%for i = 1:length(EasyFeatStrings)
%Features.(EasyFeatStrings{i})=Info.(EasyFeatStrings{i});
%end
%try
%    Features.BMI=round(str2num(strrep(Features.BMI{:}, ',', '.')),2);
%catch
%end

%%%%% Open only because of efficiency, delete later!!
%load('efficientOpening.mat')

%%
Features.fail=0;
%print_status=true;
SSC(SSC==4)=3;

SSC(~ismember(SSC,1:5))=0;
Names={'REM','N4','N3','N2','N1','Wake'};

[~,StartSleep,StopSleep,~]=QuartersFunc(SSC);

for i = 1:length(Names)
    if ~contains(Names{i},'Wake')
        State_idx.(Names{i})=Start_Stop(SSC,length(Names)-i);
    else
        State_idx.(Names{i})=Start_Stop(SSC(StartSleep:StopSleep),0);
        State_idx.(Names{i})=State_idx.(Names{i})+StartSleep-1;
    end
end

        %%
        try
            Index_EEG = contains(HDR.label,'EEG');
            fs_EEG=HDR.fs(Index_EEG);
            Downsample_Ratio=max(HDR.fs)/fs_EEG;
            tmp_data=data_raw(Index_EEG,1:end/Downsample_Ratio);
            
            Desired_fs=125;
            [p,q]=rat(Desired_fs/fs_EEG);
            %
            eeg_notch = designfilt('bandstopiir', ...       % Response type
                'PassbandFrequency1',57, ...    % Frequency constraints
                'StopbandFrequency1',58, ...
                'StopbandFrequency2',60, ...
                'PassbandFrequency2',62, ...
                'PassbandRipple1',0.2, ...         % Magnitude constraints
                'StopbandAttenuation',60, ...
                'PassbandRipple2',0.2, ...
                'SampleRate',Desired_fs);
            %
            HP_EEG = designfilt('highpassiir', ...       % Response type
                'StopbandFrequency',0.2, ...     % Frequency constraints
                'PassbandFrequency',0.3, ...
                'StopbandAttenuation',60, ...    % Magnitude constraints
                'PassbandRipple',0.2, ...
                'SampleRate',Desired_fs);               % Sample rate
            
            tmp_data=resample(tmp_data,p,q);
            
            tmp_data=filtfilt(eeg_notch, tmp_data); % Notch filter
            tmp_data=filtfilt(HP_EEG, tmp_data); % Highpass filter
            
            fs_EEG=Desired_fs;
            
            Pspects.EEG=GetBands(tmp_data,fs_EEG,State_idx,1,10,1);
            
            
        catch
            fprintf(['Error happened in EEG___' lasterr])
        end
        %% EMG Feature extraction
        try
            Index_EMG = contains(HDR.label,'EMG');
            fs_EMG=HDR.fs(Index_EMG);
            Downsample_Ratio=max(HDR.fs)/fs_EMG;
            tmp_data=data_raw(Index_EMG,1:end/Downsample_Ratio);
            
            Desired_fs=125;
            [p,q]=rat(Desired_fs/fs_EMG);
            
            tmp_data=resample(tmp_data,p,q);
            
            fs_EMG=Desired_fs;
            
            emg_lowpass = designfilt('lowpassfir','PassbandFrequency',57, ...
                'StopbandFrequency',58,'PassbandRipple',1, ...
                'StopbandAttenuation',80,'SampleRate',fs_EMG,'DesignMethod','kaiserwin');
            
            tmp_data=filtfilt(emg_lowpass, tmp_data);%Lowpass filter from 57
            
            Pspects.EMG=GetBands(tmp_data,fs_EMG,State_idx,1,10,1);
                       
        catch
            fprintf(['Error happened in EMG___' lasterr])
        end
        
        %% ECG Feature extraction
        % Pan-Thompkins
        try
            Index_ECG = contains(HDR.label,'ECG');
            fs_ECG=HDR.fs(Index_ECG);
            Downsample_Ratio=max(HDR.fs)/fs_ECG;
            tmp_data=data_raw(Index_ECG,1:end/Downsample_Ratio);
            
            Desired_fs=125; % SHHS fs of only 125
            [p,q]=rat(Desired_fs/fs_ECG);
            
            tmp_data=resample(tmp_data,p,q);
            
            fs_ECG=Desired_fs;
            
            
            
            
            %%
            % window_length=fs_ECG*30; % second epochs
            % overlap=window_length*3/4;
            % nfft=window_length;
            % [p_spec,fq]=pwelch(tmp_data,window_length,floor(overlap),nfft,fs_ECG);
            %
            % semilogy(fq,p_spec)
            %%
            
            % ecg_notch = designfilt('bandstopiir', ...       % Response type
            %        'PassbandFrequency1',57, ...    % Frequency constraints
            %        'StopbandFrequency1',58, ...
            %        'StopbandFrequency2',60, ...
            %        'PassbandFrequency2',62, ...
            %        'PassbandRipple1',0.2, ...         % Magnitude constraints
            %        'StopbandAttenuation',60, ...
            %        'PassbandRipple2',0.2, ...
            %        'SampleRate',Desired_fs);
            %
            % tmp_data=filtfilt(ecg_notch, tmp_data); % Notch filter
            %
            %as there is a problem with the first second of the data
            %seconds 5 to seconds 10 are replaced with seconds 0-5.
            %same with last 5 seconds
            inserter_low=tmp_data(5*fs_ECG+1:fs_ECG*10);
            inserter_high=tmp_data(end-fs_ECG*10:end-5*fs_ECG);
            %%
            
            tmp_data(1:fs_ECG*5)=inserter_low;
            tmp_data(end-fs_ECG*5:end)=inserter_high;

            Pspects.ECG=GetBands(tmp_data,fs_EMG,State_idx,10,30,2);
            
        catch
            fprintf(['Error happened in ECG___' lasterr])
        end
        %% EOG analysis
        try
            Index_EOGR = contains(HDR.label,'EOGR');
            Index_EOGL = contains(HDR.label,'EOGL');
            
            fs_EOG=HDR.fs(Index_EOGR);
            Downsample_Ratio=max(HDR.fs)/fs_EOG;
            
            EOGR=data_raw(Index_EOGR,1:end/Downsample_Ratio);
            
            Desired_fs=50; % SHHS fs of only 50
            [p,q]=rat(Desired_fs/fs_EOG);
            
            EOGR=resample(EOGR,p,q);
            
            EOGL=data_raw(Index_EOGL,1:end/Downsample_Ratio);
            EOGL=resample(EOGL,p,q);
            
            fs_EOG=Desired_fs;
            
            Pspects.EOG_L=GetBands(EOGL,fs_EOG,State_idx,1,10,1);
            Pspects.EOG_R=GetBands(EOGR,fs_EOG,State_idx,1,10,1);
            %

        catch
            fprintf(['Error happened in EOG___' lasterr])
        end
        
        
        
    end
%%
    function Split=SplitFunc(Quarters_idx,HDR,t,fs)
        
        t1=t(Quarters_idx(1)*fs);
        date1=datetime(HDR.starttime,'Format','HH.mm.ss');
        t2=date1-timeofday(date1) + hours(23) + minutes(59) + seconds(59);
        t3=t2+hours(2);
        t4=t3+hours(2);
        t5=t(Quarters_idx(5)*fs);
        
        Split=[t1,t2,t3,t4,t5];
    end


%%
    function REM_idx=Start_Stop(SSC,state)
        %% how long should the REM sleep be before it is included in the study
        SSC=[9,SSC,9];
        idx=SSC==state;
        FirstIdx=[];
        LastIdx=[];
        REM_idx=[];
        if sum(idx)>0
            for i=2:length(SSC)-1
                if idx(i)==1 && idx(i-1)==0 %first rem idx
                    FirstIdx=[FirstIdx; i];
                elseif idx(i-1)==1 && i==2 %In case first is sleep
                    FirstIdx=[FirstIdx; i];
                    
                elseif idx(i)==1 && idx(i+1)==0 %last rem idx
                    LastIdx=[LastIdx; i];
                elseif idx(i)==1 && i==length(SSC) %in case last is sleep
                    LastIdx=[LastIdx; i];
                end
                
            end
            
            % if isempty(LastIdx)
            %     LastIdx(end+1)=length(SSC);
            %     REM_idx=[FirstIdx,LastIdx];
            % else
            % try
            %     if FirstIdx(end) > LastIdx(end)
            %         LastIdx(end+1)=length(SSC);
            %         REM_idx=[FirstIdx,LastIdx];
            %     else
            %
            %     end
            % catch
            %     fprintf('help')
            % end
            % end
            try
                REM_idx=[FirstIdx,LastIdx]-1;
                
            catch
                fprintf('error in state index')
            end
            if isempty(REM_idx)
                %SSC
                fprintf('Still something wrong fucktard')
            end
            
        else
            fprintf('There is no state in this patient')
            REM_idx=[];
        end
        
        
    end
%%
    function [PS, f, t] = spect_eeg(data,fs)
        %spect_eeg Converts a 1D input data to a spectrogram
        %   [PS, f, t] = spect_eeg(data) transforms data to a spectrogram. The
        %   function also returns a frequency and time axis.
        %
        
        
        % Reshape data
        data = data(:);
        
        % Spectrogram parameters
        window = fs/2; % We want to detect down to 2 Hz frequencies at least.
        noverlap = round(window * 0.750);
        f = 0:0.5:50;
        
        % Compute STFT with a Hann window.
        [~,~,t,PS] = spectrogram(data, window, noverlap, f, fs);
        
        % Transform to dB
        PS = 10*log10(PS);
        
    end