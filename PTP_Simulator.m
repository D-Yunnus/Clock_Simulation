function x_slave=PTP_Simulator(master_time,slave_freq,slave_drift,diff_slave,mu_slave,sync_interval,delay,packet_loss_matrix)

% The function simulates the Precision Timing Protocol which at regular
% intervals correct the slave clock to align with the master clock.
% In the event that packets are loss during the communication, the slave
% clock enters a holdover mode which continue to accumulate error until the
% next iteration of PTP.

% Defining ticks.

[t,n]=size(slave_freq);
N=n-1;

% Slave clock parameters.

diff=diff_slave;
mu=mu_slave;

% Initialise slave clock time deviation.

x_slave=zeros(1,N/t+1);

% Gilbert-Elliot model of packet loss using a two state burst model.

mc=dtmc(packet_loss_matrix);
x0=ones(1,mc.NumStates);
current_state=1;

% Loop to iterate the slave clocks time deviation from true time at each
% tick.

for i=2:N/t+1
        
    % Modified clock simulation for slave clock time.
    % the slave_freq is obtained by syncE in white rabbit.

    Q=[(t)*diff(1)^2+(t^3/3)*diff(2)^2+(t^5/20)*diff(3)^2 , (t^2/2)*diff(2)^2+(t^4/8)*diff(3)^2 , (t^3/6)*diff(3)^2 ;
       (t^2/2)*diff(2)^2+(t^4/8)*diff(3)^2 , (t)*diff(2)^2+(t^3/3)*diff(3)^2 , (t^2/2)*diff(3)^2 ;
       (t^3/6)*diff(3)^2 , (t^2/2)*diff(3)^2 , (t)*diff(3)^2];

    noise=mvnrnd(zeros(1,3),Q,1);

    x_slave(i)=x_slave(i-1)+t*(mu(1)+slave_freq(i-1))+(t^2/2)*(mu(2)+slave_drift)+(t^3/6)*mu(3)+noise(1);
        
    % PTP message exchange to correct slave time.
    % Check whether to preform ptp at the given time.
    % Otherwise clock continues to deviate from true time in holdover mode
    % unti the next PTP cycle.

    if mod(i,sync_interval)==0

        % Check if packet makes the first-trip.

        X=simulate(mc,1,'X0',x0);
        current_state=X(2,current_state);

        if current_state==1

            % Check if packet makes the round-trip.

            X=simulate(mc,1,'X0',x0);
            current_state=X(2,current_state)+normrnd(0,10^-12);

            if current_state==1

                % PRP timestamping.

                t_1=master_time(i);
                t_2=x_slave(i)+delay+normrnd(0,10^-12);
                t_3=t_2;
                t_4=master_time(i)+2*delay++normrnd(0,10^-12);

                % Calculate one way time of flight.

                one_way_flight=0.5*((t_4-t_1)-(t_3-t_2));

                % Time offset between slave and master clock.

                offset=t_2-t_1-one_way_flight;

                % Correct slave time.

                x_slave(i)=x_slave(i)-offset;

            end
        end
    end
end

end