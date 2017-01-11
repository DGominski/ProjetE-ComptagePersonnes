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
N = 36;
for n = 1:N
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
%     fondName = ['fond_',num2str(n,'%0.4d'),'.jpeg'];

    data = imread(pietName);   
    pietData(n,:) =  reshape(data(:,:,:),1,[]);
    
%     data = double(imread(fondName));
%     fondData(n,:) = reshape(data(:,:,:),1,[]);
    
    % Test d'affichage
    % imagesc(squeeze(pietData(1,:,:,:)))
end

N = 200;
index = 1;
for n = 1:N
    indexImg = round(rand()*N);
    fondName = ['fond_',num2str(indexImg,'%0.4d'),'.jpeg'];
    
    if exist(fondName,'file') == 2
        data = imread(fondName);
        fondData(index,:) = reshape(data(:,:,:),1,[]);
        index = index + 1;
    end

end

dataRef = [pietData;fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage

svmStruct = svmtrain(double(dataRef),classType,'kernel_function','linear');

% Attention utilisé un noyau de classification linéaire et non quadratic
% pour la classification en RGB

%% Test avec vecteur d'apprentissage 
clear dataAlea
nb = 200;
indexAlea = ceil(rand(nb,1)*nb);
dataAlea = dataRef(indexAlea,:); 

rep = svmclassify(svmStruct,double(dataAlea));
stem(indexAlea,rep);
close all;


%%

wH = 100;
wL = 40;
step = 5;

imgName = ['detection_',num2str(150,'%0.4d'),'.jpeg'];
img = imread(imgName);
imagesc(img);
[x,y] = ginput(2);
xRect = round(x(1));
yRect = round(y(1));
wRect = ceil(abs(x(2)-x(1))/wL)*wL;
hRect = wH;

rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');

%%

for n = 1:500
    
    imgName = ['detection_',num2str(n,'%0.4d'),'.jpeg'];
    img = imread(imgName);
    subplot(2,1,1);
    imagesc(img);axis image;
    rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');

    index = 1;
    for w = xRect:step:xRect+wRect-wL
        dataImg(index,:) = reshape(img(yRect+(1:wH),w+(1:wL),:),[],1);
        index = index + 1;
    end

    rep = svmclassify(svmStruct,double(dataImg));
    subplot(2,1,2);
    stem(rep);title(['nbr : ',num2str(sum(rep))]);
    
    pause(0.0001);
end


