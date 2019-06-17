function [val, maxInd] = findMaxAbove(trace,pickInd)

[val,maxInd] = max(trace(1:pickInd));
