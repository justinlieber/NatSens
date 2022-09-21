function vec = GetVecFromParam(params)

Nsc     = size(params.autoCorrMag,3);
Nor     = size(params.autoCorrMag,4);
Na      = size(params.autoCorrMag,1);

[indStruct] = GetParamInds(Nsc, Nor, Na);



fieldList = fields(indStruct);

nFields = length(fieldList);

vec = [];
for fieldInd = 1:nFields
    fieldName = fieldList{fieldInd};
    vecInd = getfield(indStruct, fieldName);
    if strcmp(fieldName, 'pixelStats')
        pixelData   = getfield(params,'pixelStats');
        pixelLPData = getfield(params,'pixelLPStats');
        thisParamData = cat(1,pixelData(:), pixelLPData(:));
    else
        thisParamData = getfield(params,fieldList{fieldInd});
    end
    vec(vecInd) = thisParamData(:);
end
