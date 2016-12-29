close all;
clear all;
clc;

% Decoupage de pieton pour la SVM
chemin = 'D:\TDSI\ProjetE-ComptagePersonnes\data\';

imgName = 'detection_0460.jpeg';
imgOutputName = 'pieton_30.jpeg';

xSize = 40;
ySize = 100;

img = rgb2gray(imread(imgName));
imagesc(img);colormap(gray);

[x,y] = ginput(1);

imgOut = img(y-ySize/2:y-1+ySize/2,x-xSize/2:x-1+xSize/2);
imwrite(imgOut,[chemin,imgOutputName],'jpeg');