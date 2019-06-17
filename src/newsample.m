function sample3 = newsample(sample1,sample2, theta)

%sample1 and sample2 are structs, theta is a scalar between 0 and 1

sample3 = sample1;
fields = fieldnames(sample1);

for i=1:numel(fields)
    sample3.(fields{i}) = sample1.(fields{i}) * theta + sample2.(fields{i}) * (1 - theta);
end


