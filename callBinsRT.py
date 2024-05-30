# -*- coding: utf-8 -*-
# @Author: DFY
# @Date:   2022-06-24 14:43:18
# @Last Modified by: DFY
# @Last Modified time: 2023-10-03 21:30:30
import pandas as pd
import sys,os
import numpy as np

def calRT(overlap, noOverlap, loopBed):
    # overlap and noOverlap both are wrote to dicOver{}
    # df_overlap = pd.read_csv(overlap,sep='\t',header=None)
    # df_nooverlap = pd.read_csv(noOverlap,sep='\t',header=None)
    dicOver={}
    ########overlap
    overlapList = []
    for i in overlap:
    	overlapList.append(i.strip().split('\t'))
    df_overlap = pd.DataFrame(overlapList)

    df_overlap[6] = df_overlap[6].astype('float')
    a = df_overlap.groupby([0,1,2])
    
    for name,group in a:
        dicOver[name] = np.mean(group[6])

    ########no-overlap
    noOverlapList = []
    for i in noOverlap:
        noOverlapList.append(i.strip().split('\t'))
    df_noOverlap = pd.DataFrame(noOverlapList)
    for eachrow in range(df_noOverlap.shape[0]):
        lista = list(df_noOverlap.iloc[eachrow])
        listb = tuple(lista)
        dicOver[listb] = 0

    ########loop
    loopBedL = open(loopBed).readlines()
    loopList = []
    for i in loopBedL:
    	loopList.append(i.strip().split('\t'))
    df_loop = pd.DataFrame(loopList)

    eachFea = []
    for i in range(df_loop.shape[0]):
        lista = list(df_loop.iloc[i])
        listb = tuple(lista)
        eachFea.append(dicOver[listb])
    return eachFea

def add_chr_prefix(value):
    return 'chr' + str(value)



loopbed = sys.argv[1]
RTFile = sys.argv[2]
pathFile = sys.argv[3]
outfile = sys.argv[4]


upLen = 30000
downLen = 30000
Len = upLen+downLen
#loop = pd.read_csv(loopbed,sep='\t',header=None)#'test.bedpe'
loop = pd.read_csv(loopbed,sep='\t')
loop = loop[['label','enhancer_chrom','enhancer_start','enhancer_end','promoter_chrom','promoter_start','promoter_end']]
loop.columns = ['label','chr1','x1','x2','chr2','y1','y2']

# loop['chr1'] = loop['chr1'].apply(add_chr_prefix)
# loop['chr2'] = loop['chr2'].apply(add_chr_prefix)

# loop['chr1'] = loop['chr1'].replace('chr23', 'chrX', regex=True)
# loop['chr2'] = loop['chr2'].replace('chr23', 'chrX', regex=True)

# loop['Lmid'] = loop['x1']+((loop['x2']-loop['x1'])/2).astype('int')
# loop['Rmid'] = loop['y1']+((loop['y2']-loop['y1'])/2).astype('int')

loop['Lmid'] = loop['x1']+((loop['x2']-loop['x1'])/2).astype('int')
loop['Rmid'] = loop['y1']+((loop['y2']-loop['y1'])/2).astype('int')


loop['L_s'] = (loop['Lmid']-upLen).apply(lambda x: max(x, 0))
loop['L_e'] = (loop['Lmid']+downLen).apply(lambda x: max(x, 0))

loop['R_s'] = (loop['Rmid']-upLen).apply(lambda x: max(x, 0))
loop['R_e'] = (loop['Rmid']+downLen).apply(lambda x: max(x, 0))

loopL = loop[['chr1','L_s','L_e']]
loopR = loop[['chr2','R_s','R_e']]

bins = [i for i in range(500,8000,1000)]
result_df = pd.DataFrame()

for win in bins:
    countN = int(Len/win)
    print(f'bin: {win}')
    fea ={}

    for i in range(countN):
        print(i)
        nameL = pathFile+str(i)+'_L.bed'
        #tempL = pd.DataFrame(loopL[1])
        # tempL[2] = loopL[2]+i*win
        # tempL[3] = loopL[2]+(i+1)*win
        tempL = pd.DataFrame(loopL['chr1'])
        tempL['x1'] = loopL['L_s']+i*win
        tempL['x2'] = loopL['L_s']+(i+1)*win

        tempL.to_csv(nameL, sep='\t',header=0,index=0)
        #print(tempL)
        #overlap
        overlapL = os.popen('bedtools intersect -a '+nameL+' -b '+RTFile+' -wa -wb').readlines()
        #on-overlap
        noOverlapL = os.popen('bedtools intersect -a '+nameL+' -b '+RTFile+' -v').readlines()

        keyL = 'L'+str(i)+'_'+str(win)
        fea[keyL] = calRT(overlapL, noOverlapL, nameL)
        os.remove(nameL)

        nameR = pathFile+str(i)+'_R.bed'
        # tempR = pd.DataFrame(loopR[4])
        # tempR[5] = loopR[5]+i*win
        # tempR[6] = loopR[5]+(i+1)*win
        tempR = pd.DataFrame(loopR['chr2'])
        tempR['y1'] = loopR['R_s']+i*win
        tempR['y2'] = loopR['R_s']+(i+1)*win
        tempR.to_csv(nameR, sep='\t',header=0,index=0)
        #print(tempR)
        #overlap
        overlapR = os.popen('bedtools intersect -a '+nameR+' -b '+RTFile+' -wa -wb').readlines()
        #on-overlap
        noOverlapR = os.popen('bedtools intersect -a '+nameR+' -b '+RTFile+' -v').readlines()
        keyR = 'R'+str(i)+'_'+str(win)
        fea[keyR] = calRT(overlapR, noOverlapR, nameR)
        os.remove(nameR)

    FinalFea = pd.DataFrame(fea)
    result_df = pd.concat([result_df, FinalFea], axis=1)

result_df.insert(0,'label',loop['label'])
result_df.to_csv(outfile, sep=',',index=0)

