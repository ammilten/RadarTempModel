function sample3 = newsample2(sample1,sample2, theta)

%sample1 and sample2 are structs, theta is a scalar between 0 and 1

sample3 = sample1;
fields = fieldnames(sample1);

for i=1:numel(fields)
    sample3.(fields{i}) = sample1.(fields{i}) * theta + sample2.(fields{i}) * (1 - theta);
end

% If going frozen to frozen, keep Rth constant
% If going thawed to thawed, keep Rfr constant
% If going frozen to thawed, keep Rfr constant
% If going thawed to frozen, keep Rth constant
%   If sample3 is frozen, set sample3.Rth to sample1.Rth
%   If sample3 is thawed, set sample3.Rfr to sample1.Rfr

if sample3.bottomTemp >= 0
    sample3.Rfr = sample1.Rfr;
else 
    sample3.Rth = sample1.Rth;
end


