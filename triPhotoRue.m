close all;
clear all;
clc;

% Tri photo rue

dirFond = 'dataSetFondRGB_64_128';
dirFondRue = 'dataSetFondRGB_64_128 - Rue';


addpath(dirFond);

for numFond = 1:size(dir(dirFond),1)  
    fondName = ['fond_',num2str(numFond,'%0.4d'),'.jpeg'];
    if (exist(['dataSetFondRGB_64_128\',fondName],'file') ~= 0)
        if mean(mean(mean(abs(imread(fondName)-92)))) < 0.02*92
            imwrite(imread(fondName),[dirFondRue,'\',fondName],'jpeg');
        end
    end
end