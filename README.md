# RepliChrom

RepliChrom is a computational method to predict enhancer-promoter interactions based on replication timing features. Model prediction results of six cell types demonstrate that replication timing signals effectively predict enhancer-promoter interactions. As a proof-of-principle, we applied RepliChrom to identify interactions from various chromatin conformation capture technologies, such as Hi-C, Hi-TrAC, ChIA-PET, and 5C. Moreover, we leveraged RepliChrom to screen significant chromatin interactions in acute lymphoblastic leukemia samples, differentiating them precisely from normal samples. This work uncovers that replication timing signals shape the three-dimensional structure of fine-grained regulatory interactions.

![image](workflow.png)

**Systems Requirements**

The scripts were written in R and Python language.

To run the scripts, you need several R and Python packages. To install the packages:
`install.packages(c("pROC","ranger","ROCR"))` \
`conda install pandas, numpy` \
`conda install bedtools`



**Script usage**

