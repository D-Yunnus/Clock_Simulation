function [Slave_Phase, Phase_Difference] = Phase_Detector_Simulation(Master_Freq,Slave_Freq)

[t,n]=size(Slave_Freq);
N=n-1;

Master_Phase=zeros(1,N/t+1);
Slave_Phase=zeros(1,N/t+1);

for i=2:N/t+1
    Master_Area=+0.5*(Master_Freq(i)+Master_Freq(i-1))*t;
    Master_Phase(i)=Master_Area;
    Slave_Area=+0.5*(Slave_Freq(i)+Slave_Freq(i-1))*t;
    Slave_Phase(i)=Slave_Area;
end

Phase_Difference=Slave_Phase-Master_Phase;

end