close all;
clear all;
clc;

addpath('img');
addpath('dataSetPietonRGB_64_128');
addpath('param');

%% Paramètres 

numToStart = 1;
nbImg = 460;
nbPieton = 0;
fps = 0;

% Sliding window
wH = 128; 
wL = 64;

% Step entre 2 rectangles de détection (en hauteur)
stepH = 20;

% Step entre 2 fenêtres de détection (en largeur)
stepPixel = 32;

% Paramètres HOG
HOG_cell = [8 8]; 
HOG_block = [8 8];
Bins = 9;

% Paramètre SVM
SVM_kernel = 'linear';

% Chargement de paramètres fonctionnels
% load('param_SVM_HOG_line.mat');

%% Rectangle de détection
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
     
    if exist(pietName,'file') == 2
        data = rgb2gray(imread(pietName)); 
        pietData(index,:) = extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
        index = index + 1;
    end
end

% Fond 
% Découpe du fond dans les 2 rectangles
rectH = im2col(img(yRect+stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
rectL = im2col(img(yRect+(1:hRect),xRect+(1:wRect)),[wH wL]);

% Récupération des rectangles utiles via le stepPixel
indexImg = round(1:stepPixel:size(rectH,2));
rectS = [rectH(:,indexImg),rectL(:,indexImg)];
for index = 1:size(rectS,2)
    fondData(index,:) = extractHOGFeatures(double(vec2mat(rectS(:,index),wH)),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
end

% Vecteur de données
dataRef = [pietData;fondData];
% Vecteur binaire (0 : fond, 1 : pieton)
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage
svmStruct = svmtrain(dataRef,classType,'kernel_function',SVM_kernel);

%% Test avec données d'apprentissage 
% clear dataAlea
% nb = size(dataRef,1); 
% indexAlea = ceil(rand(nb,1)*nb);
% dataAlea = dataRef(indexAlea,:); 
% 
% repTest = svmclassify(svmStruct,dataAlea);
% stem(indexAlea,repTest);title('Test aléatoire sur les données d''apprentissage');
% hold on;plot([size(pietData,1) size(pietData,1)],[0 1],'r'); hold off;


%% Boucle
close all;

% Initialisation du vecteur de réponse
rep = zeros(nbImg,size(rectS,2));

tStart = tic;  
for n = numToStart:numToStart+nbImg -1 
    
    % Affichage de l'image et des rectangles de détection
    imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
    img = imread(imgName);

    subplot(3,1,1);
    imagesc(img);axis image;title(['fps : ',num2str(fps)]);
    rectangle('Position',[xRect yRect+stepH wRect hRect],'EdgeColor','b');
    rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');
    
    % Calcul des fenêtres de détection dans les rectangles de détection
    rectH = im2col(img(yRect+stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
    rectL = im2col(img(yRect+(1:hRect),xRect+(1:wRect)),[wH wL]);
    
    % Récupération des fenpetres utiles via le stepPixel
    indexImg = round(1:stepPixel:size(rectH,2));
    rectS = [rectH(:,indexImg),rectL(:,indexImg)];
    
    % Calcul des HOG
    for i = 1:size(rectS,2)
        HOG(i,:) = extractHOGFeatures(double(vec2mat(rectS(:,i),wH)'),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
    end
    
    % Classification
    rep(n,:) = svmclassify(svmStruct,HOG);
    
    % Affichage des réponses
    limit = round(size(rep,2)/2);
    subplot(3,1,2);stem(rep(n,1:limit));colormap gray;axis image;title('Réponses rectangle bleu (bas)');
    subplot(3,1,3);stem(rep(n,limit+1:2*limit));colormap gray;axis image;title('Réponses rectangle rouge (haut)');

    % Calcul temps
    fps = 1/toc(tStart);
    tStart = tic; 
    
    % Pause nécessaire à l'affichage
    pause(0.0001);
end



