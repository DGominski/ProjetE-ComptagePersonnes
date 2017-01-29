close all;
clear all;
clc;

addpath('img');

chemin = 'A RENSEIGNER';
cheminOut = 'A RENSEIGNER';

% Taille des images de sorties
wL = 64;
wH = 128;

Npieton = 60;

%% Boucle

for i = 1:Npieton
    nbImg = round(rand()*500);
    imgName = ['detection_',num2str(nbImg,'%0.4d'),'.jpeg'];
    imgNameOut = ['pieton_',num2str(i,'%0.4d'),'.jpeg'];
    img = imread(imgName);
    imagesc(img);

    [x,y] = ginput(1);

    imgOut = img(y-wH/2:y-1+wH/2,x-wL/2:x-1+wL/2,:);
    imwrite(imgOut,[cheminOut,imgNameOut],'jpeg');
end
