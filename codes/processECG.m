function [hrRes] = processECG(data, sr)
    % processECG Extract the HR (heart rate) for different modes
    overlap = 500;
    modes = fieldnames(data);
    hrRes = zeros(numel(modes), 1);

    for i = 1:numel(modes)
        ecgSignal = [];

        mode     = modes{i};
        modeData = data.(mode);
        
        numOfTrials = size(modeData, 2);

        for j = 1:numOfTrials
            ecgSignal = [ecgSignal modeData(1:overlap, j)'];

            if j == numOfTrials
                ecgSignal = [ecgSignal modeData(overlap+1:end, j)']; 
            end
        end
   
        % Define the sampling frequency (Hz)
        fs = sr; % Replace with the actual sampling frequency of your ECG signal
        
        % Preprocess the ECG signal: Apply a bandpass filter to remove noise
        % Define filter parameters
        lowCutoff = 0.5; % Low cutoff frequency in Hz
        highCutoff = 50; % High cutoff frequency in Hz
        [b, a] = butter(2, [lowCutoff, highCutoff] / (fs / 2), 'bandpass');
        filteredECG = filtfilt(b, a, ecgSignal);
        
        % Detect R-peaks
        [~, rPeaks] = findpeaks(filteredECG, 'MinPeakHeight', 0.5, 'MinPeakDistance', fs * 0.6);
        
        % Calculate R-R intervals (differences between successive R-peaks)
        rrIntervals = diff(rPeaks) / fs; % R-R intervals in seconds
        
        % Convert R-R intervals to heart rate (beats per minute)
        heartRate = 60 ./ rrIntervals; % Heart rate in bpm
        
        hrRes(i) = mean(heartRate);
    end
end
