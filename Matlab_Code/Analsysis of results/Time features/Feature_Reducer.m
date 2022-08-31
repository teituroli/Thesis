%%
clc
clear
close all

%% load data
Modality = 'EOG_L';

All_Features=readtable(['C:\Users\Teitur\Desktop\School\Thesis\Code\Python\Combined\Data\Combined_' Modality '.txt']);
A_Features=table2array(All_Features);

if strcmp(Modality,'EEG')
    Modality_states=GetState_EEG;
elseif strcmp(Modality,'EMG')
    Modality_states=GetState_EMG;
elseif strcmp(Modality,'EOG_R')
    Modality_states=GetState_EOG_R;
elseif strcmp(Modality,'EOG_L')
    Modality_states=GetState_EOG_R;
    
else
    error('Havent done that yet')
end


FN_EMG=fieldnames(All_Features);
FN_EMG=FN_EMG(1:end-3);

states=fieldnames(Modality_states);

%%
for j = 1:length(states)
Inv_state=states{j};
State_First=Modality_states.(Inv_state)(1,:);
State_second=Modality_states.(Inv_state)(2,:);
%%
EMG.Value.(Inv_state)(length(FN_EMG))=0;
for i = 1:length(FN_EMG)
    InvStr=FN_EMG{i};
    if contains(InvStr,(Inv_state))
        Num_Underscore=length(find(InvStr == '_'));
            if Num_Underscore==2
                Before_Num_Indx = find(InvStr == '_', 1, 'last')+1;
                EMG.Value.(Inv_state)(i)=str2double(InvStr(Before_Num_Indx:end));
            elseif Num_Underscore==3
                Before_Num_Indx = find(InvStr == '_', 2, 'last')+1;
                strall=InvStr(Before_Num_Indx(1):end);
                EMG.Value.(Inv_state)(i)=str2double(strrep(strall,'_','.'));
            else
                fprintf('stop')
            
            end
    else 
        EMG.Value.(Inv_state)(i)=99999; %high value to avoid using this later
    end
    
end
%%
Table_fieldnames={};
EMG.Combined=[];
for k = 1:length(State_First)
    Index_Saver=[];
    for i = 1:length(EMG.Value.(Inv_state))
        
        if State_First(k)<=EMG.Value.(Inv_state)(i) && State_second(k)>=EMG.Value.(Inv_state)(i)
            Index_Saver=[Index_Saver,i];
        end
        
    end

    EMG.Combined(:,k)=sum(A_Features(:,min(Index_Saver):max(Index_Saver)),2);
    Table_fieldnames(k)={[Modality '_' Inv_state '_' num2str(State_First(k)) '-' num2str(State_second(k))]};
end

T.(Inv_state) = array2table(EMG.Combined,...
    'VariableNames',Table_fieldnames);
end
%%
Out_table=[];
for i = 1:length(states)
   Out_table=[Out_table,T.(states{i})];
end

%%
error('Make sure u want to print')
%%
writetable(Out_table,['Combined_' Modality '_Reduced_Features'])
%%

function EMG=GetState_EMG()
EMG.REM(1,:)= [0     1     5    10    11    15    19    32];
EMG.REM(2,:)= [0     4     9    10    14    18    29    53];

EMG.N3(1,:)= [0     1     2     5     6     7     8    11   12    17    33    37    40    49    51];
EMG.N3(2,:)=[0     1     4     5     6     7    10    11    15    32    36    39    48    50    56];

EMG.N2(1,:)=[0     1     5    10    11    15    19    32];
EMG.N2(2,:)=[0     4     9    10    14    18    29    53];

EMG.N1(1,:)=[0     3     4     7     9    11    12    13    16    28    40    50    51    54    56];
EMG.N1(2,:)=[2     3     6     8    10    11    12    15    18    38    48    50    53    55    58];

EMG.Wake(1,:)=[0     2     4     5     6     9    10    12    17    25    36    49    51    54    56];
EMG.Wake(2,:)=[1     3     4     5     8     9    11    16    24    35    48    50    53    55    57];
end 

function EEG=GetState_EEG()
EEG.REM(1,:)=[1.0000    2.5000    3.5000    6.5000    9.0000   14.7500];
EEG.REM(2,:)= [2.0000    3.2500    6.2500    8.7500   13.5000   30.0000];
    
EEG.N3(1,:)=[0.7500    1.7500    3.2500    4.0000    6.7500    8.0000    9.7500   12.5000];
EEG.N3(2,:)=[1.5000    2.7500    3.7500    6.0000    7.7500    9.5000   10.7500   15.2500];
    
EEG.N2(1,:)=[0    0.5000    1.0000    1.7500    2.7500    4.5000    6.5000    9.5000   12.0000];
EEG.N2(2,:)=[ 0.2500    0.7500    1.2500    2.5000    3.7500    6.2500    9.2500   11.7500   15.0000];

EEG.N1(1,:)=[0.2500    2.7500    3.7500    4.2500    5.7500    8.2500    9.5000   13.5000];
EEG.N1(2,:)=[2.5000    3.5000    4.0000    5.5000    7.7500    9.2500   13.2500   30.0000];

EEG.Wake(1,:)=[0.2500    1.2500    1.7500    2.7500    3.2500    4.0000    8.5000    9.5000   10.0000   13.7500   26.2500];
EEG.Wake(2,:)=[1.0000    1.5000    2.5000    3.0000    3.7500    8.2500    9.2500    9.7500   11.7500   26.0000   30.0000];

end 
%%
function EOG_R=GetState_EOG_R()
EOG_R.REM(1,:)=[0.7500    1.7500    3.7500    9.7500   10.2500   14.7500]
EOG_R.REM(2,:)= [1.5000    3.2500    9.5000   10.0000   14.0000   15.0000]

EOG_R.N3(1,:)=   [ 0    0.2500    0.5000    0.7500    2.0000    6.0000    7.5000    9.7500   12.5000]
EOG_R.N3(2,:)=[0    0.2500    0.5000    1.7500    5.7500    7.2500    9.5000   12.0000   15.0000]

EOG_R.N2(1,:)=[0    0.7500    1.0000    1.2500    1.7500    3.2500    3.5000    6.7500    9.0000    9.7500   13.2500]
EOG_R.N2(2,:)=[0.5000    0.7500    1.0000    1.5000    3.0000    3.2500    6.5000    8.5000    9.5000   12.7500   14.7500]

EOG_R.N1(1,:)=[0    0.5000    1.0000    1.2500    2.5000    3.7500    4.2500    6.2500    8.0000    9.7500   10.5000   12.2500   13.2500]
EOG_R.N1(2,:)=[0.2500    0.7500    1.0000    2.2500    3.5000    4.0000    5.7500    7.7500    9.5000   10.0000   12.0000   13.0000   15.0000]

EOG_R.Wake(1,:)=[ 0    1.2500    2.0000    2.7500    3.2500    6.0000    9.5000   12.5000   14.5000]
EOG_R.Wake(2,:)=[1.0000    1.7500    2.5000    3.0000    5.7500    9.5000   11.2500   14.0000   15.0000]
end 

%%

function EOG_L=GetState_EOG_L()
EOG_L.REM(1,:)=[0.7500    1.7500    3.7500    9.7500   10.0000   12.5000   13.0000   14.0000]
EOG_L.REM(2,:)=[1.2500    3.5000    9.5000    9.7500   10.2500   12.7500   13.0000   15.2500]

EOG_L.N3(1,:)=[0    0.2500    0.5000    0.7500    2.0000    6.0000    8.0000   10.0000   10.5000   13.7500]   
EOG_L.N3(2,:)=[0    0.2500    0.5000    1.7500    5.7500    7.2500    9.5000   10.2500   12.7500   15.2500]
    
EOG_L.N2(1,:)=[0    0.2500    0.5000    0.7500    1.2500    1.7500    7.0000    9.0000    8.7500   14.0000]
EOG_L.N2(2,:)=[0    0.2500    0.5000    1.0000    1.5000    6.0000    8.7500    9.0000   13.5000   15.0000]

EOG_L.N1(1,:)=[0    0.7500    1.0000    1.2500    2.5000    3.7500    4.5000    6.0000    8.0000    9.7500   10.2500]
EOG_L.N1(2,:)=[0.5000    0.7500    1.0000    2.0000    3.5000    4.2500    4.7500    7.7500    8.7500   10.0000   15.0000]

EOG_L.Wake(1,:)=[0    1.0000    2.0000    2.2500    3.5000    5.7500    8.5000   13.0000   14.7500]
EOG_L.Wake(2,:)=[0.7500    1.7500    2.0000    3.2500    4.7500    7.5000   10.2500   14.0000   15.0000]
end 
