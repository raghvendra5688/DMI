from string import *;
from math import *
fp=open('out.txt','r');
fout=open('hierarchyinfo.txt','w');
count=0;
for line in fp:
    count=count+1;
count=count-2;
fout.write(str(count));
fp.close();
fout.close();
