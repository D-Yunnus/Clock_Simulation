function [time,freq] = Network_Architecture_Simulation( N , t , Clocks , Logic_Matrix , Adjustment , Filter_Freq , Sync_Interval , Distance , Trans_Speed , P_Loss_Matrix )

% 

No_of_Clocks=size(Clocks,2);

time=zeros(No_of_Clocks,N/t+1);
freq=zeros(No_of_Clocks,N/t+1);

for i=1:6
    if Clocks{i}{1}==1
        ref_clock=Clock_Type(Clocks{i});
        diff_master=Diffusion_Coefficient_Estimator(ref_clock(4),ref_clock(6),ref_clock(5),ref_clock(7),0);
        [time(i,:),freq(i,:),~]=Clock_Simulator(N,t,ref_clock(1:3),diff_master,ref_clock(8:10));
    end
end

for i=1:5
    for j=i+1:6
        if Logic_Matrix(i,j)==1
            if Clocks{i}{1}<Clocks{j}{1}
                Slave_Clock=Clock_Type(Clocks{j});
            end
            [time(j,:),freq(j,:)]=White_Rabbit_Simulator(N,t,time(i,:),freq(i,:),Slave_Clock,Adjustment,Filter_Freq,Sync_Interval,Distance,Trans_Speed,P_Loss_Matrix);
        end 
    end
end

end