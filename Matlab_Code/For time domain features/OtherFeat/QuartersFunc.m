
function [VecQuarterIdx,StartSleep,StopSleep,LengthSleep]=QuartersFunc(SSC)
%Quarter length defined by total sleep devided into 4
% CHECK IF IT FINDS THE FIRST BEING 5 and so on.
StartSleep=find(SSC,1,'first');
StopSleep=find(SSC,1,'last');
%
try
LengthSleep = StopSleep-StartSleep; % seconds
QuartLength=floor(LengthSleep/4);
First_quarter = StartSleep:StartSleep+QuartLength;
Seconds_quarter = First_quarter(end)+1:First_quarter(end)+QuartLength;
Third_quarter = Seconds_quarter(end)+1:Seconds_quarter(end)+QuartLength;
Fourth_quarter = Third_quarter(end)+1:Third_quarter(end)+QuartLength;

VecQuarterIdx=[First_quarter(1),Seconds_quarter(1),Third_quarter(1),Fourth_quarter(1),Fourth_quarter(end)];

catch
SSC
error('Error in floor')

end
end