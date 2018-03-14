function [cominfo] = louvain_hierarchy(filename,weighted)
command= ['mv ',filename,'_mod.txt Community_latest/',filename,'_mod.txt'];
system(command);
cd Community_latest;
system('make');
cd ..;
disp('Part 0 of Louvain method done');
clear command;
if (weighted==1)
    command = ['Community_latest/./convert -i Community_latest/',filename,'_mod.txt -o Community_latest/',filename,'.bin -w Community_latest/',filename,'.weights'];
else
    command = ['Community_latest/./convert -i Community_latest/',filename,'_mod.txt -o Community_latest/',filename,'.bin'];
end;
system(command);
disp('First part of Louvain method done');
if (weighted~=1)
    command = ['Community_latest/./community Community_latest/',filename,'.bin -l -1 -v > Community_latest/',filename,'.tree'];
else
    command = ['Community_latest/./community Community_latest/',filename,'.bin -l -1 -w Community_latest/',filename,'.weights > Community_latest/',filename,'.tree'];
end;
system(command);
disp('Second part of Louvain method done');
command = ['Community_latest/./hierarchy Community_latest/',filename,'.tree > out.txt'];
system(command);
disp('Third part of Louvain method done\n');
command = 'python hierarchyinfo.py';
system(command);
data = load('hierarchyinfo.txt','-ascii');
cominfo = [];
for i=1:data
    command = ['Community_latest/./hierarchy Community_latest/',filename,'.tree -l ',num2str(i),' > Groundtruth.txt'];
    system(command);
    newdata = load('Groundtruth.txt','-ascii');
    tempcominfo = newdata(:,2);
    cominfo = [cominfo tempcominfo(tempcominfo(:)>0)];
    command = ['rm Groundtruth.txt'];
    system(command);
end;
%% To remove all the extra information in Community_latest folder
command = ['rm out.txt hierarchyinfo.txt Community_latest/',filename,'.bin ','Community_latest/',filename,'.tree ','Community_latest/',filename,'_mod.txt ','Community_latest/',filename,'.weights'];
system(command);
cd Community_latest;
system('make clean');
cd ..;
clear command;