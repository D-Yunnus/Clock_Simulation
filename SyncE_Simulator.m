function Slave_Freq = SyncE_Simulator( N , t , Master_Freq , X0_Slave , Diff_Slave , Mu_Slave , Adjustment , Filter_Freq , Packet_Loss_Matrix )

% The function simulates Synchronous Ethernet which phase locks a slave
% clocks frequency with the master clocks frequency.

% Initialise slave clock frequency.

Slave_Freq=zeros(1,N/t+1);

% Gilbert-Elliot Model for packet loss.
% The model uses a two-state Markov Chain to demostrate burst packet loss.

mc=dtmc(Packet_Loss_Matrix);
x0=ones(1,mc.NumStates);
current_state=1;

% Phase Lock Loop.
% The phase lock loop has slave frequency match master frequency for each
% time tick.

for i=2:N/t+1

    % Use Clock_Simulator.m to 
    % iterate next slave_frequency given the slave clock parameters.

    [~,y,~]=Clock_Simulator(t,t,X0_Slave,Diff_Slave,Mu_Slave);

    % Check if packet makes the first-trip.

    X=simulate(mc,1,'X0',x0);
    current_state=X(2,current_state);

    if current_state==1

        % Check if packet makes the round-trip.
        
        X=simulate(mc,1,'X0',x0);
        current_state=X(2,current_state);

        if current_state==1


            % Calculate error between master clock and slave clock frequencies.
    
            FreqError=Master_Freq(i)-y(end);

            % Adjust slave clock frequency to match master clock frequency.
            % Adjust_Power is the amount of error accounted for to match the
            % frequencies.
            % Note: Adjust_Power=1 means y_slave=y_master exactly.

            Slave_Freq(i)=y(end)+Adjustment*FreqError;
    
            % Iterate the intial frequency of the slave clock for the next
            % iteration of the loop.

            X0_slave(2)=Slave_Freq(i);

        end
    else

        % If the packet is lost then the slave clock is in holdover mode
        % for another iteration before syncE is performed again.

        Slave_Freq(i)=y(end);
        X0_slave(2)=Slave_Freq(i);
        
    end
end

% Filter slave noise through a low pass filter

Slave_Freq=lowpass(Slave_Freq,Filter_Freq);

end