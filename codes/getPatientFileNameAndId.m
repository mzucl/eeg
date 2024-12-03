function [fileName, patientId] = getPatientFileNameAndId(path)
  % getPatientFileNameAndId 
  % Extract file name and patient id from file path
  
  parts = split(path, '.');
  
  fileName  = char(parts(1));
  patientId = fileName(end-3:end);
end
