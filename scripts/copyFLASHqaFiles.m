% Copy all MAtlab files required by test_fC_logAnalysis.m
% from the openFLASH git and the REGGUI git into the present git

[fList,pList] = matlab.codetools.requiredFilesAndProducts('test_fC_logAnalysis.m');

%REGGUI folder
folderIN{1}   = 'D:\programs\openREGGUI\REGGUI';
folderFROM{1} = 'C:\Users\rla\Downloads\REGGUI-a1419689b91dda57cfec83c6b8aec23df09be77a-a1419689b91dda57cfec83c6b8aec23df09be77a';
folderTO{1}   = 'D:\programs\openREGGUI\flash_qa\REGGUI';

%openFLASHfolder
folderIN{2}   = 'D:\programs\github\openFLASH\conformalFLASH';
folderFROM{2} = 'C:\Users\rla\Downloads\conformalFLASH-9cbc409a2c2ef613733dffae051de6bfaf079f92';
folderTO{2}   = 'D:\programs\openREGGUI\flash_qa\openFLASH';

%PMS folder
folderIN{3}   = 'D:\programs\PMS\coordiante_systems';
folderFROM{3} = 'D:\programs\PMS\coordiante_systems';
folderTO{3}   = 'D:\programs\openREGGUI\flash_qa\PMS';


%Copy files
for idx = 1:numel(fList)

  [folder,fileName,ext]=fileparts(fList{idx});
  [fromF , toF] = findFolders(folder , folderIN , folderFROM , folderTO);

  fileFom = fullfile(fromF , [fileName ext]);
  fileto  = fullfile(toF   , [fileName ext]);
  fprintf('[%d] Copying %s \n' , idx , [fileName ext])
  copyfile(fileFom , fileto)
end

%-----------------------------------------------
%Find the folder path where to copy the files
%-----------------------------------------------
function [fromF , toF] = findFolders(folder , folderIN , folderFROM , folderTO)

  fromF = [];
  toF = [];

  for idx = 1:numel(folderIN)
    k = strfind(folder,folderIN{idx});
    if ~isempty(k)
      %This is a match
      fromF = [folderFROM{idx} , folder(numel(folderIN{idx})+1:end)];
      %The output folder does not respect the REGGUI folder structure.
      %Some of the REGGUI function make searches on the folder structure nad make assumptions on where the files are stored
      %We cannot allow that if we want to compile the program. All path must be explicitly stated
      % without searching an inexistant folder tree structure in a compiled EXE file
      toF   = [folderTO{idx} ] ;
      break
    end
  end

  if isempty(fromF) | isempty(toF)
    fold
    error('Unknown folder \n')
  end

end
