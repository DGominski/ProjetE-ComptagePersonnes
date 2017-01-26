close all;
clear all;
clc;

addpath('img');
addpath('dataSetPietonRGB_64_128');

% Sliding window
wH = 128; 
wL = 64;

% Step entre 2 rectangles de détection (en hauteur)
stepH = 5;

% Step entre deux fenêtre de détection (en largeur)
stepPixel = 46;

% Paramètres HOG
HOG_cell = [8 8]; 
HOG_block = [8 8];
Bins = 9;


% Rectangle de détection
imgName = ['detection_',num2str(0,'%0.4d'),'.jpeg'];
img = imread(imgName);
imagesc(img);
% [x,y] = ginput(2);
% xRect = round(x(1));
% yRect = round(y(1));
% wRect = ceil(abs(x(2)-x(1))/wL)*wL;
% hRect = wH;
xRect = 139;
yRect = 170;%231;
wRect = 448;
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
close all;
numToStart = 1;
nbImg = 460;
rep = zeros(nbImg,size(rectS,2));

thresCount = 8;
infoBlock.nbZerosFollowing = zeros(size(rep,2),1);
infoBlock.nbOnesFollowing = zeros(size(rep,2),1);
infoBlock.nbBeforeEn = zeros(size(rep,2),1);
infoBlock.nbBeforeRest = zeros(size(rep,2),1);;
nbPieton = 0;
for n = numToStart:numToStart+nbImg -1 
    
    % Affichage de l'image et des rectangles de détection
    imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
    img = imread(imgName);
    n
%    subplot(1,3,1);
%    imagesc(img);axis image;title(['fps : ',num2str(fps)]);
%    rectangle('Position',[xRect yRect+stepH wRect hRect],'EdgeColor','b');
%    rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');
    
    % Calcul des rectangles
    rectH = im2col(img(yRect+stepH+(1:hRect),xRect+(1:wRect)),[wH wL]);
    rectL = im2col(img(yRect+(1:hRect),xRect+(1:wRect)),[wH wL]);
    
    % Récupération des rectangles utiles via le stepPixel
    indexImg = round(1:stepPixel:size(rectH,2));
    rectS = [rectH(:,indexImg),rectL(:,indexImg)];
    
    % Calcul des HOG
    for i = 1:size(rectS,2)
        HOG(i,:) = extractHOGFeatures(double(vec2mat(rectS(:,i),wH)'),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
    end
    
    % Classification
    rep(n,:) = svmclassify(svmStruct,HOG);
    repNow = rep(n,:);
    
    % Affichage des répons
    % limit = round(size(rep,2)/2);
    % subplot(1,3,2);stem(rep(n,1:limit));colormap gray;axis image
    % subplot(1,3,3);stem(rep(n,limit+1:2*limit));colormap gray;axis image

    % Pseudo Tracking
    for i = 1:length(repNow)
        if infoBlock.nbBeforeEn(i) == 0
            if repNow(i) == 1
                infoBlock.nbZerosFollowing(i) = 0; % Reset des zeros
                infoBlock.nbOnesFollowing(i) = infoBlock.nbOnesFollowing(i) + 1; % Incrément des ones
            end
            if repNow(i) == 0
                infoBlock.nbOnesFollowing(i) = 0; % Reset des ones
                infoBlock.nbZerosFollowing(i) = infoBlock.nbZerosFollowing(i) + 1; % Incrément des zeros
            end
            if infoBlock.nbOnesFollowing(i) >= thresCount
                nbPieton = nbPieton + 1
                infoBlock.nbBeforeEn(i) = thresCount;
                infoBlock.nbOnesFollowing(i) = 0;
                infoBlock.nbZerosFollowing(i) = 0;
                infoBlock.nbBeforeRest(i) = thresCount;
            end
        else
            if ((infoBlock.nbBeforeRest(i) > 0) & (repNow(i) == 0))
                infoBlock.nbBeforeRest(i) = infoBlock.nbBeforeRest(i) - 1;
            else
                if ((infoBlock.nbBeforeRest(i) > 0) & (repNow(i) == 1))
                    infoBlock.nbBeforeRest(i) = thresCount;
                else
                    infoBlock.nbBeforeEn(i) = infoBlock.nbBeforeEn(i) - 1;
                end
            end
        end       
    end
    
    % Calcul temps
    fps = 1/toc(tStart);
    tStart = tic; 
    
    % Pause nécessaire à l'affichage
    pause(0.0001);
end
    
%% Affichage de la fenêtre chronologique

figure;
limit = round(size(rep,2)/2);
subplot(2,1,1);imagesc(rep(:,1:limit)');colormap gray;axis image
subplot(2,1,2);imagesc(rep(:,limit+1:2*limit)');colormap gray;axis image



