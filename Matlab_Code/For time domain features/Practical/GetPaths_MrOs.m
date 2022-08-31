function [Info,Annotation_path,Feature_path,issherlock]=GetPaths_MrOs()

issherlock=true;

%[ParentFolderPath] = fileparts(pwd);
%[~, ParentFolderName] = fileparts(ParentFolderPath) ;
%try
%    CodePath=[ParentFolderPath '/' 'Code_all'];
%    addpath(CodePath)
%catch
%    CodePath=[ParentFolderPath '\' 'Code_all'];
%    addpath(CodePath)
%end

%Recieving annotation path of all patients
%Annotation_path="C:\Users\Teitur\Desktop\School\10. Semester\Stanford Project\Data\polysomnography\annotations-events-profusion\visit1";

%Annotation_path="/oak/stanford/groups/mignot/psg/mros/polysomnography/annotations-events-profusion/visit1";
Annotation_path="/oak/stanford/groups/mignot/psg/NSRR/mros/polysomnography/annotations-events-profusion/visit1";
Annotation_directory=dir(fullfile(Annotation_path,'*.xml'));
if isempty(Annotation_directory)
    fprintf('\nChanged to local Annotation directory\n')
    Annotation_path="C:/Users/Teitur/Desktop/School/10. Semester/Stanford Project/Data/polysomnography/annotations-events-profusion/visit1";
    issherlock=false; 
end

%Feature_path="/oak/stanford/groups/mignot/psg/mros/polysomnography/edfs/visit1";
Feature_path="/oak/stanford/groups/mignot/psg/NSRR/mros/polysomnography/edfs/visit1";
Feature_directory=dir(fullfile(Feature_path,'*.edf'));

if isempty(Feature_directory)
    fprintf('\nChanged to local Feature directory\n')
    Feature_path="C:/Users/Teitur/Desktop/School/10. Semester/Stanford Project/Data/polysomnography/edfs/visit1";
end

try
VisitDataset=readtable("mros-visit1-dataset-0.3.0.csv");
catch
    fprintf('\nChanged to local VisitDataset\n')

    VisitDataset=readtable("C:/Users/Teitur/Desktop/School/10. Semester/Stanford Project/Data/mros-visit1-dataset-0.3.0.csv");
    
end
fn_VD=fieldnames(VisitDataset);
%find(contains(fn_VD,'poslprdp'))

try
PatientInfo=readtable("ap942.csv");
catch
    fprintf('\nChanged to local PatientInfo\n')
    PatientInfo=readtable("C:/Users/Teitur/Desktop/School/10. Semester/Stanford Project/Data/ap942.csv");
end
fn_PI=fieldnames(PatientInfo);

%To investigate
InvStr_PI={'M1BENZO','M1ADEPR','CFCAFF','TURSMOKE','HWBMI','EDUCC',...
    'NONWHITE','DADEAD','EFSTATUS','MAXAGE','FUVSDT','VSAGE1','NSRRID'...
    'ACTNAP2P','ACWASOMP','EPEPWORT','TMMSCORE','PASCORE','DPGDS15','MHDIAB',...
    'MHMI','MHSTRK','MHCOBPD','MHCHF','POPCSA80 ','POTMST2P','POAI_ALL','SITE'...
    'DACANCER','DACARDIO','DAOTHER'};
%{'VSAGE1'  'EFSTATUS'  'DADEAD'  'FUVSDT'  'MAXAGE'  'NSRRID'}
newNames_PI={'Benzo','AntiDepr','Caffine','SmokeStat','BMI','Education',...
    'NonWhite','IsDead','STATUS','FinalAge','Days_From_First_To_Last_Visit','Age_V1','NSRRID'...
    'Acti_Out_Of_bed','Acti_WASO','EPEPWORT','Mental_state','PASE_SCORE','Depression','Diabetes',...
    'Heart_Attack','Stroke','COPD','Cong_Heart_Failure','POPCSA80','N2_perc','Arousal_Index','SITE'...
    'Cancer','Cardio','OtherD'};

for l = 1:length(InvStr_PI)
InvLoc_PI=ismember(fn_PI,InvStr_PI(l));
PatientInfo.Properties.VariableNames(InvLoc_PI)=newNames_PI(l);
end
InvLoc_PI=ismember(PatientInfo.Properties.VariableNames,newNames_PI);
PI_all=PatientInfo(:,InvLoc_PI);

%To investigate
InvStr_VD={'nsrrid','posllatp','poremlat','m1slpmed','tudramt','postlotp','poslprdp','potmremp','potmrem','postontp','poqueeg1'};
%{'VSAGE1'  'EFSTATUS'  'DADEAD'  'FUVSDT'  'MAXAGE'  'NSRRID'}
newNames_VD={'nsrrid','Sleep_latency','REM_latency','SleepMed','WeeklyAlcohol','Lights_Out','Scored_sleepTime','P_REM_sleep','REM_sleepTime','Sleep_Onset','EEG_quality'};

for l = 1:length(InvStr_VD)
InvLoc_VD=ismember(fn_VD,InvStr_VD(l));
VisitDataset.Properties.VariableNames(InvLoc_VD)=newNames_VD(l);
end
InvLoc_VD=ismember(VisitDataset.Properties.VariableNames,newNames_VD);
VD_all=VisitDataset(:,InvLoc_VD);

%Check if patient is in both PI and VD
ID_VD=VD_all.nsrrid;
ID_PI=PI_all.NSRRID;
IDsToKeep_PI=zeros(length(ID_PI),1);

for i=1:length(ID_VD)
    IdxID=contains(ID_PI,ID_VD(i));
    IDsToKeep_PI=IdxID+IDsToKeep_PI;
end

IDsToKeep_PI=logical(IDsToKeep_PI);

NamesToKeep=ID_PI(IDsToKeep_PI);
IDsToKeep_VD=ismember(ID_VD,NamesToKeep);

VD=VD_all(IDsToKeep_VD,:);
PI=PI_all(IDsToKeep_PI,:);

Info=[VD PI];
Info(:,'NSRRID')=[];

end