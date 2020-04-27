%% playgournd

addpath(genpath('/Users/Flight/codes/falkner'))
folder='/Users/Flight/Downloads/Documents/Falkner Lab/191218_datM745_cageday/';
%locations=readmatrix('/Users/Flight/Downloads/Documents/Falkner Lab/DeepLabCut_data/191218_datM745_balbcMcage_a-12182019104734-0000DeepCut_resnet50_191219_PMVcagedayDec19shuffle1_1030000.csv');

load([folder 'processed_data.mat']);

%% filter position
threshold_quantile=0.9;
x1=repeat_filter_pos(Cx,time,threshold_quantile);
x2=repeat_filter_pos(Cy,time,threshold_quantile);
figure
plot(Cx,Cy)
hold on
plot(x1,x2,'r-')

%% bin xy coordinates
nbin_x=50; % roughly number of bins on each dimension
binwidth=mean([max(x1)-min(x1),max(x2)-min(x2)])/nbin_x;

n_train=length(x1);
x1_train=x1';
x2_train=x2';
y_train=z_sig'-mean(z_sig);

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
%% run gaussian regression
minlens=2;
dims=[n1,n2];
[kest,ASDstats,dd] = fastASD(xstim,y_train,dims,minlens);

%% predict
x1_test=[540 900 1200 1200];
x2_test=[440 700 11 800];
yhat=predict_new(x1_test,x2_test,kest,xp1,xp2);
figure
x1_lim=[min(x1) max(x1)];
x2_lim=[min(x2) max(x2)];
imagesc(x1_lim,x2_lim,reshape(kest,dims)')
set(gca,'YDir','normal')
hold on 
scatter(x1_test,x2_test,300,-yhat,'filled')
colormap(jet)

%% Plot occupancy and spatial grid points with data
figure
subplot(221)
plot(x1_train,x2_train,'k.'); 
hold on; plot(x1crs,x2crs,'r.', 'markersize', 8);hold off;
axis tight; box off;
title('Grid points')

subplot(222)
colormap(jet)
scatter(x1,x2,10,y_train,'square','filled','MarkerFaceAlpha',0.5)
axis tight; box off;
colorbar
title('Signal (z-score) on 2D')

subplot(223)
scatter(x1crs,x2crs,60,yhat,'square','filled','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0.5)
axis tight; box off;
colormap jet;colorbar
title('Fitted signal')

subplot(224)
x1_lim=[min(x1) max(x1)];
x2_lim=[min(x2) max(x2)];
imagesc(x1_lim,x2_lim,reshape(kest,dims)')
hold on 
scatter(x1_train,x2_train,10,'k','MarkerEdgeAlpha',0.2)
title("Estimated receptive field")
axis tight; box off;
colormap jet;colorbar
set(gca,'YDir','normal')
%% residuals
residuals=y_train-yhat;
figure
subplot(221)
colormap(jet)
scatter(x1crs,x2crs,60,yhat,'square','filled','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0.5)
axis tight; box off;
colorbar
title('Fitted signal')

subplot(222)
plot(time,residuals,'ko','MarkerSize',2)
title('Temporal patterns of residuals')

subplot(223)
scatter(x1_train,x2_train,5,abs(residuals),'filled','MarkerFaceAlpha',0.8)
set(gca,'YDir','normal')
colorbar
title('Spatial patterns of residuals')

subplot(224)
histogram(residuals,50,'FaceColor','b','EdgeColor','c','FaceAlpha',0.7)
title('Histogram of residuals')
