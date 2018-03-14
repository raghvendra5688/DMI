==============================================================================================
These data have been downloaded as part of the DREAM11 DISEASE MODULE IDENTIFICATION CHALLENGE

ALL DATA AND RESULTS ARE EMBARGOED UNTIL PUBLICATION OF THE MAIN CHALLENGE PAPER.
See the Challenge website for further information and data access conditions.

Challenge website: https://www.synapse.org/modulechallenge
==============================================================================================

VERSION
-------

- Anonymized networks for SUB-CHALLENGE 1
- Version 3
- July 14, 2016

ANONYMIZATION
-------------

The networks are provided in anonymized form for the Challenge, i.e., gene names have been
replaced by randomly assigned numbers (these are NOT Entrez IDs). The original networks will
be shared after the Challenge closes.

This is the version of the networks for Sub-challenge 1, i.e., each network was anonymized
individually. The networks are NOT aligned: node k of network 1 is not the same gene as node
k of network 2.

See the Challenge website for details.

NETWORKS
--------

1_ppi_anonym_v2.txt
2_ppi_anonym_v2.txt
3_signal_anonym_directed_v3.txt  <-- This network is directed!
4_coexpr_anonym_v2.txt
5_cancer_anonym_v2.txt
6_homology_anonym_v2.txt

All networks are WEIGHTED and UNDIRECTED, except for the signaling network, which is DIRECTED.
For further information, see the Challenge website.

FILE FORMAT
-----------

The networks are provided as tab-separated text files. Each line defines an edge. The first
two columns correspond to the two nodes that are linked by the edge. For directed networks,
the first column is the source node and the second column the target node. The third column
gives the edge weight. The edge weight is a score greater than zero that indicates the
confidence or strenght of the interaction. See the Challenge website for details. 


--
Daniel Marbach, Sarvenaz Choobdar, Sven Bergmann
July 14, 2016
