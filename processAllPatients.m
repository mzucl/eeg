close all; clear; clc

allPatientsFilePaths = {dir(fullfile([pwd '/patients'], '*.mat')).name};

% Structure for storing all the results prior to export (EEG)
patientsData = {};

colNames = '';

numOfPatients = length(allPatientsFilePaths);
patientsIDs = cell(numOfPatients, 1);

% Used to compare the channels list for all patients
oldChLabels = {};

for i = 1:numOfPatients
    [fileName, id] = getPatientFileNameAndId(allPatientsFilePaths(i));
    [chLabels, resEEG, resECG] = processPatient(fileName);
    oldChLabels = chLabels;

    % This will be the first column in the .csv table
    patientsIDs{i} = id;

    colNames = string(chLabels);

    % This is just checked, but haven't been dealt with in the code;
    % If this error is shown, then a different structure has to be used for
    % the data to take that into the account!
    if ~isempty(oldChLabels)
        if ~isequal(oldChLabels, chLabels)
            disp('ERROR: Different channels list in different patients!');
        end
    end

    % ['sad', 'neutral']
    modes = fieldnames(resEEG);

    % For each mode
    for j = 1:numel(modes)
        mode    = modes{j};
        resMode = resEEG.(mode);
        bands   = fieldnames(resMode);
        
        % For each band
        for k = 1:numel(bands)
            band = bands{k};
            res  = resMode.(band);

            % Data for the mode 'mode' and band 'band' is stored in
            % 'res'; Next step is to add it to appropriate table/data
            % structure and finally export it;
            
            % The first patient - intialize structures
            if i == 1
                patientsData.(mode).(band) = cell(numOfPatients, 1);
                patientsECG                = cell(numOfPatients, 1);
            end
            patientsData.(mode).(band){i} = res';
        end
        patientsECG{i} = resECG';
    end
end

exportToCSV(patientsIDs, patientsData, patientsECG, colNames);
