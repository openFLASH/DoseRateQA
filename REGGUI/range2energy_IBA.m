function E = range2energy_IBA(r)



E = exp( 0.0015739*log(abs(r)).^3 - 0.004027*log(abs(r)).^2 + 0.55919*log(abs(r)) + 3.4658 ).*sign(r);