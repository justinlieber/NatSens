function sample = GetNewestFloatSample(runEyeTrack)

if runEyeTrack && Eyelink( 'NewFloatSampleAvailable') > 0
    sample = Eyelink( 'NewestFloatSample');
else
    sample = [];
end