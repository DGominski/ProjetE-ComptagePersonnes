close all;
clear all;
clc;

addpath('dataSetPietonRGB');
addpath('dataSetFondRGB');
addpath('src');

%% 
N = 36;
for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.4d'),'.jpeg'];

    data = double(imread(pietName));   
    pietData(n,:) =  reshape(data(:,:,:),1,[]);
    
    data = double(imread(fondName));
    fondData(n,:) = reshape(data(:,:,:),1,[]);
    
    % Test d'affichage
    % imagesc(squeeze(pietData(1,:,:,:)))
end

dataRef = [pietData;fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');

% Attention utilisé un noyau de classification linéaire et non quadratic
% pour la classification en RGB



%% Test avec vecteur d'apprentissage 
clear dataAlea
nb = 72;
indexAlea = ceil(rand(nb,1)*nb);
dataAlea = dataRef(indexAlea,:); 

rep = svmclassify(svmStruct,dataAlea);
stem(indexAlea,rep);
close all;


%% Load data img

addpath('src');

imgName = ['detection_',num2str(200,'%0.4d'),'.jpeg'];
img = double(imread(imgName));

wL = 100;
wH = 40;
dec = 10;
vectImgDecoupe = decoupeVectRGB(img,wL,wH,dec);

for i = 1:size(dataTest,3)
    i
    temp = dataTest(:,:,i);
    rep(i) = svmclassify(svmStruct,temp(:)');
    
    close
end

%%

posPieton = vec2mat(rep,(640-40)/10);

subplot(1,2,1);imagesc(img);colormap(gray);axis equal
subplot(1,2,2);imagesc(posPieton);colormap(gray);axis equal