%Main_script

% [fList,pList] = matlab.codetools.requiredFilesAndProducts('MrOs_Main_9_M_bands.m');
% zip("tosherlockzip",fList)

%[ParentFolderPath] = fileparts(pwd);

%try
%    CodePath=[ParentFolderPath '/' 'Code_all'];
%    addpath(CodePath)
%catch
%    CodePath=[ParentFolderPath '\' 'Code_all'];
%    addpath(CodePath)
%end

folder = fileparts(which('MrOs_Main_9_M_bands.m')); 
addpath(genpath(folder));
fprintf(mfilename)

StateInv=7;
Iterations=1;
Cohort='mrOz_';

new_or_old='new';%'old';%new

[Info,Annotation_path,Feature_path,issherlock]=GetPaths_MrOs();

Features=ToSherlock_M_bands(Info,Feature_path,Annotation_path,...
    StateInv,Iterations,new_or_old,issherlock,Cohort);
