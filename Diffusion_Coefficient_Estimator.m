function diff = Diffusion_Coefficient_Estimator(AVAR_1,AVAR_2,t_1,t_2,diff_drift)

% The Allan variance is a function of the time interval t indicating the stability of the clock.
% The function makes an estimate for the diffusion coefficients using a
% known Allen variance at a time t_Allan.

% For small time t_small, white noise dominates.

diff_white=sqrt(abs((AVAR_2*t_1-AVAR_1*t_2)/(t_1/t_2-t_2/t_1)));

% For (relatively) large time t_large, flicker noise dominates.

diff_flicker=sqrt(abs((3*(AVAR_2-diff_white^2/t_2))/t_2));

% Generate diffusion vector.

diff=[diff_white,diff_flicker,diff_drift];

end