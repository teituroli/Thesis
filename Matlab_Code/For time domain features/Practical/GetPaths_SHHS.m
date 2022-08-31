function [Info,Annotation_path,Feature_path,issherlock]=GetPaths_SHHS

% [ParentFolderPath] = fileparts(pwd);
% 
% try
%     CodePath=[ParentFolderPath '/' 'Code_all'];
%     addpath(CodePath)
% catch
%     CodePath=[ParentFolderPath '\' 'Code_all'];
%     addpath(CodePath)
% end

issherlock=true;
%Recieving annotation path of all patients
%Annotation_path="C:\Users\Teitur\Desktop\School\10. Semester\Stanford Project\Data\polysomnography\annotations-events-profusion\visit1";
Annotation_path="/oak/stanford/groups/mignot/psg/NSRR/shhs/polysomnography/annotations-events-profusion/shhs1_all";
%Annotation_path="/oak/stanford/groups/mignot/psg/shhs/polysomnography/annotations-events-profusion/shhs1_all";
Annotation_directory=dir(fullfile(Annotation_path,'*.xml'));

if isempty(Annotation_directory)
    Annotation_path="C:\Users\Teitur\Desktop\School\10. Semester\Stanford Project\Code\SHH\Data";
    %Annotation_directory=dir(fullfile(Annotation_path,'*.xml'));
    issherlock=false;
end
%Recieving the feature path of all patients
%Feature_path="C:\Users\Teitur\Desktop\School\10. Semester\Stanford Project\Data\polysomnography\edfs\visit1";

Feature_path="/oak/stanford/groups/mignot/psg/NSRR/shhs/polysomnography/edfs/shhs1";
Feature_directory=dir(fullfile(Feature_path,'*.edf'));

if isempty(Feature_directory)
    Feature_path="C:\Users\Teitur\Desktop\School\10. Semester\Stanford Project\Code\SHH\Data";
    %Feature_directory=dir(fullfile(Annotation_path,'*.edf'));
end

try
    tmptab=load("/home/users/teitur/SHHS/ssh1-table.mat");
catch
    tmptab=load("C:\Users\Teitur\Desktop\School\10. Semester\Stanford Project\Code\SHH\ssh1-table.mat");
end

Info=tmptab.table;
end