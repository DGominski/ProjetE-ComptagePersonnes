close all;
clear all;
clc;

addpath('dataSetPietonRGB');
addpath('dataSetFondRGB');
addpath('src');
addpath('img');
addpath('data');
addpath('dataDetect');
cheminOut = 'D:\Documents\INSA LYON\2016-2017\Mini-projet-TDSI-Git\ProjetE-ComptagePersonnes\dataDetect\';

%% 


wH = 100;
wL = 40;
step = 3;

imgName = ['detection_',num2str(0,'%0.4d'),'.jpeg'];
img = imread(imgName);
imagesc(img);
[x,y] = ginput(2);
xRect = round(x(1));
yRect = round(y(1));
wRect = ceil(abs(x(2)-x(1))/wL)*wL;
hRect = wH;

rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');
%%

HOG_cell = [20 20];
Bins = 9;

N = 36;
for n = 1:N
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
    
    data = imread(pietName);   
    pietData(n,:) = [extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins)];% double(reshape(data,[],1))'];
    
end

% N = 200;
% index = 1;
% for n = 1:N
%     indexImg = round(rand()*N);
%     fondName = ['fond_',num2str(indexImg,'%0.4d'),'.jpeg'];
%     
%     if exist(fondName,'file') == 2
%         data = imread(fondName);
%         fondData(index,:) = [extractHOGFeatures(double(data),'CellSize',HOG_cell,'NumBins',Bins)];% double(reshape(data,[],1))'];
%         index = index + 1;
%     end
% 
% end
index = 1;
stepH = 10;
for w = xRect:1:xRect+wRect-wL
    for h = stepH+yRect:-stepH:yRect-stepH
        fondData(index,:) = [extractHOGFeatures(double(img(h+(1:wH),w+(1:wL))),'CellSize',HOG_cell,'NumBins',Bins)];
        index = index + 1;
    end
    
end
    

dataRef = [pietData;fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','quadratic');

% Attention utilisé un noyau de classification linéaire et non quadratic
% pour la classification en RGB

%% Test avec vecteur d'apprentissage 
clear dataAlea
nb = 50;
indexAlea = ceil(rand(nb,1)*nb);
dataAlea = dataRef(indexAlea,:); 

repTest = svmclassify(svmStruct,dataAlea);
stem(indexAlea,repTest);


%%
fps = 0;
for n = 120:500
    tStart = tic;
    
    imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
    img = imread(imgName);
    subplot(4,1,1);
    imagesc(img);axis image;title(['fps : ',num2str(fps)]);
    rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');

    index = 1;
    for w = xRect:step:xRect+wRect-wL
        % dataImg(index,:) = reshape(img(yRect+(1:wH),w+(1:wL)),[],1);
        dataImg1(index,:) = [extractHOGFeatures(double(img(yRect-stepH+(1:wH),w+(1:wL))),'CellSize',HOG_cell,'NumBins',Bins)];
        dataImg2(index,:) = [extractHOGFeatures(double(img(yRect+(1:wH),w+(1:wL))),'CellSize',HOG_cell,'NumBins',Bins)];
        dataImg3(index,:) = [extractHOGFeatures(double(img(yRect+stepH+(1:wH),w+(1:wL))),'CellSize',HOG_cell,'NumBins',Bins)];
        index = index + 1;
    end

    rep = svmclassify(svmStruct,[dataImg1;dataImg2;dataImg3]);
    nb = index - 1;
    subplot(4,1,2);stem(rep(1:nb-1));
    subplot(4,1,3);stem(rep(nb:2*nb-1));
    subplot(4,1,4);stem(rep(2*nb:3*nb-1));
    
    sauvRep(n,1,:) = rep(1:nb);
    sauvRep(n,2,:) = rep(nb+1:2*nb);
    sauvRep(n,3,:) = rep(2*nb+1:3*nb);
    
    fps = 1/toc(tStart);
    pause(0.0001);
end

%%

figure;

subplot(3,1,1);imagesc(squeeze(sauvRep(:,1,:)));colormap gray;axis image
subplot(3,1,2);imagesc(squeeze(sauvRep(:,2,:)));colormap gray;axis image
subplot(3,1,3);imagesc(squeeze(sauvRep(:,3,:)));colormap gray;axis image


