function n = fs_n_omega(omega)

load const_SI;
lambda = 2*pi.*(SI.c)./omega;
n = quartz_n_lambda(lambda);