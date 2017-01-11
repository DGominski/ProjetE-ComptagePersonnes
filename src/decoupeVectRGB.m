function [ array ] = decoupeVectRGB( A,wL,wH,step)
%decoupe l'image en rectangles de nxm et renvoie un vecteur contenant
%toutes les images obtenues en RGB, decales de 'step' pixels a chaque fois

[L H C] = size(A);

index = 1;
for h = 1:step:H-wH
    for l=1:step:L-wL
        temp = A(l:(l+wL-1),h:(h+wH-1),:);
        array(index,:) = reshape(temp,1,[]);
        index = index + 1;
    end
end

end
