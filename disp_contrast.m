% Load the SPM.mat file before running this script
% load(path/to/SPM.mat)

for i = 1:length(SPM.xCon)
    disp(['Name: ', SPM.xCon(i).name]);
    disp(['Vector: [', num2str(SPM.xCon(i).c'),']']);
    fprintf('\n');
end
