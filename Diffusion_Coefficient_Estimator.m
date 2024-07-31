function diff = Diffusion_Coefficient_Estimator(AVAR,t_Allan,t_small,t_large,diff_drift)

% The Allan variance is a function of the time interval t indicating the stability of the clock.
% The function makes an estimate for the diffusion coefficients using a
% known Allen variance at a time t_Allan.

% For small time t_small, white noise dominates.

diff_white=sqrt(AVAR*sqrt(t_Allan)*sqrt(t_small));

% For (relatively) large time t_large, flicker noise dominates.

diff_flicker=sqrt(3*AVAR*sqrt(t_Allan))/sqrt(t_large*sqrt(t_large));

% Generate diffusion vector.

diff=[diff_white,diff_flicker,diff_drift];

end