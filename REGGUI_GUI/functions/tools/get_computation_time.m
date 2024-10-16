function total_time_e = get_computation_time(t_end,t_start)

total_time_e = etime(t_end,t_start);
total_time = t_end-t_start;

disp(['Starting time: ',num2str(t_start(4)),'h',num2str(t_start(5))]);
disp(['Ending time: ',num2str(total_time(4)+t_start(4)),'h',num2str(total_time(5)+t_start(5))]);
disp(['Computation time: ',num2str(floor(total_time_e/60)),'m',num2str(round(mod(total_time_e,60))),'s']);

