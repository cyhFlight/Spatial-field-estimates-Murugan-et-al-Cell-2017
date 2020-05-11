%% toy example

xx=-10:0.1:10;
[x1,x2]=meshgrid(xx);
x1r=reshape(x1,[],1);
x2r=reshape(x2,[],1);
nsamps=length(x1r);

rho=1;
delta=3;
y_noise=0.2*rho;
x1_c=-2; % peak center coordinates
x2_c=7;

xdist=(x1r-x1_c).^2 +(x2r-x2_c).^2;
y=rho.*exp(-xdist./(2*delta^2))+randn(nsamps,1)*y_noise;  % response+noise

x1_lim=[-10,10];
x2_lim=[-10;10];
imagesc(x1_lim,x2_lim,reshape(y,size(x1)))
axis equal;axis tight
colorbar
colormap jet
%% create binned regressors
% use 0.5% of the data
n_train=round(0.01*nsamps);
randinx=randsample(nsamps,n_train);
x1_train=x1r(randinx);
x2_train=x2r(randinx);
y_train=y(randinx);

binwidth=0.5;

x1crs = round(x1_train/binwidth)*binwidth;  % gridded locations
x2crs = round(x2_train/binwidth)*binwidth;  % gridded locations

xp1 = unique(x1crs); 
xp2 = unique(x2crs);
n1 = length(xp1);
n2 = length(xp2);

% Insert stimuli into design matrix
xntrp1 = interp1(xp1,1:n1,x1crs,'nearest');
xntrp2 = interp1(xp2,1:n2,x2crs,'nearest');
xstim = sparse(1:n_train,xntrp1+n1*(xntrp2-1),1,n_train,n1*n2);

% Plot occupancy and spatial grid points with data
subplot(323); plot(x1_train,x2_train,'k.'); 
hold on; plot(x1crs,x2crs,'r.', 'markersize', 8);hold off;
axis equal; axis tight; box off;

%%
minlens=1;
dims=[n1,n2];
[kest,ASDstats,dd] = fastASD(xstim,y_train-mean(y_train),dims,minlens);
%kest=flipud(kest);
%%
subplot(211)
imagesc(x1_lim,x2_lim,reshape(y-mean(y),size(x1)))
title("Signal data + noise")
axis equal; axis tight; box off;
set(gca,'YDir','normal')
subplot(212)
imagesc(x1_lim,x2_lim,reshape(kest,dims)')
title("Estimated receptive field")
axis equal; axis tight; box off;
colormap jet
set(gca,'YDir','normal')
%% predict
yhat=xstim*kest;
figure
plot(y_train-mean(y_train)-yhat,'ko');



