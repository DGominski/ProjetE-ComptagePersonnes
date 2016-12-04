function [ pts ] = setDetectionLine(img,angle)

figure;
imagesc(img); colormap(gray); axis image;

[x,y] = ginput(1)
hold on; plot(x,y,'og');

[H,L] = size(img);

angle = -angle;

ptLeft.x = 1;
ptLeft.y = y+x*tan(angle*2*pi/360)
if ptLeft.y > H % Si dépassement de la hauteur
    ptLeft.y = H;
    ptLeft.x = x-(ptLeft.y-y)*tan((90-angle)*2*pi/360)
end

ptRight.x = L; % Si dépassement de la largeur
ptRight.y = y-(L-x)*tan(angle*2*pi/360)
if ptRight.y < 1
    ptRight.y = 1;
    ptRight.x = x+y*tan((90-angle)*2*pi/360)
end

hold on; plot(ptLeft.x,ptLeft.y,'og');
hold on; plot(ptRight.x,ptRight.y,'og');
hold on; plot([ptRight.x ptLeft.x],[ptRight.y ptLeft.y],'-g');

pts = [ptLeft,ptRight];

disp('Validez avec entree');
pause;
close;

end

