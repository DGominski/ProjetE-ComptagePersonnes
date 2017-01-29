close all;
clear all;
clc;

addpath('img');
addpath('src');
addpath('param');

% Variables
nbPieton = 0;   % Nombre de pietons détectés
fps = 0;        % Image par seconde

% Paramètres
nToStart = 0;   % numéro de l'image de départ
nbImg = 500;    % nombre d'images à traiter

nbSize = 100;   % Profondeur des buffers pour l'image chronologique et binaire
seuilR =0.18;   % SeuiRGB => identiques car fond gris
seuilG = 0.18;
seuilB = 0.18;
SE = strel('disk',5); % Optimal 
    
% Création de la ligne de détection
imgName = 'detection_0000.jpeg';
img = mat2gray(imread(imgName));
[pts,index] = setDetectionLine(img);
close all;

% Chargement de paramètres fonctionnels
load('param_morpho.mat');

% Initialisation des matrices
imgChrono = zeros(size(index,2),nbSize,3); % Matrice de l'image chronologique
imgBin = zeros(size(index,2),nbSize,3); % Matrice de l'image binaire

% Début de la boucle
tStart = tic;
for n = nToStart:nToStart+nbImg-1
    
    % Chargement de l'image
    imgName = ['detection_',num2str(n,'%0.4u'),'.jpeg'];
    img = double(imread(imgName));

    % Normalisation
    imgNorm = mat2gray(img);
    
    % Récupération des pixels sur la ligne de détection
    temp = imgChrono;
    imgChrono(:,2:nbSize,:) = temp(:,1:nbSize-1,:);
    for i = 1:size(index,2)
      imgChrono(i,1,:) = imgNorm(index(2,i),index(1,i),:);
    end
    if n == 0 % Si 1ère fois alors on initialise toute la matrice à cette valeur
        for i = 2:nbSize
            imgChrono(:,i,:) = imgChrono(:,1,:);
        end
    end

    % Calcul du fond
    ligneFond = mean(permute(imgChrono,[2 1 3]));
    
    % Soustraction du fond
    ligneSansBg = abs(imgChrono(:,1,:)-permute(ligneFond,[2 1 3])); 
    
    % Seuillage RGB
    temp = imgBin;
    imgBin(:,2:nbSize,:) = temp(:,1:nbSize-1,:);
    imgBin(:,1,1) = im2bw(ligneSansBg,seuilR);
    imgBin(:,1,2) = im2bw(ligneSansBg,seuilG);
    imgBin(:,1,3) = im2bw(ligneSansBg,seuilB);
    imgBinGray = imgBin(:,:,1)|imgBin(:,:,2)|imgBin(:,:,3);

    % Suppréssion d'éventuels trous
    imgHole = imfill(imgBinGray,'holes');
    
    % Erosion/Dilatation
    imgOpen = imopen(imgHole,SE);
    
    % Extraction des centres de chaque forme
    center = regionprops(imgOpen, {'Centroid'});

    
    % Visualisation
    figure(1)
    subplot(2,2,1);imagesc(imgNorm);colormap(gray); axis image;title(['image initiale    fps :',num2str(fps,'%3.2f')]);
    hold on;plot([pts(1,1) pts(2,1)],[pts(1,2) pts(2,2)],'-g');hold off;
    subplot(2,2,3);imagesc(permute(imgChrono,[2 1 3]));colormap(gray);title('image chronologique');
    subplot(2,2,4);imagesc(imgOpen');colormap(gray);title(['nb de pieton :',num2str(nbPieton)]);
    hold on;plot([0 size(imgOpen,1)],[round(nbSize/2) round(nbSize/2)],'r');hold off; % Ligne de comptage 

    
    % Comptage et affichage des centres
    nbCenter = size(center,1);
    if nbCenter > 0
        for i=1:nbCenter
            % Affichage
            hold on;plot(center(i).Centroid(2),center(i).Centroid(1),'r*');
            
            % Comptage
            if round(center(i).Centroid(1)) == round(nbSize/2)
                nbPieton = nbPieton + 1;  
            end
        end
    end
    
   fps = 1/toc(tStart);
   pause(0.0001); % Pause nécessaire pour voir les images
   tStart = tic;
end
