
function BPG = jBandPowerGamma(X,opts)
% Parameters         
f_low  = 30;      % 30 Hz
f_high = 49;      % 64 Hz %changed to 49

% sampling frequency 
if isfield(opts,'fs'), fs = opts.fs; end

% Band power 
BPG = bandpower(X, fs, [f_low f_high]);
end

