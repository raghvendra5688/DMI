function [flag,filename] = checkfilename(filename)

flag=0;
if (strcmp(filename,'6_homology_anonym_v2'))
    command = ['python tryparse.py'];
    system(command);
    filename = '6_homology_anonym_v3';
    flag=1;
end