function [fitresult, gof] = ref_best_fit(ref_time, ref_comp)
%CREATEFIT(REF_TIME,REF_COMP)
%  Create a fit.
%
%  Data for 'ref_best_fit' fit:
%      X Input : ref_time
%      Y Output: ref_comp
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 04-Apr-2022 11:48:44


%% Fit: 'ref_best_fit'.
[xData, yData] = prepareCurveData( ref_time, ref_comp );

% Set up fittype and options.
ft = fittype( 'power2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [5.97246509796005e-11 0.00231284265145931 3.45026055953433e-16];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
% 
% Plot fit with data.
% figure( 'Name', 'ref_best_fit' );
% h = plot( fitresult, xData, yData );
% legend( h, 'ref_comp vs. ref_time', 'ref_best_fit', 'Location', 'NorthEast' );
% % Label axes
% xlabel ref_time
% ylabel ref_comp
% grid on


