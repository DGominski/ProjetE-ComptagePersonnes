function [ dataOut ] = getDataDetection(nbImg,numStart,ptsLine)

pt1 = [ptsLine(1).x ptsLine(1).y];
pt2 = [ptsLine(2).x ptsLine(2).y];

v = pt2-pt1;
deltaX = abs(pt2(1)-pt1(1));
deltaY = abs(pt2(2)-pt1(2));
p = round(sqrt(deltaX^2 + deltaY^2));

dataOut = zeros(p,nbImg);

for i=1:nbImg
   
    id = numStart + i;
    fileToload = ['detection_',num2str(id,'%0.4u'),'.jpeg'];
    img = imread(fileToload);
    img = rgb2gray(img);

    for t=0:p
        pt = round(pt1 + v*t/p);
        dataOut(t+1,i) = img(pt(2),pt(1));
    end
end

%lineAngle = 360*atan((pt2(2)-pt1(2))/(pt2(1)-pt1(1)))/(2*pi);
%dataOut = imrotate(dataOut,lineAngle);
%dataOut = dataOut';
end

