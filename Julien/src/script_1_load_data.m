idStart = 0;
nbImg = 200;

figure;
id = idStart + 1;
fileToload colormap(gray); axis image;= ['detection_',num2str(id,'%4.4u'),'.jpeg'];
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

A = A';