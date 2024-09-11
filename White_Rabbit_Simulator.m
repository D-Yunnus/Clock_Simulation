function [Slave_Time,Slave_Freq,Slave_Phase] = White_Rabbit_Simulator( N , t , Master_Time , Master_Freq , Slave_Clock , Adjustment , Filter_Freq , Sync_Interval , Distance , Speed , Packet_Loss_Matrix )

% The white rabbit function is a combination of Clock_Simulator.m,
% SyncE_Simulator.m and PTP_Simulator.m.
% The goal is to have sub nanosecond accuracy between the slave and master
% clock deviations.

% The clock parameters are encoded in the vector [X0_time,X0_freq,X0_drift,AVAR1,t1,AVAR2,t2,mu_1,mu_2,mu_3]

% SyncE simulation.

Slave_Freq=SyncE_Simulator(N,t,Master_Freq,Slave_Clock,Adjustment,Filter_Freq,Packet_Loss_Matrix);

% Phase Correction (DTMD) simulation.

[Error_Phase_Difference,~,~,Slave_Phase]=Phase_Detector_Simulation(N,t,Master_Freq,Slave_Freq);

% PTP simulation.

Slave_Time=PTP_Simulator(N,t,Master_Time,Slave_Freq-Error_Phase_Difference,Slave_Clock,Sync_Interval,Distance,Speed,Packet_Loss_Matrix);

end