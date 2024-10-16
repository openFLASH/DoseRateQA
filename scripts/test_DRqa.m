clear
close all

JSONfileName = 'D:\programs\openREGGUI\flash_qa\data\fC_logAnalysisD58.json'

config = loadjson(JSONfileName)
[handles, Plan] = runDRqa(config);
