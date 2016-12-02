% test window scroll function untuk memblur gambar. Gunakan mouse scroll
% untuk memperluas atau mempersempit lokasi blur
function testWindowScroll 
clear all; 
clc; 
f = figure('WindowScrollWheelFcn',@sliderHandle,'menubar', 'none' ); 
ax = axes('parent', f, 'units', 'pix' ); 
im = (imread('gambar 1/lion-test.jpg')); % disesuaikan 

imshow(im,'parent', ax); 

sizeImage = size(im);
w = sizeImage(2); 
h = sizeImage(1); 
halfW = double(w)/2; 
halfH = double(h)/2;
maxD = min(w,h)/2; 

initD = 100; 

blurImage(initD); 

    function sliderHandle(src, event)
        m = get(0, 'PointerLocation'); 
        xMouse = m(1); 
        yMouse = m(2); 
        
        posFig = get(f, 'position'); 
        xFig = posFig(1); 
        yFig = posFig(2); 
        widthFig = posFig(3); 
        heightFig = posFig(4); 
        
        if (xMouse > xFig ) && (yMouse > yFig ) && ... 
                (xMouse < xFig + widthFig ) && ... 
                (yMouse < yFig + heightFig )
            if event.VerticalScrollCount < 0  % up 
                initD = initD + 3; 
            elseif event.VerticalScrollCount > 0 % down 
                if initD - 3 > 0 
                   initD = initD - 3;
                end
            end     
            blurImage(initD);
        end
    end

    function blurImage(d)
        if d < maxD
            [xx,yy] = ndgrid(( 1:h )-halfH , ( 1:w ) - halfW ) ; 
            mask = uint8( ( xx.^2 + yy.^2 ) > d^2);
            G = fspecial('disk', 10); 
            cropped = uint8(zeros(sizeImage)); 
            cropped(:,:,1) = roifilt2(G ,im(:,:,1) , mask ); 
            cropped(:,:,2) = roifilt2(G ,im(:,:,2) , mask ); 
            cropped(:,:,3) = roifilt2(G ,im(:,:,3) , mask ); 
            imshow( cropped );  
            drawnow; 
        end
    end
end 
