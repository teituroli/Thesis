 function O=GetBands(Signal,fs,IsRem_in,WL_low,WL_high,Steps)
        
        fn=fieldnames(IsRem_in);
        
        Windows=WL_low:Steps:WL_high;
        
        for j = 1:length(Windows)
            WL=Windows(j);
        for i = 1:length(fn)
            
            IsRem=IsRem_in.(fn{i});
            
            Len=[];
            Signal_tmp=[];
            for s = 1:size(IsRem,1)
                
                %         xline(t_org(IsRem(s,1)),'g','LineWidth',2)
                %         xline(t_org(IsRem(s,2)),'r','LineWidth',2)
                P_indx=(IsRem(s,1)*fs:IsRem(s,2)*fs);
                
                Data=Signal(P_indx);
                %%Calculating features here

                if length(Data)/fs>35
                    window_length=fs*WL; % second epochs
                    overlap=window_length*3/4; %samples overlap
                    nfft=window_length;
                    [p_spec,Freq_V]=pwelch(Data,window_length,floor(overlap),nfft,fs);
                    
                    Len=[Len length(P_indx)];
                    
                    Signal_tmp=[Signal_tmp,p_spec];
                end
                

            end
                Signal_tmp=Signal_tmp';
                MeanSig=mean((Len'.*Signal_tmp)/sum(Len),1);
            %    Cmp.SaO2_mean=nansum([Len.*Cmp.SaO2_mean]/nansum(Len));
                
                O.(fn{i}).(['WL_' num2str(WL)])=MeanSig;
            
        end
        O.Frequency_Vector.(['WL_' num2str(WL)])=Freq_V;
        end
        O.WL_Info=Windows;
    end