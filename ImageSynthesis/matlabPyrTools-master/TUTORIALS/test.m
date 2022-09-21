

%% What do I want to do?


% 1) Look into steerable pyramid code
% How edit-able is it?
% Texture model uses complex pyramid, for phase info

% 

%%

path = '/Users/justinlieber/Documents/justinvision/Images/';

imageFiles = dir([path '*.JPG']);

size(imageFiles);

indList = 43;

images = [];
for i=1
    filePath = [path imageFiles(indList(i)).name];
    images(:,:,:,i) = imread(filePath);
end

%

im = images(:,:,:,1)/255;

im = sum(im.*repmat(shiftdim([0.2126 0.7152 0.0722],-1),[size(im,1) size(im,2) 1]),3);

clf;
imagesc(im)
colormap gray
axis image;

%%

[pyr,pind] = buildSpyr(im, 4-imSubSample, filts);

%%

oList = [1 3];

vals = [];
for oInd = 1:2
    o = oList(oInd);
    for s = 1:min(4,spyrHt(pind))
      %band = spyrBand(pyr,pind,s,4);
      band = reconSpyr(pyr,pind,filts,'reflect1',s,o);
      vals(:,:,s,oInd) = band;
      
      [o s]
    end
end

'done'
    

%%

yInd = 1:size(vals,1);
xInd = 1:size(vals,2);

%yInd = (1:1000) + 500;
%xInd = (1:1000) + 1000;

clf;

for oInd = 1:2
    for i=1:4
        plotInd = i+(oInd-1)*5;
        subplot(2,5,plotInd);
        %imagesc(vals(yInd,xInd,i,oInd).^2)
        imagesc(vals(yInd,xInd,i,oInd))
        colormap gray;

        caxis([-1 1]*0.02);
        %caxis([0 1]*0.0001);
        axis image;
        axis off;
        
        x = vals(yInd,xInd,i,oInd);
        
        title(nanstd(x(:))*100);
    end
    
    subplot(2,5,oInd*5)
    imagesc(sum(vals(yInd,xInd,:,oInd),3))
    
    colormap gray;

    caxis([-1 1]*0.02*1);
    %caxis([0 1]*0.0001);
    axis image;
    axis off;

    x = sum(vals(yInd,xInd,:,oInd),4);

    title(nanstd(x(:))*100);

    
end

%%

xInd = 1:10;

x = vals(:,xInd,3,1);
y = vals(:,xInd,4,1);


i = 1;
clf;
subplot(2,1,1)
hold all;
plot(1:2000, x(:,i));
plot(1:2000, y(:,i));

subplot(2,1,2);

scatter(x(:),y(:));
axis image;

nancorr(x(:), y(:))


