clear all;
close all;
clc;

Y = 280;

%% TRAINING SVM

Nref = 30;
HOG_cell = [3 3];
trainSVM;

%% ACQUISITION DE L'IMAGE

for i=1:504
    imgarray(:,:,i) = rgb2gray(imread(['detection_',num2str(i,'%4.4u'),'.jpeg']));
end


%% BOUCLE PRINCIPALE



for K=320:504
    
A = imgarray(:,:,K);


%% DECOUPAGE DE L'IMAGE

figure;
imagesc(A); colormap gray;
hold on; line([0 640], [Y Y]);
[array,decoupepos] = decoupe(A(280:480,:),40,100,45);
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

hold on;
for i=1:nombre_de_fenetres_testees
    if result(i) == 1
        rectangle('Position', [decoupepos(2,i+1), decoupepos(1,i+1)+280, 40, 100],'EdgeColor','r', 'LineWidth', 1)
    end
end

waitforbuttonpress;
end

