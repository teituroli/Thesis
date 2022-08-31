
function [SSC,Events]= LoadSSC_more(p_file,L,ftype)
%LOADSSC reads sleep stages from annotation files.
%   SSC = LOADSSC(p_file,L,ftype) loads the annotation file
%   specified in p_file and outputs the sleep stages.
%
%   Author: Andreas Brink-Kjaer.
%   Date: 17-Jun-2018
%
%   Input:  p_file, annotation file location
%           L, annotation length (should be based on PSG length
%           ftype, string of data source
%   Output: SSC, vector of sleep stages in 1 second bins.

% Unknown length
L_unk = 0;
if isempty(L)
    L = 20*60*60;
    L_unk = 1;
end

% Determine data type
if ~exist('ftype','var')
    if contains(p_file,'mros')
        ftype = 'mros';
    elseif contains(p_file,'cfs')
        ftype = 'cfs';
    end
end

switch ftype
    case 'kassel'
        hdr = lab_read_edf_hdr(p_file);
        fs = hdr.samplingrate;
        SSC = zeros(1,L);
        % N1 idx
        N1_e_idx = contains(hdr.events.TYP,{'Sleep_stage_1','Sleep_stage_N1'});
        N1_e_s_idx = round(hdr.events.POS(N1_e_idx)/fs);
        N1_idx = unique([double(N1_e_s_idx') + (1:30)-1]);
        % N2 idx
        N2_e_idx = contains(hdr.events.TYP,{'Sleep_stage_2','Sleep_stage_N2'});
        N2_e_s_idx = round(hdr.events.POS(N2_e_idx)/fs);
        N2_idx = unique([double(N2_e_s_idx') + (1:30)-1]);
        % N3 idx
        N3_e_idx = contains(hdr.events.TYP,{'Sleep_stage_3','Sleep_stage_N3'});
        N3_e_s_idx = round(hdr.events.POS(N3_e_idx)/fs);
        N3_idx = unique([double(N3_e_s_idx') + (1:30)-1]);
        % R idx
        R_e_idx = contains(hdr.events.TYP,{'Sleep_stage_R','Sleep_stage_REM'});
        R_e_s_idx = round(hdr.events.POS(R_e_idx)/fs);
        R_idx = unique([double(R_e_s_idx') + (1:30)-1]);
        % SSC vector
        SSC(N1_idx) = 1;
        SSC(N2_idx) = 2;
        SSC(N3_idx) = 3;
        SSC(R_idx) = 5;
        SSC = SSC(1:L);
    case {'cfs', 'mros'}
        % Read XML file
        s = xml2struct(p_file);
        ssc = s.CMPStudyConfig.SleepStages.SleepStage;
        SSC = cellfun(@(x) str2num(x.Text), ssc);
        % 30 second epochs to 1 second bins
        SSC = repelem(SSC,30);
        %%
        EventLabels={'Central Apnea','Obstructive Apnea','Mixed Apnea','SpO2 desaturation','SpO2 artifact','Arousal (ASDA)',	'Arousal ()','PLM (Left)','Limb Movement (Left)','PLM (Right)','Limb Movement (Right)'	,'Bradycardia',	'Tachycardia'	,'Blood pressure artifact','Body temperature artifact','Obstructive Hypopnea','Hypopnea','Central Hypopnea','Mixed Hypopnea'};
        EventName={'CA','OA','MA','SpO2_desat','SpO2_arti','Arousal_ASDA','Arousal_O','LM_L','PLM_L','LM_R','PLM_R','Brady','Tachy','BP_art','Temp_art','Obs_Hypo','Hypo','Central_hypo','Mixed_hypo'};
        All_Events=s.CMPStudyConfig.ScoredEvents.ScoredEvent;
        Events=struct();
        for k = 1:length(EventLabels)
            Indexes=[];
            for i = 1:length(All_Events)
                Name=All_Events{i}.Name.Text;
                if strcmp(Name,EventLabels{k})
                     Indexes= [Indexes i];
                end

            end
            Events.(EventName{k}).Indexes=Indexes;
        end
        EventStruct=s.CMPStudyConfig.ScoredEvents.ScoredEvent;
        for k = 1:length(EventName)
            index=Events.(EventName{k}).Indexes;
            for i = 1:length(index)
                Events.(EventName{k}).Start(i)=str2num(EventStruct{index(i)}.Start.Text);
                Events.(EventName{k}).Duration(i)=str2num(EventStruct{index(i)}.Duration.Text);
            end
        end
%%
    case 'wsc2'
        % Read csv file
        T = readtable(p_file,'FileType','text','Delimiter',';');
        T = T(:,end-1:end);
        T.Properties.VariableNames = {'Time','Event'};
        % Clear up empty event error in some Matlab versions
        T(cellfun(@isempty, T.Time),:) = [];
        % Get event times in seconds
        time_all = time2ind(T);
        if L_unk == 1
            L = ceil(time_all(end));
        end
        SSC = zeros(1,L);
        for i = 1:size(T,1)
            if contains(T(i,:).Event,'Stage - W') || contains(T(i,:).Event,'Stage - No Stage')
                SSC(1+round(time_all(i)):end) = 0;
            elseif contains(T(i,:).Event,'Stage - N1')
                SSC(1+round(time_all(i)):end) = 1;
            elseif contains(T(i,:).Event,'Stage - N2')
                SSC(1+round(time_all(i)):end) = 2;
            elseif contains(T(i,:).Event,'Stage - N3')
                SSC(1+round(time_all(i)):end) = 3;
            elseif contains(T(i,:).Event,'Stage - R')
                SSC(1+round(time_all(i)):end) = 5;
            end
        end
    case 'ssc'
        % Read .EVTS file
        [~,stageVec] = CLASS_codec.parseSSCevtsFile(p_file);
        % 30 second epochs to 1 second bins
        stageVec = repelem(stageVec,30);
        if length(stageVec) > L
            stageVec = stageVec(1:L);
        end
        SSC = stageVec;
        SSC(any(stageVec == 6:7,2)) = 0;
    case 'wsc'
        % Read .txt file
        fid = fopen(p_file);
        STA = textscan(fid,repmat('%s',1,3));
        fclose(fid);
        stageVec = str2num(cell2mat(STA{2}));
        % 30 second epoch to 1 second bins
        stageVec = repelem(stageVec,30);
        if length(stageVec) > L
            stageVec = stageVec(1:L);
        end
        SSC = stageVec;
        SSC(~any(cell2mat(arrayfun(@(x) stageVec == x,1:5,'Un',0)),2)) = 0;
end
end
