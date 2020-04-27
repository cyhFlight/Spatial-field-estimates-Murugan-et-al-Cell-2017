function [x1]=filter_position(Cx,time,cutoff)
x1=Cx;
x1diff=abs(diff(Cx));
% threshold on 0.95 quantile
err_x1_inx=find(x1diff>cutoff)+1;
x1_temp=Cx;
x1_temp(err_x1_inx)=[];
time_temp=time;
time_temp(err_x1_inx)=[];
xq=interp1(time_temp,x1_temp,time(err_x1_inx));
%update x1
x1(err_x1_inx)=xq;
end