
function beta = PlotStaircaseSigmoidFit(outputStruct, allLevelList,color,tickVals)

if ~exist('color') || isempty(color)
    color = [0 0 0];
end

if ~exist('tickVals') || isempty(tickVals)
    tickVals = [0.02 0.1 0.5]*100;
end

sigmoidFun  = @(beta,x)( 1/2 + (1/2)*(1 + exp(-(x-beta(1)).*beta(2)) ).^-1);

levelInd        = outputStruct.behavior(:,1);
levelMask       = ~isnan(levelInd);
fullLevelList   = allLevelList(levelInd(levelMask))';

correctFieldInd = find(strcmp(outputStruct.behDimNames,'behCorrect'));

isCorrectList   = outputStruct.behavior(levelMask,correctFieldInd);

levelList = unique(fullLevelList);
nLevels = length(levelList);

levPerf     = [];
levN        = [];

for levInd = 1:nLevels
    levMask         = fullLevelList==levelList(levInd);
    levPerf(levInd) = nanmean(isCorrectList(levMask));
    levN(levInd)            = sum(levMask);
end

xLimVals = [min(allLevelList(2:end))*0.95 max(allLevelList)*1.05];


beta0       = [nanmean(log2(fullLevelList))  1];
beta        = lsqcurvefit(sigmoidFun, beta0,log2(fullLevelList),isCorrectList);

hold all;

line(xLimVals, [1 1]*0.5, 'Color', [0 0 0], 'LineWidth',1);

xPoints = 2.^linspace(log2(xLimVals(1)), log2(xLimVals(2)), 300);
ph = plot(xPoints, sigmoidFun(beta, log2(xPoints)));
set(ph, 'Color', color);

sh = scatter(levelList, levPerf);
set(sh, 'MarkerEdgeColor', color, 'MarkerFaceColor', 1-(1-color)*0.4);
set(sh, 'SizeData',40);

% error bars
se = sqrt(levPerf.*(1-levPerf)./(levN));
xPoints = repmat(levelList', [3 1]);
yPoints = repmat(reshape(levPerf,[1 length(se)]), [3 1]) + repmat(se, [3 1]).*repmat([NaN 1 -1]', [1 length(se)]);
lh = line(xPoints(:), yPoints(:), 'LineWidth',1,'Color',color);



set(gcf, 'Color', 'w');
set(gca, 'XScale','log')
set(gca, 'XTick', tickVals, 'XTickLabel', tickVals);
axis square;
axis([xLimVals 0 1])




