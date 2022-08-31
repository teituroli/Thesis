function Hd = EOGFilter(Fs)
%EOGFILTER Returns a discrete-time filter object. The filter is designed
%from Julie A.E.Christensens article: Novel method for evaluation of eye
%movements in patients with narcolepsy

% Butterworth Highpass filter designed using FDESIGN.HIGHPASS.

% All frequency values are in Hz.
%Fs = 256;  % Sampling Frequency
N  = 4;    % Order
Fc = 0.1;  % Cutoff Frequency
% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.highpass('N,F3dB', N, Fc, Fs);
Hd = design(h, 'butter');

end
