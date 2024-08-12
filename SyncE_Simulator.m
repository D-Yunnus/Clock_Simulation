function [y_master,y_slave] = SyncE_Simulator(N,t,X0_master,diff_master,mu_master,X0_slave,diff_slave,mu_slave,Adjustment_Power)

% The simulator simulates Synchronous Ethernet which phase locks a slave
% clocks frequency with the master clocks frequency.

% Use Clock_Simulator.m to obtain a master clock frequency.

[~,y_master,~]=Clock_Simulator(N,t,X0_master,diff_master,mu_master);

% Initialise slave clock frequency.

y_slave=zeros(X0_slave(2),N/t+1);

% Phase Lock Loop.
% The phase lock loop has slave frequency match master frequency for each
% time tick.

for i=2:N/t+1

    % Use Clock_Simulator.m to 
    % iterate next slave_frequency given the slave clock parameters.

    [~,y,~]=Clock_Simulator(t,t,X0_slave,diff_slave,mu_slave);

    % Calculate error between master clock and slave clock frequencies.

    FreqError=y_master(i)-y(end);

    % Adjust slave clock frequency to match master clock frequency.
    % Adjust_Power is the amount of error accounted for to match the
    % frequencies.
    % Note: Adjust_Power=1 means y_slave=y_master exactly.

    y_slave(i)=y(end)+Adjustment_Power*FreqError;
    
    % Iterate the intial frequency of the slave clock for the next
    % iteration of the loop.

    X0_slave(2)=y_slave(i);
end
end