

function propStruct = ParseImageFilename(filename, fileExt)

if ~exist('fileExt') || isempty(fileExt)
    fileExt = '.png';
end

dashInd      = strfind(filename,'-');
pngInd       = strfind(filename,fileExt);
parenStartInd   = strfind(filename,'(');
parenEndInd     = strfind(filename,')');
endLetterInd = find(diff(isletter(filename)) == -1);

stringStartInd  = [1 dashInd+1];
nProp           = length(stringStartInd);
stringEndInd    = parenStartInd-1;

numStartInd     = parenStartInd+1;
numEndInd       = parenEndInd-1;

propStruct = [];
for i=1:length(stringStartInd)
    propString = filename(stringStartInd(i):stringEndInd(i));
    propVal = str2num( filename(numStartInd(i):numEndInd(i)) );
    
    if isempty(propVal)
        propVal = filename(numStartInd(i):numEndInd(i));
    end
    
    propStruct = setfield(propStruct, propString, propVal);
end

