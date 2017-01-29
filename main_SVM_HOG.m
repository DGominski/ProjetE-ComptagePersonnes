close all;
clear all;
clc;

addpath('img');
addpath('dataSetPietonRGB_64_128');
addpath('dataSetFondRGB_64_128');
addpath('param');
addpath('src');

%% Paramètres 

numToStart = 80;
nbImg = 100;

% Sliding window
wH = 128; 
wL = 64;

% Step entre 2 fenêtres de détection (en largeur)
stepPixel = 20;

% Détections redondantes 
prob = 0.35;
seuilDist = prob*wL;

% Paramètres HOG
HOG_cell = [8 8]; 
HOG_block = [8 8];
Bins = 9;

% Paramètre SVM
SVM_kernel = 'linear';

% Paramètres fonctionnels
% load('param_SVM_HOG_multiple_windows.mat');

%% Chargement des images
% Pietons
N = 200;
indexPieton = 1;
indexFond = 1;
for n = 1:N
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.4d'),'.jpeg'];
    
    if exist(pietName,'file') == 2
        data = rgb2gray(imread(pietName)); 
        pietData(indexPieton,:) = extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
        indexPieton = indexPieton + 1;
    end
    
    if exist(fondName,'file') == 2
        data = rgb2gray(imread(fondName)); 
        fondData(indexFond,:) = extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
        indexFond = indexFond + 1;
    end
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

%% Limitation de la zone de recherche
close all;
figure;
imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
img = rgb2gray(imread(imgName));
imagesc(img);colormap(gray);axis image;title ('Sélectionner les trottoirs');

[x1,y1] = ginput(2);
pt1 = [x1(1),y1(1)];
pt2 = [x1(2),y1(2)];
hold on; plot(pt1(1),pt1(2),'og');
hold on; plot(pt2(1),pt2(2),'og');
hold on; plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'-g');

[x2,y2] = ginput(2);
pt3 = [x2(1),y2(1)];
pt4 = [x2(2),y2(2)];
hold on; plot(pt3(1),pt3(2),'og');
hold on; plot(pt4(1),pt4(2),'og');
hold on; plot([pt3(1) pt4(1)],[pt3(2) pt4(2)],'-g');
pause(0.2);

% Pour éviter de tracer les trottoirs à chaque fois
% load('pts.mat');

%%
close all;
figure;
for n = numToStart:numToStart+nbImg -1 
    
    % Chargement de l'image à traiter
    imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
    img = rgb2gray(imread(imgName));
    
    % Découpe de l'image en imagettes de taille wL x wH
    [imgDecoupe,decoupepos] = decoupe2(img,wL,wH,stepPixel,pt1,pt2,pt3,pt4);
    
    % Extraction des HOG
    for i = 1:size(imgDecoupe,3)
        HOG(i,:) = extractHOGFeatures(double(imgDecoupe(:,:,i)),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
    end
    
    % Classification
    rep = svmclassify(svmStruct,HOG);
    
    % Affichage d'image avec toutes les fenêtres de détection positives
    subplot(1,2,1);imagesc(img);colormap(gray);axis image;title('Mutliples détections');
    for i = 1:size(decoupepos,2)
        if rep(i) == 1
            rectangle('Position',[decoupepos(2,i) decoupepos(1,i) wL wH],'EdgeColor','r');
        end
    end

    % Calcul des fenêtres redondantes
    index = 1;
    for i = 1:size(decoupepos,2)
        if rep(i) == 1
            pos(index,1) = decoupepos(2,i);
            pos(index,2) = decoupepos(1,i);
            index = index + 1;
        end
    end
    rep_prob = rep;
    pos_prob = [pos,zeros(size(pos,1),1)];
    index = 1;
    for i = 1 : size(pos_prob,1) - 1
        for j = i : size(pos_prob,1)
            if pos_prob(j,3) == 0
                dist = sqrt((pos_prob(i,1)-pos_prob(j,1))^2 + (pos_prob(i,2)-pos_prob(j,2))^2);
                if dist <= seuilDist
                    pos_prob(j,3) = index;
                end
            end
        end
        if pos_prob(i+1,3) == 0
            index = index + 1;
        end
    end

    for i = 1 : max(pos_prob(:,3))
        index = find(pos_prob(:,3) == i);
        pos_prob(index,1) =  mean(pos_prob(index,1));
        pos_prob(index,2) =  mean(pos_prob(index,2));
    end
    [x,y] = unique(pos_prob(:,1));
    pos_min = pos_prob(y,1:2);
    
    % Affichage d'image avec tri des redondances
    subplot(1,2,2);imagesc(img);colormap(gray);axis image;title('Tri des détections redondantes');
    for i = 1 : length(y)
        h = rectangle('Position', [pos_min(i,1), pos_min(i,2), wL, wH],'EdgeColor','r', 'LineWidth', 1);
    end
    disp(['Nombre de piétons:',num2str(length(x))]);
    
    % Pause nécessaire à l'affichage
    pause(0.0001);
end

