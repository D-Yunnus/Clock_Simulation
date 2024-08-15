function x_slave=PTP_Simulator(master_time,slave_freq,slave_drift,diff_slave,mu_slave,time_interval,delta)

    [t,n]=size(slave_freq);
    N=n-1;
    diff=diff_slave;
    mu=mu_slave;

    x_slave=zeros(1,N/t+1);

    transition_matrix=[0.95 0.05 ; 0.95 0.05];
    mc=dtmc(transition_matrix);
    x0=ones(1,mc.NumStates);
    current_state=1;

    for i=2:N/t+1
        
        % Modified clock simulation.

        Q=[(t)*diff(1)^2+(t^3/3)*diff(2)^2+(t^5/20)*diff(3)^2 , (t^2/2)*diff(2)^2+(t^4/8)*diff(3)^2 , (t^3/6)*diff(3)^2 ;
       (t^2/2)*diff(2)^2+(t^4/8)*diff(3)^2 , (t)*diff(2)^2+(t^3/3)*diff(3)^2 , (t^2/2)*diff(3)^2 ;
       (t^3/6)*diff(3)^2 , (t^2/2)*diff(3)^2 , (t)*diff(3)^2];

        noise=mvnrnd(zeros(1,3),Q,1);

        x_slave(i)=x_slave(i-1)+t*(mu(1)+slave_freq(i-1))+(t^2/2)*(mu(2)+slave_drift)+(t^3/6)*mu(3)+noise(1);
        
        % PTP 'handshake'

        if mod(i,time_interval)==0

            t_1=master_time(i);
            
            X=simulate(mc,1,'X0',x0);
            current_state=X(2,current_state);

            t_2=x_slave(i)+delta+normrnd(0,400*10^-6)+1*(current_state-1);
            t_3=t_2;

            X=simulate(mc,1,'X0',x0);
            current_state=X(2,current_state);

            t_4=master_time(i)+2*delta+normrnd(0,400*10^-6)+1*(current_state-1);

            one_way_flight=0.5*((t_4-t_1)-(t_3-t_2));

            offset=t_2-t_1-one_way_flight;

            x_slave(i)=x_slave(i)-offset;
        end
    end
end