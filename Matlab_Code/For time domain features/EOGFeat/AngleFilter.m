function [filt_wtR,filt_wtL]=AngleFilter(wt_R,wt_L)

for i = 6:10
    drR=wt_R.cfs{i}(:,:,1);
    diR=1i.*wt_R.cfs{i}(:,:,2);
    dcR=drR+diR;
    anglR=angle(dcR);
    
    drL=wt_L.cfs{i}(:,:,1);
    diL=1i.*wt_L.cfs{i}(:,:,2);
    dcL=drL+diL;
    anglL=angle(dcL);
    
    diffAngl=anglR-anglL;
    
    T_angle=0.9*pi;
    rem_idx=find(abs(diffAngl)<T_angle);
    
    filt_drR=drR;
    filt_diR=diR;
    filt_drR(rem_idx)=0;
    filt_diR(rem_idx)=0;
    
    filt_drL=drL;
    filt_diL=diL;
    filt_drL(rem_idx)=0;
    filt_diL(rem_idx)=0;
    
    filt_wtR=wt_R;
    filt_wtL=wt_L;
    filt_wtR.cfs{i}(:,:,1)=filt_drR;
    filt_wtR.cfs{i}(:,:,2)=imag(filt_diR);
    filt_wtL.cfs{i}(:,:,1)=filt_drL;
    filt_wtL.cfs{i}(:,:,2)=imag(filt_diL);
    
end
end