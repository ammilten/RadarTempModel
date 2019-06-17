function [val, maxInd] = findMaxBelow(trace,pickInd)

[val,i] = max(trace(pickInd:end));
maxInd = pickInd + i - 1;