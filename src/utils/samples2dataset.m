function d = samples2dataset(cl)

s = cell2mat(cl);
d = struct2dataset(s);