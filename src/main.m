clear all;
close all;
clc;

addpath('/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/img');
addpath(genpath('/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/Julien'));
imgName = 'detection_0000.jpeg';

%% Angle de l'image
%streetAngle = getImgStreetAngle(imgName);
streetAngle = -14;
img = rgb2gray(imread(imgName));

%% Selection de la ligne
ptsLine = setDetectionLine(img,streetAngle);

%% Acquisition des donn�es
figure;
dataImg = getDataDetection(200,0,ptsLine);

imagesc(dataImg');colormap(gray); axis image;

%% Suppr�ssion du fond par moyennage

dataImgFiltree = backgroundfilter(dataImg);

%% Scale
dataImgFiltreeSca = scallingImg(dataImgFiltree);

%% Seuil Hyst�r�sis par Histogramme
% imgSeuilGrad = imgHysteresis(GmagScal);
imgSeuil = imgHysteresis2(dataImgFiltreeSca);


%% Erosion
se = strel('rectangle',[3 1]);
imgErode = imerode(imgSeuil,se);
imagesc(imgErode);colormap(gray);

%% Dilatation
se = strel('disk',1);
imgDilate = imdilate(imgErode,se);
imagesc(imgDilate);colormap(gray);

%% Gradian
[Gmag,Gdir] = imgradient(dataImgFiltreeSca);
subplot(1,2,1);imagesc(Gmag);colormap(gray);
subplot(1,2,2);imagesc(Gdir);colormap(gray);

%% Plot
figure
Gx = [-1 0 1;
     -2 0 2;
     -1 0 1]
Gy = Gx';

array = decoupe(dataImg,100,100);
for i = 1:size(array,3)
    Gx_array(i,:,:) = filter2(Gx,array(:,:,i));
    Gy_array(i,:,:) = filter2(Gy,array(:,:,i));
    dataSobel = squeeze(atan2(Gy_array(i,:,:),Gx_array(i,:,:)));
    h = histogram(dataSobel,20);
    dataHist{i} = h.Values;
end



%imgFiltGra1 = filter2([-1 0 1],dataImgFiltreeSca);
%mgFiltGra2 = filter2([-1 0 1]',dataImgFiltreeSca);

%subplot(1,3,1);imagesc(Gx);colormap(gray);
%subplot(1,3,2);imagesc(Gy);colormap(gray);
% subplot(1,3,3);imagesc(max(imgFiltGra1(:,:),imgFiltGra2(:,:)));colormap(gray);
%subplot(1,3,3);imagesc(atan2(Gy,Gx));colormap(gray);