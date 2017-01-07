clear all;
close all;
clc;

Y = 280;
X = 200;

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
hold on; line([X 640], [Y Y]);
hold on; line([X X], [Y 480]);
tic
[array,decoupepos] = decoupe(A(Y:480,X:640),40,100,10);
nombre_de_fenetres_testees = size(array,3)
toc

%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS

tic
for i=1:nombre_de_fenetres_testees
    hogData(i,:) = extractHOGFeatures(double(array(:,:,i)),'CellSize',HOG_cell);
end
toc

%% CLASSIFICATION

tic
for i=1:nombre_de_fenetres_testees
    result(i) = svmclassify(svmStruct,hogData(i,:));
end
toc

%% GESTION DES IDENTIFICATIONS REDONDANTES


%% DESSIN DES BOITES DE DETECTION
tic
hold on;
for i=1:nombre_de_fenetres_testees
    if result(i) == 1
        rectangle('Position', [decoupepos(2,i)+X, decoupepos(1,i)+Y, 40, 100],'EdgeColor','r', 'LineWidth', 1)
    end
end
toc
waitforbuttonpress;


[previousarray,previousdecoupepos] = [array,decoupepos];
end

