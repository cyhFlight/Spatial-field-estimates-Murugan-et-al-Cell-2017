function x=repeat_filter_pos(Cx,time,threshold_quantile)
cutoff=quantile(abs(diff(Cx)),threshold_quantile);
x1=Cx;
c=0;
while any (abs(diff(x1)) > cutoff)
    x1=filter_position(x1,time,cutoff);
    c=c+1;
end
x=x1;
end