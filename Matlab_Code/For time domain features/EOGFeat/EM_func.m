function [OutTime,OutInterpEM]=EM_func(EOGR,EOGL,HDR,fs,InterpVal,SSC,toplot)
%This function calculates the Eye Movements of a patients using the entire
%sleeps EOG, both the left and the right channel. This calculation is based
%on Julie A.E.Christensens article: Novel method for evaluation of eye
%movements in patients with narcolepsy
%Input: EOGR, EOGL, HDR, and Fs. 
%Make sure the EOGR and EOGL only have the length that is needed for the
%analysis. For the MRoS the relevant data is only the first half of the
%entire length of the data. 

% Code Written by: Teitur Óli Kristjánsson
% Last edit: 28-09-2021

% Time vector used for plotting
t  =  seconds(0:1/fs:length(EOGR)/fs-1/fs)+datetime(HDR.starttime,'Format','HH.mm.ss');

% t only needed for plotting, might remove later.
Filt = EOGFilter(fs);

f_EOGR = filtfilt(Filt.sos,Filt.ScaleValues, EOGR);%doublecheck scale values (maybe just 1)
f_EOGL = filtfilt(Filt.sos,Filt.ScaleValues, EOGL);

%J_eli is the eliminated coeficcients, which were selected to be
%[1,2,3,4,5,11,12,13,14]. Meaning that the only ones investigated are the
%ones from 6 to 10. 
% The indeces are selected here in the correct manner. As is has to be in a
% vector inside a cell format for the dddtreecfs to work.

start_ind = 6;
stop_ind = 10;

length_ind = (stop_ind-start_ind+1);

outputindices = [];
outputindices{length_ind*2,1} = {[]};

% The 1 indices are for the real part, and 2 indicates the imaginary
for k = 1:length_ind
    outputindices{k*2-1} = [k+start_ind-1 1];
    outputindices{k*2} = [k+start_ind-1 2];
end

%The Dual Tree Wavelet Tranform is defined, as being a first stage Farras
%filter and a kingsbury Q-shift filter. The 3 indicates a Kingsubry Q-shift
%of 14 taps.
df  =  dtfilters('dtf3');
level = 14;

%The filter requires the signal to be exactly divisible with the 2^level.
%Which is why this is performed.

new_idx = floor(length(f_EOGR)/2^level)*2^level;
f_EOGR = f_EOGR(length(f_EOGR)-new_idx+1:end);%f_EOGR(1:new_idx);
f_EOGL = f_EOGL(length(f_EOGL)-new_idx+1:end);%f_EOGL(1:new_idx);
t_wave = t(1:length(f_EOGL));

%dddtree computes the wavelets. cplxdt defines the method. cplxdt is the
%only method possible for dtf3. 
wt_R  =  dddtree('cplxdt',f_EOGR,level,df{1},df{2});
wt_L  =  dddtree('cplxdt',f_EOGL,level,df{1},df{2});

%%
if toplot
%Visualizing the angle computation
    drR = wt_R.cfs{10}(:,:,1);
    diR = 1i.*wt_R.cfs{10}(:,:,2);
    dcR = drR+diR;
    anglR = angle(dcR);
    
    drL = wt_L.cfs{10}(:,:,1);
    diL = 1i.*wt_L.cfs{10}(:,:,2);
    dcL = drL+diL;
    anglL = angle(dcL);
    
    diffAngl = anglR-anglL;

    figure(200)
    
    sp1 = subplot(4,1,1);
    plot(t_wave,f_EOGR,'r','DisplayName','EOG-R')
    hold on
    plot(t_wave,f_EOGL,'b','DisplayName','EOG-L')
    legend('Location','northwest')
    
    sp2 = subplot(4,1,2);
    plot(1:length(drR),drR,'r','DisplayName','EOG-R component 10')
    hold on
    plot(1:length(drL),drL,'b','DisplayName','EOG-L component 10')
    legend('Location','northwest')
    
    sp3 = subplot(4,1,3);
    plot(1:length(anglR),anglR,'r','DisplayName','Angle R')
    hold on
    plot(1:length(anglL),anglL,'b','DisplayName','Angle L')
    legend('Location','northwest')
    
    sp4 = subplot(4,1,4);
    plot(1:length(diffAngl),diffAngl,'DisplayName','Difference')
    
    linkaxes([sp2,sp3,sp4],'x')
    legend('Location','northwest')
   
    
end
%         hold on; plot(t_wave,xapp_R,'b')

[filt_wtR,filt_wtL] = AngleFilter(wt_R,wt_L);

%% Plotting comparison of filter
%plotcomparison = false;
if toplot
    
    filt_xapp_R  =  dddtreecfs('r',filt_wtR,'cumind',outputindices);
    filt_xapp_L  =  dddtreecfs('r',filt_wtL,'cumind',outputindices);

    %outputindices for all taps
    start_ind = 1;
    stop_ind = 14;
    
    length_ind = (stop_ind-start_ind+1);
    
    outputindices_all = [];
    outputindices_all{length_ind*2,1} = {[]};
    
    for k = 1:length_ind
        outputindices_all{k*2-1} = [k+start_ind-1 1];
        outputindices_all{k*2} = [k+start_ind-1 2];
    end
    
    allxapp_R  =  dddtreecfs('r',filt_wtR,'cumind',outputindices_all);
    allxapp_L  =  dddtreecfs('r',filt_wtL,'cumind',outputindices_all);
    
    figure(400)
    
    xapp_R  =  dddtreecfs('r',wt_R,'cumind',outputindices);
    xapp_L  =  dddtreecfs('r',wt_L,'cumind',outputindices);

    sp1 = subplot(3,1,1);
    hold on
    plot(t_wave,allxapp_R,'DisplayName','R, all')
    plot(t_wave,xapp_R,'DisplayName','R 6-10')
    plot(t_wave,filt_xapp_R,'DisplayName','R, angle filtered')
    legend
    
    sp2 = subplot(3,1,2);
    hold on
    plot(t_wave,allxapp_L,'DisplayName','L, all')
    plot(t_wave,xapp_L,'DisplayName','L 6-10')
    plot(t_wave,filt_xapp_L,'DisplayName','L, angle filtered')
    legend
    
    sp3 = subplot(3,1,3);
    hold on
    plot(t_wave,filt_xapp_R,'DisplayName','R, angle filtered')
    plot(t_wave,filt_xapp_L,'DisplayName','L, angle filtered')
    legend
    
    linkaxes([sp1,sp2,sp3])
end

%%
%final filtered signal
filt_xapp_R  =  dddtreecfs('r',filt_wtR,'cumind',outputindices);
filt_xapp_L  =  dddtreecfs('r',filt_wtL,'cumind',outputindices);

%threshold of 600 \muV removed as Julie Indicates.
filt_xapp_R(filt_xapp_R>600) = 0;
filt_xapp_L(filt_xapp_L>600) = 0;

%The difference between the two EOG channels
A_diff = abs(filt_xapp_R-filt_xapp_L);

%feature tresholds
Pth = 92;
Ptresh = prctile(A_diff,Pth);
durhole = 2;
durEM = 2.5;

%The indicies where the threshold is passed for the first time, as well as
%when it goes below. 
A_diff(1)=0;
A_diff(end)=0;
idxl  =  A_diff>= Ptresh;


idx  =  find(idxl);
CrossUp  =  A_diff(idx-1)<Ptresh;
IdxUp = idx(CrossUp);

t_inv_up = t(IdxUp); %time instances where it goes above threshold

CrossDown  =  A_diff(idx+1)<Ptresh;
IdxDown = idx(CrossDown);
t_inv_down = t(IdxDown); %time instances where it goes below threshold
try
tinv = cat(1,t_inv_up,t_inv_down); %constructing a usefull matrix
catch
    fprintf('help')
end
t_new1 = tinv;

k = 1;
iter = 0;

%forloop that checks if there are gaps that should be filled. if they are,
%it is fixed. 
while iter ~= length(tinv)-1
    iter = iter+1;
    if (t_new1(1,k+1)-t_new1(2,k))<= seconds(durhole)
        t_new1(2,k) = t_new1(2,k+1);
        t_new1(:,k+1) = [];
        
    else
        k = k+1;
    end
end

%removes EM that are of too short a duration (durEM)
idxrem1 = [];
for k  =  1:length(t_new1)
    if (t_new1(2,k)-t_new1(1,k))<= seconds(durEM)
        idxrem1(length(idxrem1)+1) = k;
    end
end

t_new2 = t_new1;
t_new2(:,idxrem1) = [];

Tot_EM = sum(t_new2(2,:)-t_new2(1,:));

%plot3 = false;
if toplot
    
    figure(600)
    sp1 = subplot(7,1,1);
    hold on
    plot(t,EOGR,'r','DisplayName','EOG-R')
    plot(t,EOGL,'b','DisplayName','EOG-L')
    legend('Location','northwest')
    ylabel('Raw Signal, \mu V')
    set(gca,'Xticklabel',[]) 
    
    sp2 = subplot(7,1,2);
    hold on
    plot(t_wave,filt_xapp_R,'r','DisplayName','EOG-R - Filtered')
    plot(t_wave,filt_xapp_L,'b','DisplayName','EOG-L - Filtered')
    legend('Location','northwest')
    ylabel('Cleaned Signal, \mu V')
    set(gca,'Xticklabel',[]) 
    
    sp3 = subplot(7,1,3);
    hold on
    plot(t_wave,A_diff,'k','DisplayName','Difference')
    yline(Ptresh,'r--','DisplayName',['P_t_h ' num2str(Ptresh)],'LineWidth',1.5)
    legend('Location','northwest')
    ylabel('A_d_i_f_f, \mu V')
    set(gca,'Xticklabel',[]) 
    
    sp4 = subplot(7,1,4);
    combtime = [tinv(1,:) tinv(2,:)];
    combvals_tmp = [ones(length(tinv),1) zeros(length(tinv),1)];
    [b,I] = sort(combtime);
    combvals = combvals_tmp(I);
    stairs(b,combvals,'k')
    ylim([-0.5 1.5])
    ylabel('EM_c_a_n_d')
    set(gca,'Xticklabel',[]) 
    
    sp5 = subplot(7,1,5);
    combtime = [t_new1(1,:) t_new1(2,:)];
    combvals_tmp = [ones(length(t_new1),1) zeros(length(t_new1),1)];
    [b,I] = sort(combtime);
    combvals = combvals_tmp(I);
    stairs(b,combvals,'k')
    ylim([-0.5 1.5])
    ylabel('EM_c_a_n_d_1')
    set(gca,'Xticklabel',[]) 
    
    sp6 = subplot(7,1,6);
    combtime = [t_new2(1,:) t_new2(2,:)];
    combvals_tmp = [ones(length(t_new2),1) zeros(length(t_new2),1)];
    [b,I] = sort(combtime);
    combvals = combvals_tmp(I);
    stairs(b,combvals,'k')
    ylim([-0.5 1.5])
    ylabel('EM Vector')
    title(['Total EM time, ' num2str(round(minutes(Tot_EM)),2) ' minutes'])
    set(gca,'Xticklabel',[]) 
    
    %plotting hypnogram
    t_ssc  =  seconds(0:1:length(SSC)-1)+datetime(HDR.starttime,'Format','HH.mm.ss');
    sp7=subplot(7,1,7);
    stairs(t_ssc,SSC,'k');
    title('Hypnogram')
    ylabel('Sleep Score')
    linkaxes([sp1,sp2,sp3,sp4,sp5,sp6,sp7],'x')
    
    sgtitle('Eye Movement')
end
%combtime = [t_new2(1,:) t_new2(2,:)];
combtime = [t(1) t(1)+seconds(0.001) t_new2(1,:) t_new2(2,:) t(end)-seconds(0.001) t(end)];
combvals_tmp = [0 0 ones(length(t_new2),1)'  zeros(length(t_new2),1)' 0 0];
[b,I] = sort(combtime);
combvals = combvals_tmp(I);

%interpolating to be able to use later
%Currently there is an error of less than 0.1% when doing this, can be
%optimized, but then there is a sacrifice on the efficiency
dx=seconds(InterpVal);
OutTime=min(b):dx:max(b);
OutInterpEM=interp1(b,combvals,OutTime,'previous');


end
%%


