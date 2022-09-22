function PlotScaleThresholds(sizeImGroup, fullSizeOutput)


nGroups = length(fullSizeOutput);

sigmoidFun  = @(beta,x)( 1/2 + (1/2)*(1 + exp(-(x-beta(1)).*beta(2)) ).^-1);

saveBeta    = nan(2,nGroups);
sizeList    = nan(1,nGroups);
for groupInd = 1:nGroups
    sizeList(groupInd)      = sizeImGroup{groupInd}.eyeDegSize;
    
    fullLevelInd            = fullSizeOutput{groupInd}.behavior(:,1);
    fullLevelList           = sizeImGroup{groupInd}.cohList(fullLevelInd)';

    isCorrectList           = fullSizeOutput{groupInd}.behavior(:,6);
    
    beta0                   = [nanmean(log2(fullLevelList))  1];
    saveBeta(:,groupInd)    = lsqcurvefit(sigmoidFun, beta0,log2(fullLevelList),isCorrectList);
end


hold all;
mask = 2.^saveBeta(1,:)<100;
ind = find(mask);

xVals = sizeList;

%ind = [2 3 4];


p = polyfit(log2(xVals(ind)), saveBeta(1,ind),1);



xFuncVals = 2.^linspace(-1,4,300);

tempFunc = @(param,x)(log2(param(3)+2.^(param(1).*x + param(2))));
x0 = [p(1) p(2) 1];
fitParam = lsqcurvefit(tempFunc,x0,log2(xVals(ind)),saveBeta(1,ind));

%[p(1) fitParam(2)]

%plot(xFuncVals,2.^(p(1).*log2(xFuncVals)+p(2)));
%plot(xFuncVals,2.^(fitParam(1).*log2(xFuncVals)+fitParam(2)));

%fitParam = [9 -3.5 fitParam(3)];

ph = plot(xFuncVals,2.^tempFunc(fitParam,log2(xFuncVals)), 'LineWidth',1.5);
set(ph, 'Color', [1 1 1]*0.7)



plot(xVals(ind), 2.^saveBeta(1,ind),'Color','k');
sh = scatter(xVals(~mask), ones(size(xVals(~mask)))*100);
set(sh, 'Marker', 'x','MarkerEdgeColor','r','SizeData',100,'LineWidth',2);


title(sprintf('slope/exponent: %0.2f', p(1)));

set(gca, 'XScale','log','YScale','log');
set(gca, 'YTick', [10 25 50 100]);
ylabel('threshold (coherence)');
set(gca, 'XTick', xVals);
xlabel('size (deg)');

logDist = 5.4;
minSize = 0.4;

axis(2.^([log2(minSize)+[0 logDist] log2(100.1)+[-logDist 0]]));


axis square;
box off;
set(gcf, 'Color','w');