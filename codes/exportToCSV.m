function [] = exportToCSV(ids, data, patientsECG, header)
    % exportToCSV Export data to CSV files
    %   There is a separate CSV file for each mode ('neutral', 'sad') and each band
    
    % Get the field names of the struct
    modes = fieldnames(data);
    
    % Export ECG data
    ecgMatrix = cell2mat(patientsECG);
    % Add column names
    ecgTable  = array2table(ecgMatrix, 'VariableNames', modes);
    
    % Add ID column
    ecgTable  = addvars(ecgTable, ids, 'Before', 1, 'NewVariableNames', 'ID');
    
    % Export the table to a CSV file
    writetable(ecgTable, 'ecg.csv');
    
    for i = 1:numel(modes)
        mode = modes{i};
        resMode = data.(mode);
    
        bands = fieldnames(resMode);
    
        for j = 1:numel(bands)
            band = bands{j};
            res  = resMode.(band);
            
            resMatrix = cell2mat(res);
            % Add column names
            resTable  = array2table(resMatrix, 'VariableNames', header);
    
            % Add ID column
            resTable  = addvars(resTable, ids, 'Before', 1, 'NewVariableNames', 'ID');
    
            csvFileName = [mode '_' band '.csv'];
            
            % Export the table to a CSV file
            writetable(resTable, csvFileName);
        end
    end
end
