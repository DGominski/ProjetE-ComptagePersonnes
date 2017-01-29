close all;
clear all;
clc;

addpath('img');

imgName = 'detection_0000.jpeg';
A = imread(imgName); 
[L H C] = size(A);


cheminOut = ''; % A renseigner

% Taille des images de sorties
wL = 64;
wH = 128;

% Distance en pixel entre 2 images
step = 32;

% Découpe
index = 1;
for h = 1:step:H-wH
    for l=1:step:L-wL
        temp = A(h:(h+wH-1),l:(l+wL-1),:);
        imgNameOut = ['fond_',num2str(index,'%0.4d'),'.jpeg'];
        imwrite(temp,[cheminOut,imgNameOut],'jpeg');
        index = index + 1;
    end
end
