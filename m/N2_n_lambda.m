function n = N2_n_lambda(x)

x = x/1e-6;

n = 1 + 68.5520E-6 + 32431.57E-6.*x.^2./(144.*x.^2-1);
