%%mroz_sherlock

%all files used:
% [fList,pList] = matlab.codetools.requiredFilesAndProducts('mrOz_sherlock2.m');
% zip("tosherlockzip",fList)

function Features=ToSherlock_more(Info,Feature_path,Annotation_path,StateInv,Iterations,new_or_old,issherlock,Cohort)


tic
if issherlock
    a=parpool('local', str2num(getenv('SLURM_CPUS_PER_TASK')),'SpmdEnabled', false);
else
    try
      %  a=parpool(4);
    catch
    end
end

nontot=num2str(size(Info,1));
fprintf('Progress:\n');
fprintf(['\n' repmat('.',1,size(Info,1)) '\n\n']);

EEGNames = [{'REMs'},{'N4s'},{'N3s'},{'N2s'},{'N1s'},{'Wakes'}];
for w = 1:length(EEGNames)
    PowerSpects(size(Info,1)).(EEGNames{w})=[];
end

for i = 1:Iterations

    if contains(new_or_old,{'new'})

        %         Init_features=Features_calculator_3([],[],[],[],false,StateInv);
        %
        %         init_tab=table2cell(Info(1,:));
        %
        %         fn=fieldnames(Info);
        %         Features(size(Info,1)+1) = cell2struct([struct2cell(Init_features);repmat({[]},length(init_tab),1)],...
        %             [fieldnames(Init_features);fn(1:end-3)]);
        %
        %         Features(size(Info,1)+1).ID=size(Info,1)+1;
        Features(size(Info,1)+1).ID=size(Info,1)+1;

    elseif contains(new_or_old,{'old'})

        %numsave=num2str(length(dir(fullfile([Cohort 'State_' num2str(StateInv) 'Features*'])))-1);
        %load_name=[Cohort 'State_' num2str(StateInv) 'Features' numsave];

        try
            %    load(load_name)
        catch
            %             Init_features=Features_calculator_3([],[],[],[],false,StateInv);
            %
            %             init_tab=table2cell(Info(1,:));
            %
            %             fn=fieldnames(Info);
            %                         Features(size(Info,1)+1) = cell2struct([struct2cell(Init_features);repmat({[]},length(init_tab),1)],...
            %                             [fieldnames(Init_features);fn(1:end-3)]);
            %
            Features(size(Info,1)+1).ID=size(Info,1)+1;
        end

    else
        error( "Please enter either 'old' or 'new'\n" )
    end

    for p_num=1:size(Info,1)%sum(IDsToKeep_PI)% pnum11 is t4
        HDR=[];
        SSC=[];
        data_raw=[];
        Events=[];
        if isempty(Features(p_num).ID)
            %try
            %iter=iter+1;
            %tic          
            try
                if contains(Cohort,{'mrOz_'})
                    EEGqual=Info(p_num,:).EEG_quality;
                    if EEGqual>4
                    [HDR,SSC,data_raw,Events]=MrOs_HDR_SSC_more(Feature_path,Annotation_path,Info,p_num);
                    end
                elseif contains(Cohort,{'SHHS_'})
                    EEGqual=Info(p_num,:).EEG1qual;
                    if EEGqual>3
                    [HDR,SSC,data_raw,Events]=SHHS_HDR_SSC(Feature_path,Annotation_path,Info,p_num);
                    end
                else
                    fprintf('Cohort doesent exist')

                end
            catch
                err=lasterror;
                disp(err.message)
            end


            if ~isempty(HDR)
                try
                    %[tmpfeatures,EEG_Power_spec]=Features_just_bands(data_raw,HDR,SSC,Info(p_num,:),false);
                    [tmpfeatures]=Features_more_feat(data_raw,HDR,SSC,Info(p_num,:),false,Events);


                    tmpfeatures.ID=p_num;
                    
                    
                    %%
                    fn_myfeats=fieldnames(tmpfeatures);
                    fn_otherfeats=fieldnames(Info);
                    for z = 1:length(fn_myfeats)
                        if ~contains(fn_myfeats{z},'N4_')
                        Features(p_num).(fn_myfeats{z})=tmpfeatures.(fn_myfeats{z});
                        
                            
                        end
                    end
                    for z = 1:length(fn_otherfeats)-3
                        Features(p_num).(fn_otherfeats{z})=Info(p_num,:).(fn_otherfeats{z});
                    end
                    %%

%                     try
%                         Features(p_num) = cell2struct([struct2cell(tmpfeatures);tfeats'],...
%                             [fieldnames(tmpfeatures);fn_otherfeats(1:end-3)]);t
%                     catch
%                         Features(p_num).fail=1;
%                         lerr=lasterr;
%                         fprintf(lerr)
%                     end
%                     try
%                         PowerSpects(p_num).nsrrid=Info.nsrrid(p_num);
%                     catch
%                         try
%                             PowerSpects(p_num).nsrrid=Info.NSRRID(p_num);
%                         catch
%                             fprintf('No, the error is here')
%                             lerr=lasterr;
%                             fprintf(lerr)
%                         end
%                     end
%                     for w = 1:length(EEGNames)
%                         try
%                             PowerSpects(p_num).(EEGNames{w})=[PowerSpects(p_num).(EEGNames{w});EEG_Power_spec(w,:)];
%                         catch
%                             fprintf('error is here')
%                             lerr=lasterr;
%                             fprintf(lerr)
%                         end
%                     end
                    %toc(a(p_num))

                    %catch
                    %    disp(lasterror);

                    %end

                catch
                    err=lasterror;
                    disp(err.message)
                end
            end
        end
        %catch
        %    Features(p_num).fail=1;
        %end
        %toc
        Features(p_num).ID=p_num;


    end


    toc

    numsave=num2str(length(dir(fullfile([Cohort '_Features*']))));
    save([Cohort '_Features_' numsave],"Features")
    save(['PowerSpects_' Cohort '_' numsave],"PowerSpects")

    %save([Cohort num2str(StateInv) '_Rest_' numsave])
    fprintf('Features saved')

    fprintf(['\n \n \n \n \n \n \n \n ITERATION ' num2str(i) ' DONE \n \n \n \n \n \n \n \n'])

    new_or_old='old';
end
end
%end