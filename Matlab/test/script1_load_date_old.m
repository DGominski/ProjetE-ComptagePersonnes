clear all;
close all;
clc;

addpath('images/');

idStart = 0;
nbImg = 60;

figure;
id = idStart + 1;
fileToload = ['detection_',num2str(id,'%4.4u'),'.jpeg'];
img = imread(fileToload);
img = rgb2gray(img);
imagesc(img); colormap(gray); axis image;

%mean shift
%cam shift
[x,y] = ginput(2);
pt1 = [x(1),y(1)];
pt2 = [x(2),y(2)];
hold on; plot(pt1(1),pt1(2),'og');
hold on; plot(pt2(1),pt2(2),'og');
hold on; plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'-g');

v = pt2-pt1;
deltaX = abs(pt2(1)-pt1(1));
deltaY = abs(pt2(2)-pt1(2));
p = round(sqrt(deltaX^2 + deltaY^2));
A = zeros(p,nbImg);

for i=1:nbImg
   
    id = idStart + i;
    fileToload = ['detection_',num2str(id,'%4.4u'),'.jpeg'];
    img = imread(fileToload);
    img = rgb2gray(img);
    imagesc(img); colormap(gray); axis image;
    hold on; plot(pt1(1),pt1(2),'og');
    hold on; plot(pt2(1),pt2(2),'og');
    hold on; plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'-g');    
    title(num2str(i));
    pause(0.02);
    %disp([num2str(i),' / ',num2str(nbImg)])

    for t=0:p
        pt = round(pt1 + v*t/p);
        A(t+1,i) = img(pt(2),pt(1));
    end
end

%% Filtre moyenneur
meanColumn = mean(A,2);
Ac = A;
for j=1:size(A,2)
    Ac(:,j) = A(:,j) - meanColumn;  
end
figure; imagesc(Ac); colormap(gray);

%% Blanc et noir
Acc = convert(Ac); %Mise � l'�chelle
sz = size(Acc,1)*size(Acc,2);
Hist = hist(reshape(Acc,[sz,1]),256);
figure; hist(reshape(Acc,[sz,1]),256); axis([0 255 0 max(Hist)])
hold on
grid on
[M maxAcc] = max(Hist);

moyenne = mean(reshape(Acc,[sz,1]));
std_desv = std(reshape(Acc,[sz,1]));
pd = fitdist(reshape(Acc,[sz,1]),'Normal');
x_pdf = (0:1:255);
y = pdf(pd,x_pdf);
scale = max(Hist)/max(y);
plot(x_pdf,y.*scale)

Gradiente = diff(Hist);

par_hist = std_desv;
index = find((Acc > maxAcc + par_hist) | (Acc < maxAcc - par_hist));
Acc(index) = 255;
index2 = find(Acc ~= 255);
Acc(index2) = 0;
figure; imagesc(Acc); colormap(gray);

%% Erosion
Ace = Acc;
se = strel('square',3);
Ace = imerode(Ace,se);
figure; imagesc(Ace); colormap(gray);

%% Dilatation
Acd = Ace;
se = strel('square',3);
Acd = imdilate(Acd,se);
figure; imagesc(Acd); colormap(gray);

%% Counting
Af = Acd;
CC = bwconncomp(Af);
disp(['Number of objects:',num2str(CC.NumObjects)])
