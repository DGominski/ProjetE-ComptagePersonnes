close all;
clear all;
clc;

addpath('dataPieton');
addpath('img');
addpath('hog_feature_vector');

%% 
N = 20;
Na = 20;
Ntest = N-Na;

xx = 8;

HOG_cell = [xx xx];

for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    data = double(imread(pietName));
    %pietData(n,:) = hog_feature_vector(data);
    pietData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
    pietData2(n,:) = data(:);
    data = double(imread(fondName));
    %fondData(n,:) = hog_feature_vector(data);
    fondData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
    fondData2(n,:) = data(:);
end

dataRef = [pietData(1:Na,:);fondData(1:Na,:)];
dataRef2 = [pietData2;fondData2]';
dataTest = [pietData(Na+1:N,:);fondData(Na+1:N,:)];
classType = [ones(size(pietData(1:Na,:),1),1);zeros(size(fondData(1:Na,:),1),1)];
classType2 = [ones(size(pietData2,1),1);zeros(size(fondData2,1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');
svmStruct2 = svmtrain(dataRef2,classType2,'kernel_function','linear');


%% Test avec images selectionnees
figure;
indexAlea = ceil(rand(40,1)*40);
repSetAlea = svmclassify(svmStruct,dataRef(indexAlea,:));
stem(indexAlea,repSetAlea);


%% Load data img

addpath('src');

imgName = ['detection_',num2str(101,'%0.4d'),'.jpeg'];
img = rgb2gray(imread(imgName));

wL = 40;
wH = 100;
dec = 5;
[imgDecoupe,decoupepos] = decoupe(img,wL,wH,dec);
chemin = 'C:\Users\Isabel\Desktop\Escrit\berta\BERTA_ordenador_viejo\2 Master Industrial\TdSI\ProjetE-ComptagePersonnes-SVM_test\ProjetE-ComptagePersonnes-SVM_test\test\';

for i = 1:size(imgDecoupe,3)
    i
    %hogData = hog_feature_vector(double(imgDecoupe(:,:,i)));
    %imwrite(imgDecoupe(:,:,i),[chemin,'img_',num2str(i,'%0.6d'),'.jpeg']);
    hogData = extractHOGFeatures(double(imgDecoupe(:,:,i)),'CellSize',HOG_cell);
    rep(i) = svmclassify(svmStruct,hogData);
    rep_int(i) = rep(i);
    if rep(i) == 1
        intensite = double(imgDecoupe(:,:,i));
        rep2(i) = svmclassify(svmStruct2,intensite(:)');
        if rep(i) == rep2(i)
            imwrite(imgDecoupe(:,:,i),[chemin,'img_',num2str(i,'%0.6d'),'.jpeg']);
        else rep_int(i) = 0;
        end
    end

end

%% Representation pietons 

figure;imagesc(img);colormap(gray);
hold on
for i = 1 : length(rep)
    if rep(i) == 1
        rectangle('Position', [decoupepos(2,i), decoupepos(1,i), 40, 100],'EdgeColor','r', 'LineWidth', 1)
    end
end
figure;imagesc(img);colormap(gray);
hold on
index = 1;
for i = 1 : length(rep)
    if rep_int(i) == 1
        rectangle('Position', [decoupepos(2,i), decoupepos(1,i), 40, 100],'EdgeColor','r', 'LineWidth', 1)
        h = rectangle('Position', [decoupepos(2,i), decoupepos(1,i), 40, 100],'EdgeColor','r', 'LineWidth', 1);
        pos(index,:) = get(h,'Position');
        index = index + 1;
    end
end

%% Probabilite rectangles

    rep_prob = rep_int;
    pos_prob = [pos(:,1:2),zeros(length(pos),1)];
    prob = 0.6;
    index = 1;
    for i = 1 : size(pos_prob,1) - 1
        for j = i : size(pos_prob,1)
            if pos_prob(j,3) == 0
                dist = sqrt((pos_prob(i,1)-pos_prob(j,1))^2 + (pos_prob(i,2)-pos_prob(j,2))^2);
                if dist <= wL*prob
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
    
figure;imagesc(img);colormap(gray);
hold on
index = 1;
for i = 1 : size(pos_prob,1)
    rectangle('Position', [pos_prob(i,1), pos_prob(i,2), wL, wH],'EdgeColor','r', 'LineWidth', 1)
end

nbrPietons_exp = length(unique(pos_prob(:,1)));
%%% figure
% subplot(1,2,1);imagesc(imread('pieton_01.jpeg'));colormap(gray);
% subplot(1,2,2);[a,b] = extractHOGFeatures(imread('pieton_01.jpeg'),'CellSize',[3 3]);plot(b);
