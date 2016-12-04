clear all;
close all;
clc;

addpath('img');
addpath('src');
addpath('data');

imgName = 'detection_0000.jpeg';

%% Angle de l'image
streetAngle = getImgStreetAngle(imgName);
img = rgb2gray(imread(imgName));

%% Selection de la ligne
ptsLine = setDetectionLine(img,streetAngle);

%% Acquisition des données
figure;
% dataImg = getDataDetection(200,0,ptsLine);
load('data200Img.mat');

imagesc(dataImg');colormap(gray); axis image;

%% Suppréssion du fond par moyennage

dataImgFiltree = backgroundfilter(dataImg);

%% Scale
dataImgFiltreeSca = scallingImg(dataImgFiltree);

%% Seuil Hystérésis par Histogramme
% imgSeuilGrad = imgHysteresis(GmagScal);
imgSeuil = imgHysteresis(dataImgFiltreeSca);

%% Erosion
% se = strel('disk',1);
% imgErode = imerode(imgSeuil,se);
% imagesc(imgErode);

%% Dilatation
se = strel('disk',3);
imgDilate = imdilate(Gmag,se);
imagesc(imgDilate);colormap(gray);

%% Gradian
[Gmag,Gdir] = imgradient(dataImgFiltreeSca);
subplot(1,2,1);imagesc(Gmag);colormap(gray);
subplot(1,2,2);imagesc(Gdir);colormap(gray);
