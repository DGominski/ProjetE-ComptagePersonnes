close all;
clear all;
clc;

dirPieton = 'dataSetPietonRGB_64_128';
dirFond = 'dataSetFondRGB_64_128';

nbTestAleatoire = 60; 

addpath(dirPieton);
addpath(dirFond);

%% SVM + HOG


% Paramètres HOG
HOG_cell = [8 8]; 
HOG_block = [8 8];
Bins = 9;
nbPietonApprentissage = 10;
nbFondApprentissage = 10;

% Apparentissage Pietons/Fonds
nbTest = max(size(dir(dirPieton),1),size(dir(dirFond),1));
indexPieton = 1;
indexFond = 1;
for n = 1:nbTest
    numFond = ceil(rand()*size(dir(dirFond),1));
    numPieton = ceil(rand()*size(dir(dirPieton),1));
    
    pietonName = ['pieton_',num2str(numPieton,'%0.4d'),'.jpeg'];
    fondName = ['fond_',num2str(numFond,'%0.4d'),'.jpeg'];
    
    if (exist(['dataSetPietonRGB_64_128\',pietonName],'file') == 2) & (indexPieton <= nbPietonApprentissage)
        data = rgb2gray(imread(pietonName)); 
        pietData(indexPieton,:) = extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
        indexPieton = indexPieton + 1;
    end
    
    if (exist(['dataSetFondRGB_64_128\',fondName],'file') == 2) & (indexFond <= nbFondApprentissage)
        data = rgb2gray(imread(fondName)); 
        fondData(indexFond,:) = extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block);
        indexFond = indexFond + 1;
    end
end

% Vecteur de données
dataRef = [pietData;fondData];
% Vecteur binaire (0 : fond, 1 : pieton)
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');



%% Test Aléatoire

for numImg = 1:nbTestAleatoire
   
    % On enregistre la vraie réponse
    rep(numImg) = 1;

    % On choisit un fond aléatoirement
    numPieton = ceil(rand()*size(dir(dirPieton),1));
    pietonName = ['pieton_',num2str(numPieton,'%0.4d'),'.jpeg'];
    while(exist(['dataSetPietonRGB_64_128\',pietonName],'file') ~= 2)
        numPieton = ceil(rand()*size(dir(dirPieton),1));
        pietonName = ['pieton_',num2str(numPieton,'%0.4d'),'.jpeg'];
    end

    img = imread(pietonName);

    
    % Test HOG
    repTestHOGandSVM(numImg) = svmclassify(svmStruct,extractHOGFeatures(double(rgb2gray(img)),'CellSize',HOG_cell,'NumBins',Bins,'BlockSize',HOG_block));
    
    % Test Morpho
    imgNorm = mat2gray(img);
    nbLine = size(img,1);
    imgChrono = zeros(size(img,2),nbLine,3);
    imgBin = zeros(size(img,2),nbLine,3);
    nbCountPiet = 0;
    for nLine = 1:nbLine
        
        % Récupération des pixels sur la ligne de détection
        temp = imgChrono;
        imgChrono(:,2:nbLine,:) = temp(:,1:nbLine-1,:);

        imgChrono(:,1,:) = permute(imgNorm(1+nbLine-nLine,:,:),[2 1 3]);

        if nLine == 1 % Initialisation
            for i = 1:nbLine
                imgChrono(:,i,:) = imgChrono(:,1,:);
            end
        end

        % Calcul du fond
        %ligneFond = mean(permute(imgChrono(:,1:40,:),[2 1 3]));
        ligneFond = mean(permute(imgChrono(:,:,:),[2 1 3]));

        % Soustraction du fond
        ligneSansBg = abs(imgChrono(:,1,:)-permute(ligneFond,[2 1 3])); 

        % Seuillage
        seuilR =0.17; % A AJUSTER !!!!!!!!
        seuilG = 0.17; % A AJUSTER !!!!!!!!
        seuilB = 0.17; % A AJUSTER !!!!!!!!
        temp = imgBin;
        imgBin(:,2:nbLine,:) = temp(:,1:nbLine-1,:);
        imgBin(:,1,1) = im2bw(ligneSansBg,seuilR);
        imgBin(:,1,2) = im2bw(ligneSansBg,seuilG);
        imgBin(:,1,3) = im2bw(ligneSansBg,seuilB);
        imgBinGray = imgBin(:,:,1)|imgBin(:,:,2)|imgBin(:,:,3);

        % Supprésion d'éventuelle trou
        imgHole = imfill(imgBinGray,'holes');

        % Dilatation/Erosion
        imgOpen = imopen(imgHole,strel('disk',5)); % A AJUSTER !!!!!!!!

        % Centrer des formes
        center = regionprops(imgOpen, {'Centroid'});


        % Visualisation
%         figure(1)
%         subplot(2,2,1);imagesc(imgNorm);colormap(gray); axis image;title('image initiale');
%         subplot(2,2,3);imagesc(permute(imgChrono,[2 1 3]));colormap(gray);title('image chronologique');
%         subplot(2,2,4);imagesc(imgOpen');colormap(gray);title(['nb de pieton :',num2str(nbCountPiet)]);
%         hold on;plot([0 size(imgOpen,1)],[50 50],'r');hold off;
%         pause(0.0001);

        % Comptage et affichage des centres
        nbCenter = size(center,1);
        if nbCenter > 0
            for i=1:nbCenter
                % Affichage
                % hold on;plot(center(i).Centroid(2),center(i).Centroid(1),'r*');

                % Comptage
                if round(center(i).Centroid(1)) == 50
                    nbCountPiet = nbCountPiet + 1;  
                end
            end
        end
    end
    repTestMorpho(numImg) = nbCountPiet;
end

indexPieton = find(rep == 1);

nbrTotalPieton = sum(rep);

% HOG
VraiPositif = nnz(repTestHOGandSVM(indexPieton))/nbrTotalPieton*100

VraiNegatif = (nbrTotalPieton-nnz(repTestHOGandSVM(indexPieton)))/nbrTotalPieton*100


% Morpho
VraiPositif = nnz(repTestMorpho(indexPieton))/nbrTotalPieton*100

VraiNegatif = (nbrTotalPieton-nnz(repTestMorpho(indexPieton)))/nbrTotalPieton*100

