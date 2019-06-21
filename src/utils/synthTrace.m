function tr = synthTrace(A, Ps, R, dz)
% N is attenuation profile
% Ps is the reference power
% R is the reflectivity

L = zeros(length(A),1);

for i=1:length(A)
    L(i) = trapz(A(end-i+1:end)) * dz * 2 / 1000;
end

ncells = 100;
x = linspace(-1,1,ncells);
y = (-x.^2 + 1) * R;

tr = zeros(length(L)+round(ncells/2),1);
tr(1:length(L)) = Ps - L;
tr(length(L)+1:end) = Ps - L(end);


tr(end-ncells+1:end) = tr(end-ncells+1:end) + y';
