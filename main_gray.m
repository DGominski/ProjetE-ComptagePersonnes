close all;
clear all;
clc;

addpath('img');
addpath('src');

% Ligne de détection
imgName = 'detection_0000.jpeg';
img = double(rgb2gray(imread(imgName)));
[pts,index] = setDetectionLine(img);

% Boucle
nToStart = 0;
nToEnd = 100;

nbImg = 100;
imgChrono = zeros(size(index,2),nbImg);
temp = img;
img = mat2gray(temp);
for i = 1:size(index,2)
  ligneFond(i) = img(index(2,i),index(1,i));
end
imgBg = ones(nbImg,1)*ligneFond;
imgSansBg = zeros(size(index,2),nbImg);
imgBin = zeros(size(index,2),nbImg);

close all;
figure;
for n = 0:500
    tStart = tic;
    
    % Chargement de l'image
    imgName = ['detection_',num2str(n,'%0.4u'),'.jpeg'];
    img = double(rgb2gray(imread(imgName)));
    
    % Normalisation
%     minImg = min(min(img));
%     img = img - minImg;
%     maxImg = max(max(img));
%     imgNorm = img/maxImg*1;
    imgNorm = mat2gray(img);
    
    % Récupération des pixels sur la ligne de détection
    temp = imgChrono;
    imgChrono(:,2:nbImg) = temp(:,1:nbImg-1);
    for i = 1:size(index,2)
      imgChrono(i,1) = imgNorm(index(2,i),index(1,i));
    end
    
    % Calcul du fond
%    fond = mean(imgChrono');
%    imgBg(:,2:nbImg) = imgBg(:,1:nbImg-1);
%    imgBg(:,1) = fond; 
    ligneFond = mean(imgChrono');
    
    % Soustraction du fond
%     imgSansBg(:,2:nbImg) = imgSansBg(:,1:nbImg-1);
%     imgSansBg(:,1) = abs(imgChrono(:,1)-imgBg(:,1)); 
    ligneSansBg = abs(imgChrono(:,1)-ligneFond'); 
    
    % Seuillage
    seuil = 0.2;
    temp = imgBin;
    imgBin(:,2:nbImg) = temp(:,1:nbImg-1);
%     imgBin(:,1) = im2bw(imgSansBg(:,1),seuil);
    imgBin(:,1) = im2bw(ligneSansBg,seuil);
    
    % Supprésion d'éventuelle trou
    imgHole = imfill(imgBin,'holes');
    
    % Dilatation/Erosion
    imgOpen = imopen(imgHole,strel('disk',5));
    
    % Centrer des formes
    [labeledImage, numberOfCircles] = bwlabel(imgOpen(:,25:75));
    
    % Visualisation
    H = 2;
    L = 2;
    subplot(H,L,1);imagesc(imgNorm);colormap(gray); axis image;title('image initiale');
    subplot(H,L,2);imagesc(imgOpen');colormap(gray); axis image;
    hold on;plot([0 size(labeledImage,1)],[25 25],'r');plot([0 size(labeledImage,1)],[75 75],'r');
    subplot(H,L,3);imagesc(labeledImage');colormap(gray); axis image;title(numberOfCircles);
    subplot(H,L,3);imagesc(imgBg);colormap(gray); axis image;
    
   f =1/ toc(tStart)
   pause(0.001);
    
    
end