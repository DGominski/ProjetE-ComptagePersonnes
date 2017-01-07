close all;
clear all;
clc;

addpath('img');
addpath('src');

freqAff = 1; % 4 => 1 sur 4 images
H = 2;
L = 2;
    
% Ligne de d�tection
imgName = 'detection_0000.jpeg';
img = mat2gray(imread(imgName));
[pts,index] = setDetectionLine(img);


% Boucle
nToStart = 0;
nToEnd = 100;

nbImg = 100;
imgChrono = zeros(size(index,2),nbImg,3);
imgBin = zeros(size(index,2),nbImg,3);

temp = img;

close all;
figure;
nb = 0;
fps = 0;
for n = 0:500
    tStart = tic;
    
    % Chargement de l'image
    imgName = ['detection_',num2str(n,'%0.4u'),'.jpeg'];
    img = double(imread(imgName));
    
    % Normalisation
    imgNorm = mat2gray(img);
    
    % R�cup�ration des pixels sur la ligne de d�tection
    temp = imgChrono;
    imgChrono(:,2:nbImg,:) = temp(:,1:nbImg-1,:);
    for i = 1:size(index,2)
      imgChrono(i,1,:) = imgNorm(index(2,i),index(1,i),:);
    end
    if n == 0
        for i = 2:nbImg
            imgChrono(:,i,:) = imgChrono(:,1,:);
        end
    end
    
    % Calcul du fond
    ligneFond = mean(permute(imgChrono,[2 1 3]));
    
    % Soustraction du fond
    ligneSansBg = abs(imgChrono(:,1,:)-permute(ligneFond,[2 1 3])); 
    
    % Seuillage
    seuilR =0.15; % A AJUSTER !!!!!!!!
    seuilG = 0.15; % A AJUSTER !!!!!!!!
    seuilB = 0.15; % A AJUSTER !!!!!!!!
    temp = imgBin;
    imgBin(:,2:nbImg,:) = temp(:,1:nbImg-1,:);
    imgBin(:,1,1) = im2bw(ligneSansBg,seuilR);
    imgBin(:,1,2) = im2bw(ligneSansBg,seuilG);
    imgBin(:,1,3) = im2bw(ligneSansBg,seuilB);
    imgBinGray = imgBin(:,:,1)|imgBin(:,:,2)|imgBin(:,:,3);

    % Suppr�sion d'�ventuelle trou
    imgHole = imfill(imgBinGray,'holes');
    
    % Dilatation/Erosion
    imgOpen = imopen(imgHole,strel('disk',5)); % A AJUSTER !!!!!!!!
    
    % Centrer des formes
    center = regionprops(imgOpen, {'Centroid'});
    
    % Visualisation
    if mod(n,freqAff) == 0
        subplot(H,L,1);imagesc(imgNorm);colormap(gray); axis image;title(['image initiale    fps :',num2str(fps)]);
        hold on;plot([pts(1,1) pts(2,1)],[pts(1,2) pts(2,2)],'-g');
        subplot(H,L,3);imagesc(permute(imgChrono,[2 1 3]));colormap(gray); axis image;title('image chronologique');
        subplot(H,L,4);imagesc(imgOpen');colormap(gray); axis image;title(['nb de pieton :',num2str(nb)]);
        hold on;plot([0 size(imgOpen,1)],[50 50],'r');
    end
    
    % Comptage et affichage des centres
    nbCenter = size(center,1);
    if nbCenter > 0
        for i=1:nbCenter
            % Affichage
            if mod(n,freqAff) == 0
                hold on;plot(center(i).Centroid(2),center(i).Centroid(1),'r*');
            end
            % Comptage
            if round(center(i).Centroid(1)) == 50
                nb = nb + 1;  
            end
        end
    end
   
   fps =1/ toc(tStart)
   pause(0.001);
end