function [HDR,SSC,data_raw,Events]=SHHS_HDR_SSC(Feature_path,Annotation_path,Info,p_num)

Feature_Full_Dir=fullfile(Feature_path,['shhs1-' num2str(Info.nsrrid(p_num)) '.edf']);
fprintf(['\b' num2str(p_num)  '|\n']);
Annotation_Full_Dir=fullfile(Annotation_path,['shhs1-' num2str(Info.nsrrid(p_num)) '-profusion.xml']);

if isfile(Feature_Full_Dir) && isfile(Annotation_Full_Dir)
    
    %if exist('HDR')~=1
    [HDR,data_raw]=LoadEDF_more(Feature_Full_Dir,'shhs');%Feature_Full_Dir,'wsc');
    
    [SSC,Events]=LoadSSC_more(Annotation_Full_Dir, size(data_raw,2),'mros');
    %end
    
elseif isfile(Feature_Full_Dir)
    error('There is only a HDR file')
    
elseif isfile(Annotation_Full_Dir)
    error('There is only a SSC file')
else
    error('None of the files exist')
end

end