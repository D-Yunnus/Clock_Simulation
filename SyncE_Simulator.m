function [x_master,y_master,y_slave] = SyncE_Simulator(N,t,X0_master,diff_master,mu_master,X0_slave,diff_slave,mu_slave,adjustment,filter_freq,packet_loss_matrix)

% The function simulates Synchronous Ethernet which phase locks a slave
% clocks frequency with the master clocks frequency.

% Use Clock_Simulator.m to obtain a master clock frequency.

[x_master,y_master,~]=Clock_Simulator(N,t,X0_master,diff_master,mu_master);

% Initialise slave clock frequency.

y_slave=zeros(1,N/t+1);

% Gilbert-Elliot Model for packet loss.
% The model uses a two-state Markov Chain to demostrate burst packet loss.

mc=dtmc(packet_loss_matrix);
x0=ones(1,mc.NumStates);
current_state=1;

% Phase Lock Loop.
% The phase lock loop has slave frequency match master frequency for each
% time tick.

for i=2:N/t+1

    % Use Clock_Simulator.m to 
    % iterate next slave_frequency given the slave clock parameters.

    [~,y,~]=Clock_Simulator(t,t,X0_slave,diff_slave,mu_slave);

    % Check if packet makes the first-trip.

    X=simulate(mc,1,'X0',x0);
    current_state=X(2,current_state);

    if current_state==1

        % Check if packet makes the round-trip.
        
        X=simulate(mc,1,'X0',x0);
        current_state=X(2,current_state);

        if current_state==1


            % Calculate error between master clock and slave clock frequencies.
    
            FreqError=y_master(i)-y(end);

            % Adjust slave clock frequency to match master clock frequency.
            % Adjust_Power is the amount of error accounted for to match the
            % frequencies.
            % Note: Adjust_Power=1 means y_slave=y_master exactly.

            y_slave(i)=y(end)+adjustment*FreqError;
    
            % Iterate the intial frequency of the slave clock for the next
            % iteration of the loop.

            X0_slave(2)=y_slave(i);

        end
    else

        % If the packet is lost then the slave clock is in holdover mode
        % for another iteration before syncE is performed again.

        y_slave(i)=y(end);
        X0_slave(2)=y_slave(i);
        
    end
end

% Filter slave noise through a low pass filter

y_slave=lowpass(y_slave,filter_freq);

end