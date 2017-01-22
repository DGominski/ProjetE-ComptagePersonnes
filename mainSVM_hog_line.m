close all;
clear all;
clc;

addpath('img');
addpath('dataSetPietonRGB_64_128');

% Sliding window
wH = 128; 
wL = 64;

% Step entre 2 rectangles de détection (en hauteur)
stepH = 10;

% Step entre deux fenêtre de détection (en largeur)
stepPixel = 32;

% Paramètres HOG
HOG_cell = [8 8]; 
HOG_block = [8 8];
Bins = 9;


% Rectangle de détection
imgName = ['detection_',num2str(0,'%0.4d'),'.jpeg'];
img = imread(imgName);
imagesc(img);
[x,y] = ginput(2);
xRect = round(x(1));
yRect = round(y(1));
wRect = ceil(abs(x(2)-x(1))/wL)*wL;
hRect = wH;
rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');

%% Chargement des images

% Pietons
N = 100;
index = 1;
for n = 1:N
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
     
    if exist(['dataSetPietonRGB_64_128\',pietName],'file') == 2
        data = rgb2gray(imread(pietName)); 
        pietData(index,:) = extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
        index = index + 1;
    end
end

% Fond 
% Découpe du fond dans les 3 rectangles
rect1 = im2col(img(yRect+stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
rect2 = im2col(img(yRect+(1:hRect),xRect+(1:wRect)),[wH wL]);
rect3 = im2col(img(yRect-stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
rectS = [rect1,rect2,rect3];
for index = 1:size(rectS,2)
    fondData(index,:) = extractHOGFeatures(double(vec2mat(rectS(:,index),wH)),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
end

% Vecteur de données
dataRef = [pietData;fondData];
% Vecteur binaire (0 : fond, 1 : pieton)
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage
% Test du noyau : linear(obligatoire pour l'intensité) / quadratic 
svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');

%% Test avec donées d'apprentissage 
% clear dataAlea
% nb = 150; 
% indexAlea = ceil(rand(nb,1)*nb);
% dataAlea = dataRef(indexAlea,:); 
% 
% repTest = svmclassify(svmStruct,dataAlea);
% stem(indexAlea,repTest);

%%
fps = 0;
tStart = tic;  

for n = 60:500
    
    % Affichage de l'image
    subplot(1,2,1);
    imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
    img = imread(imgName);
    imagesc(img);axis image;title(['fps : ',num2str(fps)]);
    
    % Affichage des rectangles de détection
    rectangle('Position',[xRect yRect+stepH wRect hRect],'EdgeColor','b');
    rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');
    rectangle('Position',[xRect yRect-stepH wRect hRect],'EdgeColor','g');
    
    % Calcul des rectangles
    rect1 = im2col(img(yRect+stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
    rect2 = im2col(img(yRect+(1:hRect),xRect+(1:wRect)),[wH wL]);
    rect3 = im2col(img(yRect-stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
    
    % Récupération des rectangles utiles via le stepPixel
    indexImg = round(1:stepPixel:size(rect1,2));
    rectS = [rect1(:,indexImg),rect2(:,indexImg),rect3(:,indexImg)];
    
    % Calcul des HOG
    for i = 1:size(rectS,2)
        HOG(i,:) = extractHOGFeatures(double(vec2mat(rectS(:,i),wH)'),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
    end
    
    % Classification
    rep(n,:) = svmclassify(svmStruct,HOG);
    
    % Affichage des répons
    subplot(1,2,2);
    stem(rep(n,:));

    % Calcul temps
    fps = 1/toc(tStart);
    tStart = tic; 
    
    % Pause nécessaire à l'affichage
    pause(0.001);
end
    
%% Affichage de la fenêtre chronologique

figure;
limit = round(size(rep,2)/3);
subplot(3,1,1);imagesc(rep(:,1:limit)');colormap gray;axis image
subplot(3,1,2);imagesc(rep(:,limit+1:2*limit)');colormap gray;axis image
subplot(3,1,3);imagesc(rep(:,2*limit+1:3*limit)');colormap gray;axis image


