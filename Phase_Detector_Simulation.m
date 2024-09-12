function [Error_Phase_Difference,Phase_Difference,Master_Phase,Slave_Phase] = Phase_Detector_Simulation(N,t,Master_Freq,Slave_Freq)

Master_Phase=zeros(1,N/t+1);
Slave_Phase=zeros(1,N/t+1);
Error_Master_Phase=zeros(1,N/t+1);
Error_Slave_Phase=zeros(1,N/t+1);

Master_Area=0;
Slave_Area=0;

for i=2:N/t+1

    Error_Master_Phase(i)=0.5*(Master_Freq(i)+Master_Freq(i-1))*t;
    Master_Area=Master_Area+Error_Master_Phase(i);
    Master_Phase(i)=Master_Area;

    Error_Slave_Phase(i)=0.5*(Slave_Freq(i)+Slave_Freq(i-1))*t;
    Slave_Area=Slave_Area+Error_Slave_Phase(i);
    Slave_Phase(i)=Slave_Area;

end

Phase_Difference=Slave_Phase-Master_Phase;
Error_Phase_Difference=Error_Slave_Phase-Error_Master_Phase;

end