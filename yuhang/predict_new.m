function yhat=predict_new(x1_test,x2_test,kest,xp1,xp2)
n1 = length(xp1);
n2 = length(xp2);
n_test=length(x1_test);
% Insert stimuli into design matrix
xntrp1 = interp1(xp1,1:n1,x1_test,'nearest');
xntrp2 = interp1(xp2,1:n2,x2_test,'nearest');
xstim = sparse(1:n_test,xntrp1+n1*(xntrp2-1),1,n_test,n1*n2);
yhat=xstim*kest;
end