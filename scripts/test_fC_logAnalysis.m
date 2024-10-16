clear
close all

JSONfileName = 'D:\programs\openREGGUI\flash_qa\data\fC_logAnalysisD58Azar.json'

config = loadjson(JSONfileName)
[handles, Plan] = fC_logAnalysis(config);
