function params = GetParamFromVec(vec, Nsc, Nor, Na)

[indStruct, fSizes] = GetParamInds(Nsc, Nor, Na);

fieldList = fields(indStruct);

nFields = length(fieldList);

params = [];
for fieldInd = 1:nFields
    fieldName = fieldList{fieldInd};
    pixelVec = vec(getfield(indStruct, fieldName));
    if strcmp(fieldName, 'pixelStats')
        params.pixelStats   = pixelVec(1:6);
        params.pixelLPStats = reshape(pixelVec(7:end),[(Nsc+1) 2]);
    else
        params = setfield(params,fieldName,reshape(pixelVec, fSizes{fieldInd}));
    end
end
