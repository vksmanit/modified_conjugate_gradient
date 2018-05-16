function x = nal_nbk_mcg(A,B,mcg_index)
% --------------------------------------------------------------------------------------------
% Syntax : x = nal_nbk_mcg(A,B,mcg_index) 
%
% This is modified conjugate gredient method to solve the system of  equation Ax = B,
% here we have take x = zeros(length(B),1) as our initial guess.
% --------------------------------------------------------------------------------------------

% -------------------------------- written on : Mar 12, 2018 ---------------------------------
   mcg_index_plus_one = mcg_index + 1;
   x = zeros(length(B),1);
   col_size_of_A = length(x);
   r = B - A*x;
   p = r;
   iter = 1;
   for k = 1:100 %length(B) % since modified CG generate the exact solution to linear system 
                       % Ax = B in at most n step 
                       % this is not working with length(B) --> TODO
       iter = iter + 1 ;% variable for iteration
       Ap = A * p;
       alpha = (r(1:mcg_index)'*p(1:mcg_index) - r(mcg_index_plus_one:col_size_of_A)'*p(mcg_index_plus_one:col_size_of_A))/(p(1:mcg_index)' * Ap(1:mcg_index) - p(mcg_index_plus_one:col_size_of_A)'*Ap(mcg_index_plus_one:col_size_of_A));
       x = x + alpha * p;
%       size (alpha)
      % x = x - alpha * p;  % -ve sign is in paper but +ve sign is working
       rold = r;
        r = r - alpha * Ap;
        temp1 = max(abs(r - rold));
        if (temp1 < 1e-6)
       %if ( ((r-rold) < 10^-6) | ((rold -r) < 10 ^-6))
       %if ( abs(r-rold) < 10^-6) % or (rold -r) < 10 ^-6)
          iter
           break;
       end
       beta = -(r(1:mcg_index)'*Ap(1:mcg_index) -r(mcg_index_plus_one:col_size_of_A)'*Ap(mcg_index_plus_one:col_size_of_A))/(p(1:mcg_index)' * Ap(1:mcg_index) - p(mcg_index_plus_one:col_size_of_A)'*Ap(mcg_index_plus_one:col_size_of_A));
       p = r + beta * p;

	%size(beta)	       %k
   end

end

 
