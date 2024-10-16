function r = energy2range_IBA(E)

r = exp( -0.013296*log(abs(E)).^3 + 0.15248*log(abs(E)).^2 + 1.2193*log(abs(E)) - 5.5064).*sign(E);