function XYZ=spc2xyz(Spc)
% spc2xyz v1.33
%
% This function calculates the CIE (1931) XYZ values of a radiant spectrum
%
% Usage: XYZ = spc2xyz(Spc)
%
%           Spc = (n x 2) matrix
%                  Spc(:,1) = wavelength (nm)
%                  Spc(:,2) = Radiance (W m-2 sr-1 nm-1)
%
%           XYZ = (n x 3) matrix
%
if (nargin ~= 1)|(nargout ~= 1)
   if nargout == 1
      XYZ = zeros(1,3);
   end
   PrintUsage
   return
elseif ~isnumeric(Spc)
   XYZ = zeros(1,3);
   PrintUsage
   return
end
%
%
% Initialize some constants
%
%       w = wavelength in nm
% x, y, z = CIE (1931) colour-matching functions
%
w = [ 380 384 388 392 396   400 404 408 412 416 ...
      420 424 428 432 436   440 444 448 452 456 ...
      460 464 468 472 476   480 484 488 492 496 ...
      500 504 508 512 516   520 524 528 532 536 ...
      540 544 548 552 556   560 564 568 572 576 ...
      580 584 588 592 596   600 604 608 612 616 ...
      620 624 628 632 636   640 644 648 652 656 ...
      660 664 668 672 676   680 684 688 692 696 ...
      700 704 708 712 716   720 724 728 732 736 ...
      740 744 748 752 756   760 764 768 772 776 ...
      780];

x = [0.001368 0.001996 0.003301 0.005330 0.008751      0.014310 0.020748 0.033881 0.055023 0.086958 ...
     0.134380 0.198611 0.258777 0.304897 0.334351      0.348280 0.349287 0.341809 0.330041 0.314025 ...
     0.290800 0.260423 0.218407 0.173327 0.132179      0.095640 0.064581 0.041151 0.024144 0.012162 ...
     0.004900 0.002236 0.005175 0.015536 0.034815      0.063270 0.099456 0.142368 0.189140 0.238321 ...
     0.290400 0.345483 0.403378 0.464336 0.528296      0.594500 0.661570 0.728828 0.794826 0.857933 ...
     0.916300 0.967218 1.009089 1.040986 1.059794      1.062200 1.050977 1.022666 0.979331 0.923194 ...
     0.854450 0.772954 0.685602 0.601114 0.522600      0.447900 0.377533 0.313019 0.256118 0.207097 ...
     0.164900 0.129147 0.099690 0.076804 0.059807      0.046770 0.035405 0.026345 0.019600 0.014791 ...
     0.011359 0.008679 0.006627 0.005053 0.003834      0.002899 0.002197 0.001660 0.001246 0.000929 ...
     0.000690 0.000512 0.000383 0.000289 0.000219      0.000166 0.000126 0.000095 0.000072 0.000055 ...
     0.000042];

y = [0.000039 0.000057 0.000094 0.000151 0.000247      0.000396 0.000572 0.000941 0.001531 0.002455 ...
     0.004000 0.006546 0.009768 0.013583 0.018007      0.023000 0.028351 0.034521 0.041768 0.050244 ...
     0.060000 0.070911 0.083667 0.099046 0.117532      0.139020 0.162718 0.191274 0.226734 0.270185 ...
     0.323000 0.389288 0.463394 0.544512 0.629346      0.710000 0.777837 0.836307 0.884962 0.923735 ...
     0.954000 0.976023 0.990313 0.998098 0.999857      0.995000 0.982724 0.963857 0.938499 0.907006 ...
     0.870000 0.827581 0.781192 0.732422 0.682219      0.631000 0.579638 0.528353 0.478030 0.429080 ...
     0.381000 0.332818 0.286594 0.244890 0.208162      0.175000 0.145126 0.118779 0.096189 0.077121 ...
     0.061000 0.047550 0.036564 0.028077 0.021801      0.017000 0.012835 0.009533 0.007085 0.005343 ...
     0.004102 0.003134 0.002393 0.001825 0.001384      0.001047 0.000793 0.000599 0.000450 0.000335 ...
     0.000249 0.000185 0.000138 0.000104 0.000079      0.000060 0.000045 0.000034 0.000026 0.000020 ...
     0.000015];

z = [0.006450 0.009415 0.015588 0.025203 0.041438      0.067850 0.098540 0.161304 0.262611 0.416209 ...
     0.645600 0.959439 1.258123 1.494804 1.656405      1.747060 1.780433 1.779198 1.764039 1.733560 ...
     1.669200 1.564528 1.389880 1.187824 0.994198      0.812950 0.652105 0.520338 0.416184 0.334858 ...
     0.272000 0.223453 0.179225 0.138376 0.103905      0.078250 0.060788 0.047753 0.036936 0.027712 ...
     0.020300 0.014585 0.010378 0.007382 0.005304      0.003900 0.002935 0.002309 0.001948 0.001766 ...
     0.001650 0.001458 0.001205 0.001049 0.000969      0.000800 0.000645 0.000435 0.000283 0.000230 ...
     0.000190 0.000117 0.000065 0.000039 0.000028      0.000020 0.000012 0.000003 0.000000 0.000000 ...
     0.000000 0.000000 0.000000 0.000000 0.000000      0.000000 0.000000 0.000000 0.000000 0.000000 ...
     0.000000 0.000000 0.000000 0.000000 0.000000      0.000000 0.000000 0.000000 0.000000 0.000000 ...
     0.000000 0.000000 0.000000 0.000000 0.000000      0.000000 0.000000 0.000000 0.000000 0.000000 ...
     0.000000];

XYZ = zeros(1,3);

[m,n] = size(Spc);

for i=1:m
   if (Spc(i,1) >= w(1))&(Spc(i,1) <= w(end))
	   XYZ(1) = XYZ(1) + Spc(i,2)*interp1(w,x,Spc(i,1));
   	XYZ(2) = XYZ(2) + Spc(i,2)*interp1(w,y,Spc(i,1));
      XYZ(3) = XYZ(3) + Spc(i,2)*interp1(w,z,Spc(i,1));
   end
end

BinWidth = (Spc(end,1) - Spc(1,1))/(length(Spc(:,1)) - 1);

XYZ = XYZ*683*BinWidth;

return
%--------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n spc2xyz v1.33\n\n')
fprintf(' This function calculates the CIE (1931) XYZ values of a radiant spectrum\n\n')
fprintf(' Usage: XYZ = spc2xyz(Spc)\n\n')
fprintf('           Spc = (n x 2) matrix\n')
fprintf('                  Spc(:,1) = wavelength (nm)\n')
fprintf('                  Spc(:,2) = Radiance (W m-2 sr-1 nm-1)\n\n')
fprintf('           XYZ = (n x 3) matrix\n\n')

return