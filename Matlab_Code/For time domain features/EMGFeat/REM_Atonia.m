%% REM atonia index
function [Tot_MAE]=REM_Atonia(EMG_t,fs,HDR,States,Info,StartSleep,...
    StopSleep,SSC,toplot);
%based on https://onlinelibrary.wiley.com/doi/10.1111/jsr.12304

%init
% is_MAEsplit=zeros(1,4);
% is_MAEquart=zeros(1,4);
% isnot_MAEsplit=zeros(1,4);
% isnot_MAEquart=zeros(1,4);

statenames=fieldnames(States);


% Defining initial filters
%Filt1 = EMGFilter_lowpass(fs);
%Filt2 = EMGFilter_highpass(fs);

% h  = fdesign.highpass('N,F3dB', N, Fc, Fs);
% Hd = design(h, 'butter');
%Filt22 = designfilt('highpassiir','FilterOrder',20, ...
%          'PassbandFrequency',10,'PassbamndRipple',0.2, ...
%          'SampleRate',fs);

Filt2 = designfilt('highpassiir', ...       % Response type
       'StopbandFrequency',9, ...     % Frequency constraints
       'PassbandFrequency',10, ...
       'StopbandAttenuation',60, ...    % Magnitude constraints
       'PassbandRipple',0.2, ...
       'SampleRate',fs);               % Sample rate


Filt1 = designfilt('lowpassiir', ...        % Response type
       'PassbandFrequency',59, ...     % Frequency constraints
       'StopbandFrequency',61, ...
       'PassbandRipple',0.2, ...          % Magnitude constraints
       'StopbandAttenuation',60, ...
       'SampleRate',fs);  


d = designfilt('bandstopiir','FilterOrder',6, ...
    'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
    'DesignMethod','butter','SampleRate',fs);

%Applying filters
EMG_f1 = filtfilt(Filt1, EMG_t);
EMG_f2 = filtfilt(Filt2, EMG_f1);
EMG = filtfilt(d, EMG_f2);

for k = 1:length(statenames)

REM_idx=States.REM*fs;

end

%% Defining Baseline
WinL_s=60*30*fs;

%BaselineInv=zeros(1,length(EMG)/WinL_s-1);
iter=0;

t = seconds(0:1/fs:length(EMG)/fs-1/fs)+datetime(HDR.starttime,'Format','HH.mm.ss');


%Lightout_t=Info.Lights_Out+datetime(HDR.starttime,'Format','HH.mm.ss')-timeofday(datetime(HDR.starttime,'Format','HH.mm.ss'));
StartSleep=StartSleep*fs;
StopSleep=StopSleep*fs;

bwlength=60*30*fs; %fs * 60 to get minutes, then *30 to get half an hour

if toplot
    figure()
    plot(t,EMG);
    
    xline(t(StartSleep),'b','LineWidth',3)
    xline(t(StopSleep),'b','LineWidth',3)
    xline(t(StartSleep+bwlength),'y','LineWidth',3)
    xline(t(StopSleep-bwlength),'y','LineWidth',3)
end

iwl=30*fs; %inside window length
%REM_idx(1,1)=REM_idx(1,1)-60*45*fs;
not_MAE=0;
sum_MAE=0;

DSratio=256/fs; %NOTE THIS DOWNSAMPLE IS NOT A PART OF RUNE FRANDSENS CODE
W_length=ceil(51/DSratio);

for i = 1 : size(REM_idx,1)
    
    %inv = EMG( (REM_idx(i,1) - WinL_s) : REM_idx(i,2) + WinL_s);
    
    %EMG_ii=REM_idx(i,1)-WinL_s:30*fs:(REM_idx(i,2)+WinL_s);
    
    iter=1;
    
    %tjek hvor langt inde i signalet vi er
    if (StartSleep+bwlength)<REM_idx(i,1) && (StopSleep)>REM_idx(i,2)+bwlength
        if toplot
            xline(t(REM_idx(i,1)),'r','LineWidth',3)
        end%BaselineInv(iter) = median(EMG(EMG_ii(k):EMG_ii(k+1)));
        
        %fprintf("t1")
        EMG_ii=REM_idx(i,1)-bwlength:iwl:(REM_idx(i,2)+bwlength);
        
    elseif (StartSleep+bwlength)>REM_idx(i,1) && (StopSleep)>(REM_idx(i,2)+bwlength)
        %fix it lower end
        %fprintf("t2")
        %xline(t(REM_idx(i,1)),'g','LineWidth',3)
        dist=REM_idx(i,1)-(StartSleep);
        numbersbefore=floor(dist/iwl);
        numbersafter=120-numbersbefore;
        
        EMG_ii=REM_idx(i,1)-numbersbefore*iwl:iwl:(REM_idx(i,2)+numbersafter*iwl);
        
    elseif (StartSleep+bwlength)<REM_idx(i,1) && (StopSleep)<(REM_idx(i,2)+bwlength)
        %fix upper end
        %fprintf("t3")
        %xline(t(REM_idx(i,1)),'k','LineWidth',3)
        dist=(StopSleep)-REM_idx(i,2);
        numbersafter=floor(dist/iwl);
        numbersbefore=120-numbersafter;
        EMG_ii=REM_idx(i,1)-numbersbefore*iwl:iwl:(REM_idx(i,2)+numbersafter*iwl);
        if numbersafter==0
            mover=REM_idx(i,2)-EMG_ii(end)-W_length;
            EMG_ii=EMG_ii+mover;
            %EMG_ii=[EMG_ii REM_idx(i,2)-2*W_length]; %minus 2 windowlength as the AC window is shortened after
        end
    else
        fprintf("t4")
        if toplot
            xline(t(REM_idx(i,1)),'o','LineWidth',3)
        end
    end

    AC=ActivityWindow(EMG(EMG_ii(1):EMG_ii(end)+W_length),W_length);
    
    AC_EMG_ii=EMG_ii-EMG_ii(1)+1;
    
    for k = 1:length(EMG_ii)-1
        %iter = iter+1;
        %EMG_ii(k)
        
        BaselineInv(k) = median(AC(AC_EMG_ii(k):AC_EMG_ii(k+1)));% EMG(EMG_ii(k):EMG_ii(k+1)));
    end
    MADT=4;
    Threshold=min(BaselineInv)*MADT;
    
    %BaselineInv(iter) = median(EMG(i:i+WinL_s));
    IEI = 0.5;%0.3;
    minMAE = 0.3;
    
    t_ac=t(EMG_ii(1):EMG_ii(end));
    
    %The indicies where the threshold is passed for the first time, as well as
    %when it goes below.
    try
        AC_Inv=AC( (REM_idx(i,1) - EMG_ii(1)) : (REM_idx(i,2)-EMG_ii(1)) );
        t_AC_inv = t_ac( (REM_idx(i,1) - EMG_ii(1)) : (REM_idx(i,2)-EMG_ii(1)) );
    catch
        try
            AC_Inv=AC( (REM_idx(i,1) - EMG_ii(1)) : (REM_idx(i,2)-EMG_ii(1))-W_length );
            t_AC_inv = t_ac( (REM_idx(i,1) - EMG_ii(1)) : (REM_idx(i,2)-EMG_ii(1))-W_length );
        catch
            errmsg = lasterr;
            fprintf(errmsg)
        end
    end
    
    
    AC_Inv(end)=0;
    AC_Inv(1)=0;
    idxl  =  AC_Inv>= Threshold;
    
    idx  =  find(idxl);
    CrossUp  =  AC_Inv(idx-1)<Threshold;
    IdxUp = idx(CrossUp);
    
    t_inv_up = t_AC_inv(IdxUp); %time instances where it goes above threshold
    
    CrossDown  =  AC_Inv(idx+1)<Threshold;
    IdxDown = idx(CrossDown);
    
    t_inv_down = t_AC_inv(IdxDown); %time instances where it goes below threshold
    
    tinv = cat(1,t_inv_up,t_inv_down); %constructing a usefull matrix
    
    t_new1 = tinv;
    
    k = 1;
    iter = 1;
    
    %forloop that checks if there are gaps that should be filled. if they are,
    %it is fixed.
    while iter <= size(t_new1,2)-1
        try
            
            if (t_new1(1,k+1)-t_new1(2,k))<= seconds(IEI)
                t_new1(2,k) = t_new1(2,k+1);
                t_new1(:,k+1) = [];
                
            else
                k = k+1;
            end
        catch
            fprintf('catchme')
        end
        iter = iter+1;
    end
    
    %removes EM that are of too short a duration (durEM)
    idxrem1 = [];
    for k  =  1:size(t_new1,2)
        if (t_new1(2,k)-t_new1(1,k))<= seconds(minMAE)
            idxrem1(length(idxrem1)+1) = k;
        end
    end
    
    t_new2 = t_new1;
    t_new2(:,idxrem1) = [];
    
    %% MiniEpoch
    %time_in_rem=t(REM_idx(i,1))-t(REM_idx(i,2));
    %number_of_3_sec_epoch=sum(minutes(time_in_rem))/3;
    
    
    secondss=3;
    epoch_l=secondss*fs;
    %for k = 1:size(REM_idx,1)
    epochs=t(REM_idx(i,1):epoch_l:REM_idx(i,2));
    
    if isempty(t_new2)
        not_MAE=not_MAE+length(epochs);
    else
        combtime = [t_new2(1,:) t_new2(2,:)];
        combvals_tmp = [ones(length(t_new2),1) zeros(length(t_new2),1)];
        [b,I] = sort(combtime);
        combvals = combvals_tmp(I);
        
        %interpolating to be able to use later
        %Currently there is an error of less than 0.1% when doing this, can be
        %optimized, but then there is a sacrifice on the efficiency
        InterpVal=0.1;
        dx=seconds(InterpVal);
        OutTime=min(b):dx:max(b);
        try
            OutInterpEM=interp1(b,combvals,OutTime,'previous');
        catch
            errmsg = lasterr;
            fprintf(errmsg)
        end
        for s = 1:length(epochs)-1
            
            isidx=isbetween(OutTime,epochs(s),epochs(s+1));
            
            sum_a=sum(OutInterpEM(isidx));
            
            if sum_a>=(secondss*1/InterpVal)/2
                %         th = t(epochs(s:s+1))
                %         a = isbetween(t_new2,th(1),th(2))
                %         fprintf(num2str(sum(a)))
                %         if ~sum(a)==0
                %             fprintf('hello')
                %             fidx = find(a,1,'last');
                %             lidx = find(a,1,'first');
                %
                %         end
                %fprintf('works?')
                sum_MAE=sum_MAE+1;
%                 for w=1:4
%                     
%                     if Split(w)<epochs(s) && epochs(s)<Split(w+1)
%                         is_MAEsplit(w)=is_MAEsplit(w)+1;
%                     end
%                     
%                     if Quart_t(w)<epochs(s) && epochs(s)<Quart_t(w+1)
%                         is_MAEquart(w)=is_MAEquart(w)+1;
%                     end
%                     
%                 end
                
                
                
                
            else
                
                not_MAE=not_MAE+1;
%                 for w=1:4
%                     
%                     if Split(w)<epochs(s) && epochs(s)<Split(w+1)
%                         isnot_MAEsplit(w)=isnot_MAEsplit(w)+1;
%                     end
%                     
%                     if Quart_t(w)<epochs(s) && epochs(s)<Quart_t(w+1)
%                         isnot_MAEquart(w)=isnot_MAEquart(w)+1;
%                     end
%                     
%                 end
            end
        end
        
        %end
        
    end
    %%
    if toplot
        
        figure(600+i)
        sp1 = subplot(7,1,1);
        hold on
        plot(t,EMG_t,'r','DisplayName','EMG_o_r_g')
        legend('Location','northwest')
        ylabel('Raw Signal, \mu V')
        set(gca,'Xticklabel',[])
        
        sp2 = subplot(7,1,2);
        hold on
        plot(t,EMG_t,'r','DisplayName','EMG - Filtered')
        legend('Location','northwest')
        ylabel('Cleaned Signal, \mu V')
        set(gca,'Xticklabel',[])
        
        
        sp3 = subplot(7,1,3);
        hold on
        plot(t_AC_inv,AC_Inv,'k','DisplayName','Difference')
        yline(Threshold,'r--','DisplayName',['Threshold:' num2str(Threshold)],'LineWidth',1.5)
        legend('Location','northwest')
        ylabel('AC, \mu V')
        set(gca,'Xticklabel',[])
        
        
        sp4 = subplot(7,1,4);
        combtime = [tinv(1,:) tinv(2,:)];
        combvals_tmp = [ones(length(tinv),1) zeros(length(tinv),1)];
        [b,I] = sort(combtime);
        combvals = combvals_tmp(I);
        stairs(b,combvals,'k')
        ylim([-0.5 1.5])
        title('Inter Event Removal')
        set(gca,'Xticklabel',[])
        
        
        sp5 = subplot(7,1,5);
        combtime = [t_new1(1,:) t_new1(2,:)];
        combvals_tmp = [ones(length(t_new1),1) zeros(length(t_new1),1)];
        [b,I] = sort(combtime);
        combvals = combvals_tmp(I);
        stairs(b,combvals,'k')
        ylim([-0.5 1.5])
        title('Intra Event Removal')
        set(gca,'Xticklabel',[])
        
        
        sp6 = subplot(7,1,6);
        combtime = [t_new2(1,:) t_new2(2,:)];
        combvals_tmp = [ones(length(t_new2),1) zeros(length(t_new2),1)];
        [b,I] = sort(combtime);
        combvals = combvals_tmp(I);
        stairs(b,combvals,'k')
        ylim([-0.5 1.5])
        %ylabel('')
        title(['Total RSWA score, ' num2str(sum_MAE/not_MAE,2)])
        set(gca,'Xticklabel',[])
        
        
        %plotting hypnogram
        t_ssc  =  seconds(0:1:length(SSC)-1)+datetime(HDR.starttime,'Format','HH.mm.ss');
        sp7=subplot(7,1,7);
        stairs(t_ssc,SSC,'k');
        title('Hypnogram')
        ylabel('Sleep Score')
        ylim([-0.1 5.1])
        linkaxes([sp1,sp2,sp3,sp4,sp5,sp6,sp7],'x')
        xlim([t_AC_inv(1) t_AC_inv(end)])
        
        sgtitle('RMWA analysis')
    end
    
    
    
    %Tot_EM = sum(t_new2(2,:)-t_new2(1,:));
    
end

Tot_MAE = sum_MAE/not_MAE;
% MAE_quart=is_MAEquart./isnot_MAEquart;
% MAE_split=is_MAEsplit./isnot_MAEsplit;
% 
% MAE_quart(isnan(MAE_quart))=0;
% MAE_split(isnan(MAE_split))=0;

end
%% activity window
function AC=ActivityWindow(EMG,WL)

for i = 1:length(EMG)-WL
    Part=EMG(i:i+WL);
    AC(i)=max(Part)-min(Part);
end

end