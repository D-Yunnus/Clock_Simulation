function [time,freq,phase] = Network_Architecture_Simulation( N , t , Clocks , Logic_Matrix , Adjustment , Filter_Freq , Sync_Interval , Distance , Trans_Speed , P_Loss_Matrix )

% The function designs a network of clocks using white rabbit
% synchronisation to synchronise master clocks at higher stratum levels
% than slave clocks.
% The function returns a time and frequency matrix with each row i being
% the i clock in the network.

% The input clocks is a set of cells which hold information on the type of
% clock and the stratum level it is on.
% Example: {2, 'Caesium'} is a stratum 2 caesium clock.

No_of_Clocks=size(Clocks,2);

% Intialise time/freq matrices.

time=zeros(No_of_Clocks,N/t+1);
freq=zeros(No_of_Clocks,N/t+1);
phase=zeros(No_of_Clocks,N/t+1);

% Iterative loops for each clock in the network.

% The loop finds stratum 1 clocks (highest stratum clocks) and generates
% time and frequency for these clocks to then synchronise with lower level
% clocks.

for i=1:No_of_Clocks
    if Clocks{i}{1}==1
        ref_clock=Clock_Type(Clocks{i});
        diff_master=Diffusion_Coefficient_Estimator(ref_clock(4),ref_clock(6),ref_clock(5),ref_clock(7),0);
        [time(i,:),freq(i,:),~]=Clock_Simulator(N,t,ref_clock(1:3),diff_master,ref_clock(8:10));
    end
end

% Iterate between each clock and consider the j clocks that are connect to the i
% clock that act as slave clocks.
% Use white rabbit to generate time and frequency for the j slave clocks.
% Iterate down the levels systemmatically.

for i=1:No_of_Clocks-1
    for j=i+1:No_of_Clocks

        % Check the logic matrix to see if the (i,j) edge exists in the network topology.

        if Logic_Matrix(i,j)==1
            
            % Check that the stratum level of the j clock is higher than
            % the i level.

            if Clocks{i}{1}<Clocks{j}{1}
                Slave_Clock=Clock_Type(Clocks{j});
            end

            % Use White Rabbit.

            [time(j,:),freq(j,:),phase(j,:)]=White_Rabbit_Simulator(N,t,time(i,:),freq(i,:),Slave_Clock,Adjustment,Filter_Freq,Sync_Interval,Distance(i,j),Trans_Speed(i,j),P_Loss_Matrix);
        end 
    end
end

end