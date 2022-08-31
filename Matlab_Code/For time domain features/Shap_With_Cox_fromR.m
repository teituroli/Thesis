%% A good start
clc
clear
close all
%%
subplot = @(m,n,p) subtightplot (m, n, p, [0.04 0.05], [0.1 0.1], [0.1 0.05]);
%set figure size
set(groot, 'defaultFigureUnits', 'centimeters', 'defaultFigurePosition', [0 0 28 20]);

%%
Study='MrOs';
Modality='EOG_L';%'EOG_L';
modalities={'EEG','EMG','EOG_R','EOG_L','EOG_L2'};

for ww = 1:length(modalities)
    Modality=modalities{ww};
    



    %modeltype='Model_4';
Confounders=['All_Confounders'];%['Age_sex_Confounders'] %'All_Confounders';
%ECG=10 %EEG 4_ EOG_R=10, EOG_L = 4, EMG = 1

if ~strcmp(Modality,'EOG_L2')
Filepath_shap=strcat('C:\Users\Teitur\Desktop\School\Thesis\Code\Python\Combined\Matrices\matrix_combined_',Modality,'.csv');
Filepath_data=strcat('C:\Users\Teitur\Desktop\School\Thesis\Code\Python\\Combined\For Matlab plot\','Data_For_Matlab_Combined',Modality,'.csv');
else
    Filepath_shap=strcat('C:\Users\Teitur\Desktop\School\Thesis\Code\Python\Combined\Matrices\matrix_combined_','EOG_L','.csv');
    Filepath_data=strcat('C:\Users\Teitur\Desktop\School\Thesis\Code\Python\\Combined\For Matlab plot\','Data_For_Matlab_Combined','EOG_L','.csv');

end
Tmp_shap=readtable(Filepath_shap);
Data_all=readtable(Filepath_data);

if sum(strcmp(Modality,{'EEG','ECG'}))
    reducer = 1%2;
    WL=4;
elseif sum(strcmp(Modality,{'EOG_R','EOG_L','EOG_L2'}))
    reducer = 1%1.6;
    WL=4;
elseif  strcmp(Modality,{'EMG'})
    reducer=1;
    WL=1;
end
% if strcmp(Modality,'EOG_L') 
%     Modality='EOG_L2';
% end

% if ~isempty(Confounders)
%     if strcmp(Modality,'EOG_L') 
%         Modality=['EOG_L2_' Confounders];
%     else
%         Modality=[Modality '_' Confounders];
%     end
%     %ALl Confounders
%     Cox_Tab=readtable(['C:\Users\Teitur\Desktop\School\Thesis\Code\Cox_results\All Confounders\' Modality '_Reduced_Cox_Output.csv']);
%     %Cox_Tab=readtable(['C:\Users\Teitur\Desktop\School\Thesis\Code\Cox_results\Age Sex Confounders\' Modality '_Reduced_Cox_Output.csv']);
% else
%     Cox_Tab=readtable(['C:\Users\Teitur\Desktop\School\Thesis\Code\Cox_results\No Confounders\' Modality '_Reduced_Cox_Output.csv']);
% end

%%
shap_all=Tmp_shap;
lengthshap=(size(shap_all,2)-1)/5;
%%
% REMs=shap_all(:,1:lengthshap);
% N3=shap_all(:,lengthshap+1:2*lengthshap);
% N2=shap_all(:,2*(lengthshap)+1:2*(lengthshap)+lengthshap);
% N1=shap_all(:,3*(lengthshap)+1:3*(lengthshap)+lengthshap);
% Wake=shap_all(:,4*(lengthshap)+1:end-1);
% RandomFeature=shap_all(:,end);

%%

%% for shap

Shap.REM=shap_all(:,1:lengthshap);
Shap.N3=shap_all(:,lengthshap+1:2*lengthshap);
Shap.N2=shap_all(:,2*(lengthshap)+1:2*(lengthshap)+lengthshap);
Shap.N1=shap_all(:,3*(lengthshap)+1:3*(lengthshap)+lengthshap);
Shap.Wake=shap_all(:,4*(lengthshap)+1:end-1);
Shap.RandomFeature=shap_all(:,end);

%% For data
Data.REM=Data_all(:,1:lengthshap);
Data.N3=Data_all(:,lengthshap+1:2*lengthshap);
Data.N2=Data_all(:,2*(lengthshap)+1:2*(lengthshap)+lengthshap);
Data.N1=Data_all(:,3*(lengthshap)+1:3*(lengthshap)+lengthshap);
Data.Wake=Data_all(:,4*(lengthshap)+1:end-1);
Data.RandomFeature=Data_all(:,end);

%%
inv=size(Shap.REM,1);
% figure(200)
%
FN=fieldnames(Shap);
%
%%
for i = 6
    DataToPlot=Shap.(FN{i}){1:inv,:};
    
    Mean_Shap=mean(abs(DataToPlot),1);
    LengthXaxis=(length(Mean_Shap)-1)/(1/0.1);
    
    
    DataToPlot=Shap.(FN{i}){1:inv,:};
    
    Mean_Shap=mean(abs(DataToPlot),1);
    Std_Shap=std(abs(DataToPlot),1);
    Error_high=Mean_Shap+Std_Shap;
    Error_low=Mean_Shap-Std_Shap;
    
    T=0:LengthXaxis;
    Mean_Shap=repmat(Mean_Shap,length(T),1)';
    Error_high=repmat(Error_high,length(T),1)';
    Error_low=repmat(Error_low,length(T),1)';
    %plot(T, Error_high, 'Color',COLORS.ERROR.(FN{i})/255  , 'LineWidth', 2);
    
    %plot(T, Error_low, 'Color',COLORS.ERROR.(FN{i})/255 , 'LineWidth', 2);
    T2 = [T, fliplr(T)];
    inBetween = [Error_high, fliplr(Error_low)];
    fill(T2, inBetween,'r','FaceAlpha',0.2,'LineStyle','none','HandleVisibility','off');
    hold on;
    PL1=plot(T,Mean_Shap,'r','DisplayName',['Random Feature Importance'],'LineWidth',2);
    %     hold on
    %     plot(T,Error_high,'DisplayName',[FN{i} ' Error SHAP'])
    %     plot(T,Error_low)
end
legend
%%

for i = 1:length(FN)
    Shap_bar.(FN{i}).Data=Shap.(FN{i}){1:inv,:};
    
    Shap_bar.(FN{i}).Mean_Shap=mean(abs(Shap_bar.(FN{i}).Data),1);
    Shap_bar.(FN{i}).Std_Shap=std(abs(Shap_bar.(FN{i}).Data),1);
    Shap_bar.(FN{i}).Error_high=Shap_bar.(FN{i}).Mean_Shap+Std_Shap;
    Shap_bar.(FN{i}).Error_low=Shap_bar.(FN{i}).Mean_Shap-Std_Shap;
    
    Shap_bar.(FN{i}).T=0:1/WL:(length(Shap_bar.(FN{i}).Mean_Shap)-1)/WL;
end


%%
%close all
figure(400)
sgtitle([Modality '- Feature importance'])
Model_series=[];
for i = 1:length(FN)-1
    subplot(3,2,i)
    Model_series=[Model_series;Shap_bar.(FN{i}).Mean_Shap];
    bar(Shap_bar.(FN{i}).T,Shap_bar.(FN{i}).Mean_Shap)
    yline(Shap_bar.RandomFeature.Mean_Shap,'r','-');
    yline(Shap_bar.RandomFeature.Error_high,'r','LineStyle','--')
    yline(Shap_bar.RandomFeature.Error_low,'r','LineStyle','--')
    title([FN{i}])
    ylabel('Mean(|Shap value|)')
    xlabel('Frequency, Hz')
end



%%
try
    close figure 500
catch
end
figure(500)
for i = 1:length(FN)-1
    subplot(3,2,i)
    if true
    if false %strcmp(Modality,'EEG')
        Names= {'Delta','Theta','Alpha','Beta','Gamma'};
        Seperator=[0,4,8,13,30];
        ax=gca;
        BottomLim=-0.9;%ax.YLim(1)*0.9;
        hold on
        line([Seperator; Seperator], [ones(length(Seperator),1)'*-10;ones(length(Seperator),1)'*10], 'YLimInclude', 'off','color','black');
        h=text(Seperator+3, repmat(BottomLim,length(Seperator),1) , Names, ...
            'VerticalAlignment', 'bottom');
        set(h(1),'Rotation',90);
        set(h(2),'Rotation',90);
        set(h(3),'Rotation',90);
        set(h(4),'Rotation',90);
        set(h(5),'Rotation',90);
    end
    for k = 1:round(size(Shap.(FN{i}){:,:},2)/reducer)
        invshap=Shap.(FN{i}){:,k};
        invdata=Data.(FN{i}){:,k};
        %LowerLimit=min(invdata);
        %UpperLimit=max(invdata);
        N=length(invdata);
        %c=linspace(LowerLimit,UpperLimit,N)';
        %c=linspace(1,1,N);
        %colormap(c)
        %rgb_table = squeeze(hsv2rgb(repmat(.5,[N 1]),linspace(0,1,N)',repmat(1,[N 1])));
        %colormap(rgb_table)
        longColormap=cool(N);
        [sorted_invdata,I]=sort(invdata);
        sorted_shap=invshap(I);
        %scatter(repmat(Shap_bar.(FN{i}).T(i),N,1),invshap,2,invdata,'filled')%,[],c,'filled')
        
        scatter(repmat(Shap_bar.(FN{i}).T(k),N,1),sorted_shap,2,longColormap,'filled')%,[],c,'filled')
        hold on
    end
    xlim([-0.5 Shap_bar.(FN{i}).T(k) + 7])%Shap_bar.(FN{i}).T(end)+1])
    ylim([-1 2])
    
    title([FN{i}])
    
    longColormap=copper(N);
    Randomfeat_shap=Shap.RandomFeature{:,:};
    Randomfeat_data=Data.RandomFeature{:,:};
    [sorted_invdata,I]=sort(Randomfeat_data);
    sorted_shap=Randomfeat_shap(I);
    scatter(Shap_bar.(FN{i}).T(k) + 4,sorted_shap,5,longColormap,'filled')%,[],c,'filled')
    end
    if sum(i == [1,3,5])
        ylabel('SHAP')
    end
    if sum(i == [4,5])
        xlabel('Frequency, Hz')
    else
        set(gca,'Xticklabel',[])
    end
    
    if sum(i == [2,4])
        set(gca,'Ytick',[])
    end
    
end


%%%CHANGE MEEE
%Stage ='REM'



type_models={'SE','ME'};

OutNames={'Single Effect','Multi Effect'};
stages={'REM','N3','N2','N1','Wake'}
for tm = 1:length(OutNames)
    type_model=type_models{tm};
    OutName=OutNames{tm}%'Single Effect';

%% Get Cox results 
for aa = 1:4


%% plot cox results
figg=figure(500)

Line1=[]
Line2=[]
Line3=[]
Line4=[]
Line5=[]

for i = 1:length(FN)-1

        Stage=FN{i}
        modeltype=['Model_' num2str(aa)];
        sgtitle([Modality ' - SHAP and Cox - ' strrep(modeltype,'_',' ') ' - ' OutName])
        
        cox_=readtable([type_model '_' Modality '_' Stage '_' modeltype '.csv'])
        try
            T = renamevars(cox_,["Var1"],["Name"])
        catch
            T=cox_
        end
        
        for rr= 1:size(T,1)
            T.Name{rr}=strrep(T.Name{rr},"`",'')
        end
        
        Cox_Tab=T;
        
        %%
        
        %% Splitting Name into relevant categories
        Names=Cox_Tab.Name;
        %RandFeat_indx=find(contains(Names,'RandomArray'))-1;
        State={}
        LL=[]
        UL=[]
        for ij = 1:length(Names) %-1 to  not include random feature
            %try
            InvStr=Names{ij}{1};
            if strcmp(InvStr,'Age')
                 break
            end
            if contains(Names{ij},'EOG')
                Underscores=strfind(InvStr,'_');
                dash=(strfind(InvStr, '-'));
                State(ij)={InvStr(Underscores(2)+1:Underscores(3)-1)};
                LL(ij) = str2double(InvStr(Underscores(3)+1:dash-1));
                UL(ij) = str2double(InvStr(dash+1:end));
            else
                Underscores=(find(InvStr == '_'));
                dash=(find(InvStr == '-'));
                State(ij)={InvStr(Underscores(1)+1:Underscores(2)-1)};
                LL(ij) = str2double(InvStr(Underscores(2)+1:dash-1));
                UL(ij) = str2double(InvStr(dash+1:end));
            end
            
            % catch
            %end
            
           
        end
    
    Colorr='r';
    lengther_states(i)=length(State)
    for k = 1:lengther_states(i)
        
            if Cox_Tab.P_val(k)<=0.05
                Colorr=[79 160 135]/255;
            else
                Colorr=[233 102 72]/255;
            end
            
            subplot(3,2,i)
            
            yyaxis right
            
            ylim([-1 2])
            %Mean Cox Line
            Area = [LL(k) UL(k)];
            Haz = [Cox_Tab.HR(k) Cox_Tab.HR(k)];
            Line1{i,k}=line(Area,Haz,'Color',Colorr,'LineWidth',1.3);
            
            %Upper and lower Line
            Haz_CI_L=([Cox_Tab.LowerCI(k) Cox_Tab.LowerCI(k)]);
            Haz_CI_U=([Cox_Tab.UpperCI(k) Cox_Tab.UpperCI(k)]);
            Line2{i,k}=line([mean(Area)+0.3 mean(Area)-0.3],Haz_CI_L,'Color',Colorr);
            Line3{i,k}=line([mean(Area)+0.3 mean(Area)-0.3],Haz_CI_U,'Color',Colorr);
            
            %Connecting lines
            Mean_to_Low=([Cox_Tab.HR(k) (Cox_Tab.LowerCI(k))]);
            Haz_CI_U=([Cox_Tab.HR(k) (Cox_Tab.UpperCI(k))]);
            Line4{i,k}=line([mean(Area) mean(Area)],Mean_to_Low,'Color',Colorr,'LineStyle','--');
            Line5{i,k}=line([mean(Area) mean(Area)],Haz_CI_U,'Color',Colorr,'LineStyle','--');
            
            yline(1)
            
    end
    if sum(i == [2,4,5])
        ylabel('Cox Hazard Ratio')
    end
    
    if sum(i == [1,3])
        set(gca,'Yticklabel',[])
    end
end


%error('tmpstop')
%%
lastsub=subplot(3,2,6);
colormap('cool')
names{256}='High';
names{1}='Low';
lastposit=lastsub.Position;
Labeledcolorbar=lcolorbar(names);

vertical=(lastposit(1)-lastposit(3))/2+lastposit(1)+0.09;
hori=lastposit(4)+lastposit(2)-0.24;
Labeledcolorbar.Position=[vertical    hori   0.0300    0.1557];
ylabel(Labeledcolorbar, 'Feature Value')
% Labeledcolorbar.Position=[0.5703, 0.1100, 0.3347, 0.05]
% Labeledcolorbar.OuterPosition= [0.5142 0.0306 0.4319 0.1886]
% Labeledcolorbar.InnerPosition=[0.5142 0.0306 0.4319 0.1886]

%c=colorbar;
%c.Ticks=[]
set(lastsub,'Visible','off');

% c = linspace(1,10,length(x));
% scatter(x,y,[],c,'filled')
% colorbar
% colormap jet


%% save figure
set(figg,'Units','Inches');
pos = get(figg,'Position');
set(figg,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
Savename=[Modality '_' modeltype '_Cox_results_' OutName]; 
print(figg,Savename,'-dpdf','-r0')


%%
for i = 1:length(FN)-1
    for k = 1:lengther_states(i)
        
        delete(Line1{i,k})
        delete(Line2{i,k})
        delete(Line3{i,k})
        delete(Line4{i,k})
        delete(Line5{i,k})
    end
end

end
end
end