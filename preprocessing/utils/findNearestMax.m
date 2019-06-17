function maxInd = findNearestMax(trace,pickInd)

% Initialize output (defaults to pick)
maxInd = pickInd;

% Initialize attempt
testInd = pickInd + 1;

while testInd + 1 < length(trace)

    %If Function starts decreasing then break the loop
    if trace(testInd + 1) < trace(testInd)
        maxInd = testInd + 1;
        break
    end
    testInd = testInd + 1;
end

