%Bands Combiner SHHS

Files=dir(fullfile('SHHS__PSpect_*.mat'));

starter=load(Files(1).name);

FN1=fieldnames(starter.Pspects);

StageInv={'REM','N3','N2','N1','Wake'};
FN1{1}='ECG';
    %{'EEG'   }
    %{'EMG'   }
    %{'ECG'   }
    %{'EOG_L' }
    %{'EOG_R' }
    %{'nsrrid'}
for j = 1
    fprintf([FN1{j} '...\n'])
    Out=[];
    for i = 1:size(Files,1)
        fprintf([num2str(i) '\n'])
        Inv=load(Files(i).name); 
        
        Inv.Pspects.(FN1{j});
        
        FN_WL=fieldnames(Inv.Pspects.(FN1{j}).(StageInv{1}));
        for k=1:length(StageInv)
            
            for l = 11%6:length(FN_WL)%2%floor(length(FN_WL)/2)
                
                Tmp=Inv.Pspects.(FN1{j}).(StageInv{k}).(FN_WL{l});
                
                if ~isempty(Tmp)
                    Out.(FN_WL{l}).(StageInv{k})(i,1:length(Tmp))=Tmp;
                else
                   
                end
                
                
            end
            
            
        end
        Out.Other.nsrrid(i)=Inv.Pspects.nsrrid;
    end
    
    Out.Other.Frequency_Vectors=Inv.Pspects.(FN1{1}).Frequency_Vector;
    Out.Other.WindowLengths=Inv.Pspects.(FN1{1}).WL_Info;
    save([FN1{j} '_Spectrums'],'Out')
end

