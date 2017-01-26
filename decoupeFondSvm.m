close all;
clear all;
clc;

imgName = 'detection_0000.jpeg';
A = imread(imgName); 
[L H C] = size(A);

wL = 128;
wH = 64;
step = 32;

cheminOut = 'D:\Documents\INSA LYON\2016-2017\Mini-projet-TDSI-Git\ProjetE-ComptagePersonnes\dataSetFondRGB_64_128\';

index = 1;
for h = 1:step:H-wH
    for l=1:step:L-wL
        temp = A(l:(l+wL-1),h:(h+wH-1),:);
        imgNameOut = ['fond_',num2str(index,'%0.4d'),'.jpeg'];
        imwrite(temp,[cheminOut,imgNameOut],'jpeg');
        index = index + 1;
    end
end
