close all;
clear all;
clc;

addpath('img');
addpath('src');

% Ligne de d�tection
imgName = 'detection_0000.jpeg';
img = rgb2gray(imread(imgName));
[pts,vectIndexLigne] = setDetectionLine(img);

