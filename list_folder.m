function [output] = list_folder()
    % Function that generates a list of the existing folders in a directory.
    files=dir;
    n=1;
    for m=1:length(files)
        if files(m).isdir==1
            output(n)=files(m);
            n=n+1;
        end
    end
end

