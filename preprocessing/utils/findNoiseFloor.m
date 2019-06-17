function [noiseFloorInd, pctBelowThresh] = findNoiseFloor(trace)

windowSize = 150;
windowStep = 10;
threshPct = 0.3;
stopPctBelowThresh = 0.7;
startBuffer = 1;

noiseFloorThresh = (max(trace(startBuffer:end)) - min(trace(startBuffer:end))) * threshPct + min(trace(startBuffer:end));

% Initialize window sliding
windowStart = 1;
windowEnd = windowSize;

noiseFloorInd = nan;

pctBelowThresh = [];
ct = 1;
while windowEnd < length(trace)
    
    % Find number of points below threshhold
    nPtsBelowThresh = sum(trace(windowStart:windowEnd) < noiseFloorThresh);
    
    % Check against threshhold percent (break if necessary)
    pctBelowThresh(ct) = nPtsBelowThresh/windowSize;
    if pctBelowThresh(ct) > stopPctBelowThresh
        noiseFloorInd = windowStart + windowSize / 2;
        break
    end
    
    % Slide window
    windowStart = windowStart + windowStep;
    windowEnd = windowEnd + windowStep;
    
    ct = ct+1;
    
end


    
    
