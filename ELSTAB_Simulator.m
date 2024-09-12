function [Slave_Time,Corrected_Freq,Corrected_Phase,Master_Time,Master_Freq] = ELSTAB_Simulator( N , t , Master_Clock , Master_Freq , Delay , Delay_Uncertainty , alpha , beta , Filter_Freq , Distance , Speed )

% Initialise values.

Master_Freq=zeros(1,N/t+1);
Master_Err=zeros(1,N/t+1);
Master_Phase=zeros(1,N/t+1);
Delay_Phase=zeros(1,N/t+1);
Delay_Phase(1)=Delay;
Delay_Err=zeros(1,N/t+1);
Corrected_Phase=zeros(1,N/t+1);
Corrected_Freq=zeros(1,N/t+1);
Master_Time=zeros(1,N/t+1);

for i=2:N/t+1

    % Calculate phase error per second and the accumulative phase.

    Master_Err(i)=0.5*(Master_Freq(i)-Master_Freq(i-1));
    Master_Phase(i)=Master_Phase(i-1)+Master_Err(i);

    % Generate delay phase.

    Delay_Time=normrnd(Delay,Delay_Uncertainty);
    Delay_Phase(i)=Master_Phase(i)+Delay_Time;
    Delay_Err(i)=Delay_Phase(i)-Delay_Phase(i-1);

    % Calculate the delay uncertainty numerically and correct the phase.

    Uncertainty=alpha*(Delay_Err(i)-Master_Err(i))+beta*(Delay_Phase(i-1)-Master_Phase(i-1))-Delay;
    Corrected_Phase(i)=Master_Phase(i)+Uncertainty;

    % Correct the master phase.

    Master_Phase(i)=Corrected_Phase(i);
end

% Calculate corrected frequency.

for i=2:N/t+1
    Corrected_Freq(i)=(Corrected_Phase(i)-Corrected_Phase(i-1))/t+10*10^-8;
end

% Use lowpass filter.

Corrected_Freq=lowpass(Corrected_Freq,Filter_Freq);

% Loop master time.

X0=Master_Clock(1:3);
diff=Diffusion_Coefficient_Estimator(Master_Clock(4),Master_Clock(6),Master_Clock(5),Master_Clock(7),0);
mu=Master_Clock(8:10);

for i=2:N/t+1

    Q=[(t)*diff(1)^2+(t^3/3)*diff(2)^2+(t^5/20)*diff(3)^2 , (t^2/2)*diff(2)^2+(t^4/8)*diff(3)^2 , (t^3/6)*diff(3)^2 ;
       (t^2/2)*diff(2)^2+(t^4/8)*diff(3)^2 , (t)*diff(2)^2+(t^3/3)*diff(3)^2 , (t^2/2)*diff(3)^2 ;
       (t^3/6)*diff(3)^2 , (t^2/2)*diff(3)^2 , (t)*diff(3)^2];

    noise=mvnrnd(zeros(1,3),Q,1);

    Master_Time(i)=Master_Time(i-1)+t*(mu(1)+Master_Freq(i-1))+(t^2/2)*(mu(2)+X0(3))+(t^3/6)*mu(3)+noise(1);

end

% Synchronise slave clock continuously.

Slave_Time=PTP_Simulator(N,t,Master_Time,Corrected_Freq,Master_Clock,2,Distance,Speed,[1,0;1,0]);

end