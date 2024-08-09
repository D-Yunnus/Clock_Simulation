function [x_master,x_slave] = PTP_Simulator(n,d,T,X0_master,diff_master,mu_master,X0_slave,diff_slave,mu_slave)

diff=diff_master;
X_0=X0_master;
mu=mu_master;
[x_master,y_master,~]=Clock_Simulator(n,d,X_0,diff,mu);

diff=diff_slave;
mu=mu_slave;

x_slave=zeros(1,n/T+1);

for i=1:n/T
    [x,~,~]=Clock_Simulator(T,1,[x_master((i-1)*T+1),y_master((i-1)*T+1),X0_slave(3)],diff,mu);
    x_slave((i-1)*T+1:i*T+1)=x;
end

end