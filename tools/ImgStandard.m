function output_I = ImgStandard(I)
epsilon = 1e-3;
I_min = min(I(:));
I_max = max(I(:));
output_I = (I-I_min)/(I_max-I_min)*255;
output_I(output_I>(255-epsilon)) = 255-epsilon;
output_I(output_I<epsilon) = epsilon;