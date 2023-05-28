% where u is the noisy input image.
function [frth]=fpdepyou(u,iteration,dt)
% I = Noisy Image
% T - Threshold , Based on the threshold you will get scale sapce images. At a particular 
% value of T you will gwt the converged image. 
% Time step   -  0.25 a good experimental step time
u=double(u);

for  t=1:iteration
    
    [ux,uy]=gradient(u);                        %get ?u
    [uxx,~]=gradient(ux);                        %get ??/?x(?u)
    [~,uyy]=gradient(uy);                        %get ??/?y(?u)
                                                 %we have now ?^2(u)
    c=1./(1.+sqrt(uxx.^2+uyy.^2)+0.0000001);     %get g(n) = ?(|?^2(?)|)
    [div1,~]=gradient(c.*uxx);                   %get ??/?x(g(n))
    [~,div2]=gradient(c.*uyy);                   %get ??/?y(g(n))
    [div11,~]=gradient(div1);                    %get ??/?x(??/?x(g(n))
    [~,div22]=gradient(div2);                    %get ??/?y(??/?y(g(n))
                                                 %we have now ?^2(g(n))
    div=div11+div22;                             %?^2[g(n)] 
    
    u=u-(dt.*div);                               %u(n+1) = u(n) - dt*?^2[g(n)]
                
end
frth=uint8(u);% Converting to 8 bit image