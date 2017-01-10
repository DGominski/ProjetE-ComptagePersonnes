clear all;
close all;
clc;

addpath('C:\Users\Isabel\Desktop\Escrit\berta\BERTA_ordenador_viejo\2 Master Industrial\TdSI\ProjetE-ComptagePersonnes-dgm\ProjetE-ComptagePersonnes-dgm\data2\')
addpath('C:\Users\Isabel\Desktop\Escrit\berta\BERTA_ordenador_viejo\2 Master Industrial\TdSI\ProjetE-ComptagePersonnes-dgm\ProjetE-ComptagePersonnes-dgm\img\')
addpath('C:\Users\Isabel\Desktop\Escrit\berta\BERTA_ordenador_viejo\2 Master Industrial\TdSI\ProjetE-ComptagePersonnes-dgm\ProjetE-ComptagePersonnes-dgm\Matlab\')

%% TRAINING SVM

Nref = 50;
HOG_cell = [20 20];
trainSVM_HOG_Intensite;

%% ACQUISITION DE L'IMAGE
N1 = 102;
N2 = 220; 
for i = N1 : N2
    imgarray(:,:,i) = rgb2gray(imread(['detection_',num2str(i,'%4.4u'),'.jpeg']));
end

%% LIMITER ZONE DE RECHERCHE DE PIÉTONS
figure;
imagesc(imgarray(:,:,N1)); colormap gray; hold on
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
pause(0.1)

%% DEFINITION PARAMETRES FENETRE GLISSANTE
wH = 100;
wL = 40;
step = 7;

%% BOUCLE PRINCIPALE

for K = N1 : N2
    %% ACQUISITION DE L'IMAGE  
    A = imgarray(:,:,K);
%     if K == N1 || rem(K-N1,10) == 0
        %% DECOUPAGE DE L'IMAGE
        tic
        figure;
        imagesc(A); colormap gray;
        hold on; 
        [imgDecoupe,decoupepos] = decoupe2(A,wL,wH,step,pt1,pt2,pt3,pt4);
        nombre_de_fenetres_testees = size(imgDecoupe,3);
        dec_time = toc

        %% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS & CLASSIFICATION
        tic
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

        extr_time = toc

        %% GESTION DES IDENTIFICATIONS REDONDANTES
        tic
        if sum(rep_int) >= 1
            rep_prob = rep_int;
            pos_prob = [pos,zeros(size(pos,1),1)];
            prob = 0.475;
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
            idred_time = toc 
            [x,y] = unique(pos_prob(:,1));
            pos_min = pos_prob(y,1:2);
            %% DESSIN DES BOITES DE DETECTION
            tic
            hold on;
            for i = 1 : length(y)
                rectangle('Position', [pos_min(i,1), pos_min(i,2), wL, wH],'EdgeColor','r', 'LineWidth', 1)
            end
            nbrPietons_exp = length(x);

            dessin_time = toc
        end
        pause(0.00000001)
%     else
%         tic
%         figure;
%         imagesc(A); colormap gray;
%         hold on; 
%         [x,y] = unique(pos_prob(:,1));
%         pos_min = pos_prob(y,1:2);
%         [imgDecoupe,decoupepos] = decoupe3(A,wL,wH,step,pos_min);
%         nombre_de_fenetres_testees = size(imgDecoupe,3);
%         dec_time = toc
% 
%         %% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS & CLASSIFICATION
%         tic
%         rep = zeros(nombre_de_fenetres_testees,1);
%         rep_int = zeros(nombre_de_fenetres_testees,1);
%         rep2 = zeros(nombre_de_fenetres_testees,1);
%         index = 1;
%         pos = zeros(1,2);
%     
%         for i = 1 : nombre_de_fenetres_testees
%             hogData = extractHOGFeatures(double(imgDecoupe(:,:,i)),'CellSize',HOG_cell);
%             rep(i) = svmclassify(svmStruct,hogData);
%             rep_int(i) = rep(i);
%             if rep(i) == 1
%                 intensite = double(imgDecoupe(:,:,i));
%                 rep2(i) = svmclassify(svmStruct2,intensite(:)');
%                 if rep(i) ~= rep2(i)
%                     rep_int(i) = 0;
%                 end
%             end
%             if rep_int(i) == 1
%                 pos(index,1) = decoupepos(2,i);
%                 pos(index,2) = decoupepos(1,i);
%                 index = index + 1;
%             end
%         end
% 
%         extr_time = toc
% 
%         %% GESTION DES IDENTIFICATIONS REDONDANTES
%         tic
%         if sum(rep_int) >= 1
%             rep_prob = rep_int;
%             pos_prob = [pos,zeros(size(pos,1),1)];
%             prob = 0.5;
%             index = 1;
%             for i = 1 : size(pos_prob,1) - 1
%                 for j = i : size(pos_prob,1)
%                     if pos_prob(j,3) == 0
%                         dist = sqrt((pos_prob(i,1)-pos_prob(j,1))^2 + (pos_prob(i,2)-pos_prob(j,2))^2);
%                         if dist <= prob*wL
%                             pos_prob(j,3) = index;
%                         end
%                     end
%                 end
%                 if pos_prob(i+1,3) == 0
%                     index = index + 1;
%                 end
%             end
% 
%             for i = 1 : max(pos_prob(:,3))
%                 index = find(pos_prob(:,3) == i);
%                 pos_prob(index,1) =  mean(pos_prob(index,1));
%                 pos_prob(index,2) =  mean(pos_prob(index,2));
%             end
%             idred_time = toc 
%             
%             %% DESSIN DES BOITES DE DETECTION
%             tic
%             hold on;
%             for i = 1 : size(pos_prob,1)
%                 rectangle('Position', [pos_prob(i,1), pos_prob(i,2), wL, wH],'EdgeColor','r', 'LineWidth', 1)
%             end
%             nbrPietons_exp = length(unique(pos_prob(:,1)));
% 
%             dessin_time = toc
%         end
%         pause(0.00000001)    
%     end
end

