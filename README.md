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

Extracting replication timing features by `callBinRT.py`: \
`python callBinRT.py --bedpefile --RTfile --outpath --outfile` \
Traning model by Random Forest method by `trainbyRF_5fold.R` (5-fold validation) and `trainbyRF_100times.R` (multiple traning validation). \
Model predition by `predictByModel.R`. 

Here we have K562 as an example to use these scripts. \
`python callBinRT.py Hi-C_data/K562_pairs_1-20_test.bedpe RTdata/RT_K562_BoneMarrowLymphoblast_Int37482971_hg19.bedgraph output\ K562_pairs_1-20.bedpe.binsRTfea_test.csv ` 

`Rscript trainbyRF_5fold.R output\ K562_pairs_1-20.bedpe.binsRTfea_test.csv `

`Rscript trainbyRF_100times.R output\ K562_pairs_1-20.bedpe.binsRTfea_test.csv `



