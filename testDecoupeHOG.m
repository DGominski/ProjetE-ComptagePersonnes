close all;
clear all;
clc;

addpath('img');

imgName = ['detection_',num2str(0,'%0.4d'),'.jpeg'];
img = imread(imgName);

HOG_cell = [10 10];
Bins = 9;

wH = 100;
wL = 40;

xRect = 155;
yRect = 185;
wRect = 280;
hRect = wH;

[hog,vHog] = extractHOGFeatures(double(img(yRect+(1:hRect),xRect+(1:wRect+1))),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',[1 1],'BlockOverlap',[0 0]);

hogRes = reshape(hog,10,28*9);
hogRes2 = im2col(hogRes,[10 4*9]);