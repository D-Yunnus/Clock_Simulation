function [Slave_Time,Slave_Freq,Slave_Phase] = White_Rabbit_Simulator( N , t , Master_Time , Master_Freq , Slave_Clock , Adjustment , Filter_Freq , Sync_Interval , Distance , Speed , Packet_Loss_Matrix )

% The white rabbit function is a combination of Clock_Simulator.m,
% SyncE_Simulator.m and PTP_Simulator.m.
% The goal is to have sub nanosecond accuracy between the slave and master
% clock deviations.

% The clock parameters are encoded in the vector [X0_time,X0_freq,X0_drift,AVAR1,t1,AVAR2,t2,mu_1,mu_2,mu_3]

% Compute slave clock values.

diff_slave=Diffusion_Coefficient_Estimator(Slave_Clock(4),Slave_Clock(6),Slave_Clock(5),Slave_Clock(7),0);
mu_slave=Slave_Clock(8:10);
X0_slave=Slave_Clock(1:3);

% SyncE simulation.

Slave_Freq=SyncE_Simulator(N,t,Master_Freq,X0_slave,diff_slave,mu_slave,Adjustment,Filter_Freq,Packet_Loss_Matrix);

% Phase Correction (DTMD) simulation.

[Error_Phase_Difference,~,~,Slave_Phase]=Phase_Detector_Simulation(N,t,Master_Freq,Slave_Freq);

% PTP simulation.

Slave_Time=PTP_Simulator(N,t,Master_Time,Slave_Freq-Error_Phase_Difference,X0_slave(3),diff_slave,mu_slave,Sync_Interval,Distance,Speed,Packet_Loss_Matrix);

end