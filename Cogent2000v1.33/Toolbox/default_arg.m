function arg = default_arg( default, args, n )
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

if length(args) < n
    arg = default;
else
    arg = args{n};
end