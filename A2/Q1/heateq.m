function im = heateq(image,sigma,n)
dt = 0.5*sigma^2/n;%calculate delta t

I_nplus1 = image;
for i = 1:n%loop for n times
    [fx, fy] = gradient(I_nplus1);%first order derivative
    [fxx, fyx] = gradient(fx);
    [fxy, fyy] = gradient(fy);%second order derivative
    I_nplus1 = (fxx + fyy)*dt + I_nplus1;%numerical update to get I at n+1 iteration
end

im = I_nplus1;
end