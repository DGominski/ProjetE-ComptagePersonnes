function [pts,index] = setDetectionLine(img)

figure;
imagesc(img);

[x,y] = ginput(2)
pt1 =[x(1) y(1)];
pt2 =[x(2) y(2)];
pts = [pt1;pt2]

% Affichage des points
hold on;
plot(pt1(1),pt1(2),'og');
plot(pt2(1),pt2(2),'og');
plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'-g');

% Calcul des index 
v = pt2-pt1;
deltaX = abs(pt2(1)-pt1(1));
deltaY = abs(pt2(2)-pt1(2));
p = round(sqrt(deltaX^2 + deltaY^2));

for t=0:p
    index(:,t+1) = round(pt1 + v*t/p);
end
    

end

