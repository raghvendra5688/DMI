# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

from string import *
from math import *

fp = open('subchallenge1/6_homology_anonym_v2.txt','r');
nodeid_map = {};
count = 0;
for line in fp:
    line = line.strip("\r\n");
    data = line.split("\t");
    node1,node2,weight = int(data[0]),int(data[1]),float(data[2]);
    if node1 not in nodeid_map:
        count=count+1;
        nodeid_map[node1] = count;
    if node2 not in nodeid_map:
        count = count+1;
        nodeid_map[node2] = count;
fp.close();

fout = open('6_homology_anonym_v3.txt','w');
fp = open('subchallenge1/6_homology_anonym_v2.txt','r');
for line in fp:
    line = line.strip("\r\n");
    data = line.split("\t");
    node1,node2,weight = int(data[0]),int(data[1]),float(data[2]);
    outputstring = str(nodeid_map[node1])+" "+str(nodeid_map[node2])+" "+str(weight)+"\n";
    fout.write(outputstring);
fout.close();

fout1 = open('6_nodemap.txt','w');
for key in nodeid_map.keys():
    outputstring = str(nodeid_map[key]) + " " + str(key)+"\n";
    fout1.write(outputstring);
fout1.close();

