clear all;
close all;
clc;
Y = 280;

%% TRAINING SVM

Nref = 20;
HOG_cell = [8 8];
trainSVM_HOG_Intensite;


%% BOUCLE PRINCIPALE

for K = 100:504
%% ACQUISITION DE L'IMAGE  

A = rgb2gray(imread(['detection_',num2str(K,'%4.4u'),'.jpeg']));

%% DECOUPAGE DE L'IMAGE

figure;
imagesc(A); colormap gray;
hold on;
wH = 100;
wL = 40;
dec = 10;
[imgDecoupe,decoupepos] = decoupe(A,wL,wH,dec);
nombre_de_fenetres_testees = size(imgDecoupe,3);


%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS & CLASSIFICATION
rep = zeros(nombre_de_fenetres_testees,1);
rep_int = zeros(nombre_de_fenetres_testees,1);
rep2 = zeros(nombre_de_fenetres_testees,1);
index = 1;
pos = zeros(1,2);
for i = 1 : nombre_de_fenetres_testees
    hogData = extractHOGFeatures(double(imgDecoupe(:,:,i)),'CellSize',HOG_cell);
    rep(i) = svmclassify(svmStruct,hogData);
    rep_int(i) = rep(i);
    if rep(i) == 1
        intensite = double(imgDecoupe(:,:,i));
        rep2(i) = svmclassify(svmStruct2,intensite(:)');
        if rep(i) ~= rep2(i)
           rep_int(i) = 0;
        end
    end
    if rep_int(i) == 1
        pos(index,1) = decoupepos(2,i);
        pos(index,2) = decoupepos(1,i);
        index = index + 1;
    end
end


%% GESTION DES IDENTIFICATIONS REDONDANTES

if sum(rep_int) >= 1
    rep_prob = rep_int;
    pos_prob = [pos,zeros(length(pos),1)];
    prob = 0.5;
    index = 1;
    for i = 1 : size(pos_prob,1) - 1
        for j = i : size(pos_prob,1)
            if pos_prob(j,3) == 0
                dist = sqrt((pos_prob(i,1)-pos_prob(j,1))^2 + (pos_prob(i,2)-pos_prob(j,2))^2);
                if dist <= prob*wL
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

%% DESSIN DES BOITES DE DETECTION

    hold on;
    for i = 1 : size(pos_prob,1)
        rectangle('Position', [pos_prob(i,1), pos_prob(i,2), wL, wH],'EdgeColor','r', 'LineWidth', 1)
    end
    nbrPietons_exp = length(unique(pos_prob(:,1)))
end

waitforbuttonpress;
end

