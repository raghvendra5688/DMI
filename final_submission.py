# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

from string import *
from math import *
import sys
experiment = sys.argv[1]
filename = sys.argv[2];
method = sys.argv[3];
print('Filename entered is: ',filename);

#Select the inputfile from the MHKSC results folder with cluster memberships
inputfile = experiment+'/Hierarchy_'+method+'_'+filename+'_best_list.csv';
fp = open(inputfile,'r');

#Select the confidence information from confidence file
conffile = experiment + '/Confidence_'+filename+'_best_list.csv';
fp1 = open(conffile,'r');

confvalue = experiment + '/Confidence_'+filename+'_best_value.csv';
fp2= open(confvalue,'r')
conf_value = 0.0
select_level = 0;
for line in fp2:
    line = line.strip("\r\n");
    data = line.split(",");
    print(data)
    conf_value,select_level = float(data[0]),int(data[1]);
fp2.close();

#In case of 6th network perform the following operation
if (filename=="6_homology_anonym_v3"):
    nodemap = {};
    fp4 = open('6_nodemap.txt','r');
    for line in fp4:
        line = line.strip("\r\n");
        data = line.split(" ");
        nodemap[int(data[0])] = int(data[1]);
    fp4.close();


##Read the hierarchy list and extract the level of hierarchy out
node_membership,cluster_nodes = {},{};
count = 0;
for line in fp:
    line = line.strip("\r\n");
    data = line.split(",");
    if (filename=="6_homology_anonym_v3"):
        nodeid,clusterid = nodemap[count+1]-1,int(data[select_level-1]);
    else:
        nodeid,clusterid = count,int(data[select_level-1]);
        node_membership[nodeid] = clusterid;
    if clusterid not in cluster_nodes:
        cluster_nodes[clusterid] = [nodeid];
    else:
        cluster_nodes[clusterid].append(nodeid);
    count = count+1;
fp.close();

cluster_conf = {};
for line in fp1:
    line = line.strip("\r\n");
    data = line.split(",");
    moduleid,conf = int(data[0]),float(data[1]);
    cluster_conf[moduleid] = conf;
fp1.close();

#Find clusters which are in the range >=3 and <= 100 and use only those for evaluation with confidence score>=0.01
final_cluster_info = {};
count=1;
#conf_value = 0.01
avg_mod_size = [];
for key in cluster_nodes.keys():
    #print key,cluster_nodes[key],cluster_conf[key]
    if (len(cluster_nodes[key])>=3 and len(cluster_nodes[key])<=100 and cluster_conf[key]<=conf_value):
        avg_mod_size.append(len(cluster_nodes[key]));
        confidence = 1-cluster_conf[key];
        cluster_nodes[key].insert(0,confidence);
        final_cluster_info[count] = cluster_nodes[key];
        count = count+1;

average_mod_size = (1.0*sum(avg_mod_size))/len(avg_mod_size)
print(average_mod_size)

#Create an output_submission
outfile = experiment + '/'+ filename+'_final_output_' + method + '_L'+str(select_level)+'.txt';
fp3 = open(outfile,'w');
for key in final_cluster_info.keys():
    value = final_cluster_info[key];
    outputstring =  str(key) + '\t' +  '\t'.join(str(val) for val in value);
    fp3.write(outputstring+"\n");
fp3.close();
