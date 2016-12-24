clear all;
close all;
clc;

Y = 280;

%% TRAINING SVM

Nref = 20;
HOG_cell = [2 2];
trainSVM;

%% ACQUISITION DE L'IMAGE

img = imread('detection_0330.jpeg');
img = rgb2gray(img);

%% MOYENNAGE POUR ELIMINATION DE L'ARRIERE PLAN

% Ac = backgroundfilter(A);
% figure;
% histogram(Ac);

%% DECOUPAGE DE L'IMAGE

figure;
imagesc(img); colormap gray;
hold on; line([0 640], [Y Y]);
[array,decoupepos] = decoupe(img(280:480,:),40,100,40);
nombre_de_fenetres_testees = size(array,3)

%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS

for i=1:nombre_de_fenetres_testees
    hogData(i,:) = extractHOGFeatures(double(array(:,:,i)),'CellSize',HOG_cell);
end


%% CLASSIFICATION

for i=1:nombre_de_fenetres_testees
    result(i) = svmclassify(svmStruct,hogData(i,:));
end


%% GESTION DES IDENTIFICATIONS REDONDANTES


%% DESSIN DES BOITES DE DETECTION

for i=1:nombre_de_fenetres_testees
    if result(i) == 1
        figure;
        imagesc(array(:,:,i));
    end
end


