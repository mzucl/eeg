function [chLabels, EEGResults, ECGResults] = processPatient(fileName)
    % processPatient Process single patient
    %   Return average power per band and heart rate for both modes ('neutral',
    %   'sad')
    
    % Load the data structure
    D = load(strcat(pwd, '/patients/', fileName, '.mat.mat'));
    D = D.D;
    
    % Cut off frequencies
    lowFreq  = 0;
    highFreq = 0;
    filtersIdx = find(strcmp({D.history.fun}, 'spm_eeg_filter'));
    for i = 1:length(filtersIdx)
        idx = filtersIdx(i);
        if D.history(idx).args.band == "high"
            lowFreq = D.history(idx).args.freq;
        else
            highFreq = D.history(idx).args.freq;
        end
    end
    
    % Create a structure with frequency bands
    freqBands.delta = [lowFreq 4];
    freqBands.theta = [4 8];
    freqBands.alpha = [8 12];
    freqBands.beta  = [12 30];
    freqBands.gamma = [30 highFreq];
    
    % General variables
    numChannels = D.data.dim(1);
    numSamples  = D.data.dim(2);
    numTrials   = D.data.dim(3);
    sr          = D.Fsample; % sample rate
    
    % Bad trials
    badTrialsIdx = find([D.trials.bad] == 1);
    
    % 'neutral' vs 'sad' movie clips
    labels = {D.trials.label};
    
    % Find indices of 'neutral' labels
    neutralIdx = setdiff(find(strcmp(labels, 'Neutral')), badTrialsIdx);
    
    % Find indices of 'sad' labels
    sadIdx = setdiff(find(strcmp(labels, 'Sad')), badTrialsIdx);
    
    assert(size(neutralIdx, 2) + size(sadIdx, 2) + size(badTrialsIdx, 2) == numTrials, 'ERROR!');
    
    % Load the data
    filePath = fullfile(pwd, 'patients', strcat(fileName, '.dat.dat'));
    
    f = fopen(filePath, 'rb');
    
    if f == -1
        error('Failed to open the file: %s', filePath);
    end
    data = fread(f, inf, '*float32');
    
    % Reshape the data
    data = reshape(data, numChannels, numSamples, numTrials);
    
    % ECG channel
    chIdx      = strcmp({D.channels.label}, {'ECG'});
    ECGData.neutral = squeeze(data(chIdx, :, neutralIdx));
    ECGData.sad     = squeeze(data(chIdx, :, sadIdx));
    ECGResults      = processECG(ECGData, sr);
    
    % Find all 'EEG' channels
    isEEG    = arrayfun(@(x) strcmp(x.type, 'EEG'), D.channels);
    indices  = isEEG;
    chLabels = {D.channels(indices).label}; 
    data = data(indices, :, :);
    
    % FFT of all channels averaged over all trials
    allChannelsNeutralPower = mean(abs(fft(data(:, :, neutralIdx), [], 2) / numSamples).^2, 3);
    allChannelsSadPower     = mean(abs(fft(data(:, :, sadIdx), [], 2) / numSamples).^2, 3);
    
    % Vector of frequencies
    hz = linspace(0, sr/2, floor(numSamples/2) + 1);
    
    % Power bands
    bandNames = fieldnames(freqBands);
    % Loop through each frequency band
    for i = 1:numel(bandNames)
        bandName = bandNames{i};
        range    = freqBands.(bandName);
        bandIdx  = dsearchn(hz', range');
    
        % 'neutral' mode
        neutralPower    = allChannelsNeutralPower(:, bandIdx(1):bandIdx(2));
        avgNeutralPower = mean(neutralPower, 2);
        avgNeutralPower = 10 * log10(avgNeutralPower);
    
        % 'sad' mode
        sadPower    = allChannelsSadPower(:, bandIdx(1):bandIdx(2));
        avgSadPower = mean(sadPower, 2);
        avgSadPower = 10 * log10(avgSadPower);
    
        EEGResults.neutral.(bandName) = avgNeutralPower;
        EEGResults.sad.(bandName)     = avgSadPower;
    end
end
