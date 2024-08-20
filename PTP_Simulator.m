function Slave_Time = PTP_Simulator( N , t , Master_Time , Slave_Freq , Slave_Drift , Diff_Slave , Mu_Slave , Sync_Interval , Distance, Avg_Speed , Packet_Loss_Matrix )

% The function simulates the Precision Timing Protocol which at regular
% intervals correct the slave clock to align with the master clock.
% In the event that packets are loss during the communication, the slave
% clock enters a holdover mode which continue to accumulate error until the
% next iteration of PTP.

% Slave clock parameters.

diff=Diff_Slave;
mu=Mu_Slave;

% Define the delay time

Delay=Distance/normrnd(Avg_Speed,10^-2*3*10^-8);

% Initialise slave clock time deviation.

Slave_Time=zeros(1,N/t+1);

% Gilbert-Elliot model of packet loss using a two state burst model.

mc=dtmc(Packet_Loss_Matrix);
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

    Slave_Time(i)=Slave_Time(i-1)+t*(mu(1)+Slave_Freq(i-1))+(t^2/2)*(mu(2)+Slave_Drift)+(t^3/6)*mu(3)+noise(1);
        
    % PTP message exchange to correct slave time.
    % Check whether to preform ptp at the given time.
    % Otherwise clock continues to deviate from true time in holdover mode
    % unti the next PTP cycle.

    if mod(i,Sync_Interval)==0

        % Check if packet makes the first-trip.

        X=simulate(mc,1,'X0',x0);
        current_state=X(2,current_state);

        if current_state==1

            % Check if packet makes the round-trip.

            X=simulate(mc,1,'X0',x0);
            current_state=X(2,current_state);

            if current_state==1

                % PRP timestamping.

                t_1=Master_Time(i);
                t_2=Slave_Time(i)+Delay+normrnd(0,10^-12);
                t_3=t_2;
                t_4=Master_Time(i)+2*Delay+normrnd(0,10^-12);

                % Calculate one way time of flight.

                one_way_flight=0.5*((t_4-t_1)-(t_3-t_2));

                % Time offset between slave and master clock.

                offset=t_2-t_1-one_way_flight;

                % Correct slave time.

                Slave_Time(i)=Slave_Time(i)-offset;

            end
        end
    end
end

end