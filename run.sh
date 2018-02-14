#!/bin/bash

# run.sh

baseHomedir=~/topkSubgraphWork/
cd ${baseHomeDir}
mkdir data
mkdir -p data/synthetic/results/
cd data/synthetic/
wget http://www.cse.psu.edu/~madduri/software/GTgraph/GTgraph.tar.gz
tar -zxvf GTgraph.tar.gz
cd GTgraph
Change CC=gcc in Makefile.var
make
mv R-MAT/GTgraph-rmat ../
cd ..
rm -rf GTgraph.tar.gz GTgraph

./GTgraph-rmat -n 1000 -m 12000 -o ./sample_1000_10000.txt
mv log sample_1000_10000.log
java -cp ${baseHomeDir}/bin -Xmx20g dataGen/GTGraphToOurFormatConverter ${baseHomeDir}/data/synthetic/ sample_1000_10000.txt GT_1000_10000.txt types_1000_10000.txt

./GTgraph-rmat -n 10000 -m 100000 -o ./sample_10000_100000.txt
mv log sample_10000_100000.log
java -cp ${baseHomeDir}/bin -Xmx20g dataGen/GTGraphToOurFormatConverter ${baseHomeDir}/data/synthetic/ sample_10000_100000.txt GT_10000_100000.txt types_10000_100000.txt

./GTgraph-rmat -n 100000 -m 1000000 -o ./sample_100000_1000000.txt
mv log sample_100000_1000000.log
java -cp ${baseHomeDir}/bin -Xmx20g dataGen/GTGraphToOurFormatConverter ${baseHomeDir}/data/synthetic/ sample_100000_1000000.txt GT_100000_1000000.txt types_100000_1000000.txt

./GTgraph-rmat -n 1000000 -m 10000000 -o ./sample_1000000_10000000.txt
mv log sample_1000000_10000000.log
java -cp ${baseHomeDir}/bin -Xmx20g dataGen/GTGraphToOurFormatConverter ${baseHomeDir}/data/synthetic/ sample_1000000_10000000.txt GT_1000000_10000000.txt types_1000000_10000000.txt

Create edge lists
for i in 1000_10000 10000_100000 100000_1000000 1000000_10000000
do
date +%s;
time java -cp ${baseHomeDir}/bin -Xmx5g IndexConstruction/SortedEdgeListsConstructor ${baseHomeDir}/data/synthetic/ GT_${i}.txt types_${i}.txt
date +%s;
cat GT_${i}_*list > tmp.txt
ls -ltr tmp.txt
rm -rf tmp.txt
done

Create topology and SPD indexes.

for d in 3 2
do
for graph in 1000_10000 10000_100000 100000_1000000 1000000_10000000
do
(time java -cp ${baseHomeDir}/bin -Xmx5g IndexConstruction/SPDAndTopologyAndSPathIndexConstructor2  ${baseHomeDir}/data/synthetic/ GT_${graph}.txt types_${graph}.txt ${d}) 1>SPDAndTopologyAndSPathIndexConstructor2.${graph}.${d}.out 2>SPDAndTopologyAndSPathIndexConstructor2.${graph}.${d}.err
done
done

Wikipedia
=========

java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetInfoboxes 1>GetInfoboxes.txt 2>GetInfoboxes.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/ComputeEntityDictAndInfoboxText 1>ComputeEntityDictAndInfoboxText.txt 2>ComputeEntityDictAndInfoboxText.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GenerateSets 1>GenerateSets.txt 2>GenerateSets.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GenerateNetwork 1>GenerateNetwork.txt 2>GenerateNetwork.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/Create10EntityTypeNetwork 1>Create10EntityTypeNetwork.txt 2>Create10EntityTypeNetwork.err

java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetFilmObjects >sandBox/film.txt 2>sandBox/film.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetPersonObjects >sandBox/person.txt 2>sandBox/person.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetAlbumObjects >sandBox/album.txt 2>sandBox/album.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetCompanyObjects >sandBox/company.txt 2>sandBox/company.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetFootballBiographyObjects >sandBox/footballBiography.txt 2>sandBox/footballBiography.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetNRHPObjects >sandBox/nrhp.txt 2>sandBox/nrhp.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetTelevisionObjects >sandBox/television.txt 2>sandBox/television.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetSingleObjects >sandBox/single.txt 2>sandBox/single.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetSettlementObjects >sandBox/settlement.txt 2>sandBox/settlement.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetMusicalArtistObjects >sandBox/musicalArtist.txt 2>sandBox/musicalArtist.err
java -Xmx10g -cp ~/jars/*:. dataGen/wikipedia/GetClusterDistributions ${baseHomeDir}/wikipedia/ 1>GetClusterDistributions.txt 2>GetClusterDistributions.err
java -Xmx10g dataGen/wikipedia/WikipediaGraphGen

Note: We used metis-4.0 for our work.
To run the baseline graph generator 
We need to change the io.c file. Change MAXLINE to MAXLINE*10. Otherwise, fgets buffer size gets smaller than the maximum
size of our file and results into bad parsing by metis.

java -Xmx10g -cp ${baseHomeDir}/bin IndexConstruction/SortedEdgeListsConstructor ${baseHomeDir}/data/wikipedia/ graph.txt nodeTypes.txt
(time java -Xmx10g -cp ${baseHomeDir}/bin IndexConstruction/SPDAndTopologyAndSPathIndexConstructor2  ${baseHomeDir}/data/wikipedia/ graph.txt nodeTypes.txt 2) 1>SPDAndTopologyAndSPathIndexConstructor2a.wikipedia.out 2>SPDAndTopologyAndSPathIndexConstructor2a.wikipedia.err


DBLP
=======================
java -Xmx20g -cp ~/jars/*:. dataGen/DBLP/PreProcessDBLP
Make appropriate settings in Global.java for DBLP dataset.
java -Xmx20g -cp ~/jars/*:. dataGen/DBLP/netclus/NetClus 1

GenerateDBLPNetwork
java -cp ~/jars/*:. dataGen/DBLP/netclus/Star2GeneralGraph ${baseHomeDir}/data/DBLP/

java -Xmx10g -cp ${baseHomeDir}/bin IndexConstruction/SortedEdgeListsConstructor ${baseHomeDir}/data/DBLP/ graph.txt types.txt
(time java -Xmx10g -cp ${baseHomeDir}/bin IndexConstruction/SPDAndTopologyAndSPathIndexConstructor2  ${baseHomeDir}/data/DBLP/ graph.txt types.txt 2) 1>SPDAndTopologyAndSPathIndexConstructor2a.DBLP.out 2>SPDAndTopologyAndSPathIndexConstructor2a.DBLP.err

======================================================================================================

Create Random queries of different kinds
========================================
mkdir ${baseHomeDir}/data/synthetic/queries/
for i in `seq 2 5`;
do
for j in `seq 1 200`;
do
for type in Path Clique Subgraph
do
echo "Generating query for ID: ${j} and #Nodes: ${i} and Type: ${type}";
java -Xmx10g -cp ${baseHomeDir}/bin QueryExecution/Random${type}QueryGenerator ${baseHomeDir}/data/synthetic/queries/ dummy ../types_1000_10000.txt ${i}
mv ${baseHomeDir}/data/synthetic/queries/queryGraph.txt ${baseHomeDir}/data/synthetic/queries/queryGraph.${type}.${j}.${i}.txt  
mv ${baseHomeDir}/data/synthetic/queries/queryTypes.txt ${baseHomeDir}/data/synthetic/queries/queryTypes.${type}.${j}.${i}.txt
done
done 
done
=========================================
Check number of matches for each query and find 10 queries of each type with greater than 1000 matches.

rm -rf  ${baseHomeDir}/data/synthetic/queries/queryGraphs.txt ${baseHomeDir}/data/synthetic/queries/queryTypes.txt
for j in `seq 1 100`;
do
for i in `seq 2 5`;
do
for type in Path Clique Subgraph
do
echo "queries/queryGraph.${type}.${j}.${i}.txt" >> ${baseHomeDir}/data/synthetic/queries/queryGraphs.txt
echo "queries/queryTypes.${type}.${j}.${i}.txt" >> ${baseHomeDir}/data/synthetic/queries/queryTypes.txt
done
done 
done

java -Xmx10g -cp ~/jars/*:bin QueryExecution/QBSQueryExecutorV2MultipleQueries ${baseHomeDir}/data/synthetic/ GT_10000_100000.txt types_10000_100000.txt 2 queries/queryGraphs.txt queries/queryTypes.txt GT_10000_100000.spath 1000 GT_10000_100000.topology GT_10000_100000.spd 

Select best 10 queries of each type and each size.

cd ${baseHomeDir}/data/synthetic/results
rm -rf selectedQueryGraphs.txt
for s in `seq 2 5`;
do
for type in Path Subgraph Clique
do
for i in `ls|grep "10000_100000"`; do wc -l $i;done|grep ${type}|grep ".${s}.txt"|sort -n -r -k 1|head -10|cut -d"_" -f4|sed 's/^/queries\//g' >> selectedQueryGraphs.txt
done
done
sed 's/Graph/Types/g' selectedQueryGraphs.txt > selectedQueryTypes.txt

=====
Process each query using SPath, QBS, QBSv2, QBSwithTopK1Off, QBSwithTopK2Off for 10 times on 10000/100000 graph
===============================================================================================================

cd ${baseHomeDir}/
date
for repeat in `seq 1 10`;
do
dir="${baseHomeDir}/data/synthetic/";
mkdir -p ${dir}/results/comparison/${repeat}
java -Xmx10g -cp ~/jars/*:bin QueryExecution/QBSQueryExecutorV2MultipleQueries ${dir} GT_10000_100000.txt types_10000_100000.txt 2 results/selectedQueryGraphs.txt results/selectedQueryTypes.txt GT_10000_100000.spath 10 GT_10000_100000.topology GT_10000_100000.spd results/comparison/${repeat}
java -Xmx10g -cp ~/jars/*:bin QueryExecution/RankingAfterMatching ${dir} GT_10000_100000.txt types_10000_100000.txt 2 results/selectedQueryGraphs.txt results/selectedQueryTypes.txt GT_10000_100000.spath 10 results/comparison/${repeat}
for t in 0 1 2;
do
java -Xmx10g -cp ~/jars/*:bin QueryExecution/QBSQueryExecutorMultipleQueries ${dir} GT_10000_100000.txt types_10000_100000.txt 2 results/selectedQueryGraphs.txt results/selectedQueryTypes.txt GT_10000_100000.spath 10 GT_10000_100000.topology ${t} results/comparison/${repeat} 
done
done
date

java -Xmx1g -cp ~/jars/*:. QueryExecution/ComputeTimesforDifferentAlgosForDiffQueryTypes
java -Xmx1g -cp ~/jars/*:. QueryExecution/ComputeTimesforDifferentAlgosForDiffQueryTypes2

==========================================================================

Process all 20 path queries of sizes 2 to 5 using QBSv2 on 1000/10000 graph, 10000/100000 graph, 100000/1000000 graph, 1000000/10000000 graph
=============================================================================================================
mkdir ${baseHomeDir}/data/synthetic/results/scalability

cd ${baseHomeDir}/data/synthetic/results
rm -rf selectedQueryGraphs.txt
for s in `seq 2 5`;
do
for type in Path Subgraph
do
for i in `ls|grep "10000_100000"`; do wc -l $i;done|grep ${type}|grep ".${s}.txt"|sort -n -r -k 1|head -10|cut -d"_" -f4|sed 's/^/queries\//g' >> selectedQueryGraphs.txt
done
done
sed 's/Graph/Types/g' selectedQueryGraphs.txt > selectedQueryTypes.txt

cd ${baseHomeDir}/
for repeat in `seq 1 10`;
do
for graph in 1000_10000 10000_100000 100000_1000000 1000000_10000000
do
dir="${baseHomeDir}/data/synthetic/";
mkdir -p ${dir}/results/scalability/${repeat}
java -Xmx10g -cp ~/jars/*:bin QueryExecution/QBSQueryExecutorV2MultipleQueries ${dir} GT_${graph}.txt types_${graph}.txt 2 results/selectedQueryGraphs.txt results/selectedQueryTypes.txt GT_${graph}.spath 10 GT_${graph}.topology GT_${graph}.spd results/scalability/${repeat}
done
done

Script to compute Candidate Filtering time+actual topK execution time for all graphs:
cd ${baseHomeDir}/data/synthetic/results/scalability/
for g in 1000_10000 10000_100000 100000_1000000 1000000_10000000
do
for size in 2 3 4 5
do
val1=`grep Candidate */*.*${g}_*.*.*.${size}.txt|cut -d" " -f4|awk 'BEGIN{a=0;} {a=a+$1} END{print a;}'`;
val2=`grep Candidate */*.*${g}_*.*.*.${size}.txt|wc -l`;
val=`echo ${val1}/${val2}|bc -l`;
echo -n "${val} ";
val1=`grep Overall */*.*${g}_*.*.*.${size}.txt|cut -d" " -f3|awk 'BEGIN{a=0;} {a=a+$1} END{print a;}'`;
val2=`grep Overall */*.*${g}_*.*.*.${size}.txt|wc -l`;
val=`echo ${val1}/${val2}|bc -l`;
echo -n "${val} ";
done
echo "";
done

==========
For G2 topK experiments (Vary topK)

mkdir ${baseHomeDir}/data/synthetic/results/topk

cd ${baseHomeDir}/data/synthetic/results
rm -rf selectedQueryGraphs.txt
for s in `seq 2 5`;
do
for type in Path Subgraph
do
for i in `ls|grep "10000_100000"`; do wc -l $i;done|grep ${type}|grep ".${s}.txt"|sort -n -r -k 1|head -10|cut -d"_" -f4|sed 's/^/queries\//g' >> selectedQueryGraphs.txt
done
done
sed 's/Graph/Types/g' selectedQueryGraphs.txt > selectedQueryTypes.txt

cd ${baseHomeDir}/
for repeat in `seq 1 10`;
do
for topk in 10 20 50 100
do
dir="${baseHomeDir}/data/synthetic/";
mkdir -p ${dir}/results/topk/${repeat}
java -Xmx10g -cp ~/jars/*:bin QueryExecution/QBSQueryExecutorV2MultipleQueries ${dir} GT_10000_100000.txt types_10000_100000.txt 2 results/selectedQueryGraphs.txt results/selectedQueryTypes.txt GT_10000_100000.spath ${topk} GT_10000_100000.topology GT_10000_100000.spd results/topk/${repeat}
done
done

cd ${baseHomeDir}/data/synthetic/results/topk/
for k in 10 20 50 100
do
for size in 2 3 4 5
do
val1=`grep Overall */QBSQueryExecutorV2.topK=${k}_*.${size}.txt|cut -d" " -f3|awk 'BEGIN{a=0;} {a=a+$1} END{print a;}'`;
val2=`grep Overall */QBSQueryExecutorV2.topK=${k}_*.${size}.txt|wc -l`;
val=`echo ${val1}/${val2}|bc -l`;
echo -n "${val} ";
done
echo "";
done

========================================
#Candidates and #Matches expt.
mkdir ${baseHomeDir}/data/synthetic/results/stats/
cd ${baseHomeDir}/data/synthetic/results
rm -rf selectedQueryGraphs.txt
for s in `seq 2 5`;
do
for type in Path Subgraph
do
for i in `ls|grep "10000_100000"`; do wc -l $i;done|grep ${type}|grep ".${s}.txt"|sort -n -r -k 1|head -10|cut -d"_" -f4|sed 's/^/queries\//g' >> selectedQueryGraphs.txt
done
done
sed 's/Graph/Types/g' selectedQueryGraphs.txt > selectedQueryTypes.txt

cd ${baseHomeDir}/
dir="${baseHomeDir}/data/synthetic/";
java -Xmx10g -cp ~/jars/*:bin QueryExecution/QBSQueryExecutorV2Stats2 ${dir} GT_10000_100000.txt types_10000_100000.txt 2 results/selectedQueryGraphs.txt results/selectedQueryTypes.txt GT_10000_100000.spath 10 GT_10000_100000.topology GT_10000_100000.spd results/stats/

while read line
do
query=`echo $line|cut -d"/" -f2`;
matches=`wc -l ${baseHomeDir}/data/synthetic/results/comparison/1/matches.topK=10_K0=2_GT_10000_100000_${query}|awk '{print $1}'`;
echo ${matches} >>${dir}/results/stats/QBSQueryExecutorV2.topK=10_K0=2_GT_10000_100000_${query}
done<${baseHomeDir}/data/synthetic/results/selectedQueryGraphs.txt

====
cd ${baseHomeDir}/data/synthetic/results/stats
#Find average number of matches.
for i in `ls|grep ".*.5.txt"`; do tail -1 $i;done|awk  'BEGIN{a=0;b=0;} {a=a+$1;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.4.txt"`; do tail -1 $i;done|awk  'BEGIN{a=0;b=0;} {a=a+$1;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.3.txt"`; do tail -1 $i;done|awk  'BEGIN{a=0;b=0;} {a=a+$1;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.2.txt"`; do tail -1 $i;done|awk  'BEGIN{a=0;b=0;} {a=a+$1;b=b+1;} END{print a/b;}'

#No of candidates of a particular size for query size=5 nodes.
for i in `ls|grep ".*.5.txt"`; do sed 's/\t/#/g' $i|grep "^1#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.5.txt"`; do sed 's/\t/#/g' $i|grep "^2#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.5.txt"`; do sed 's/\t/#/g' $i|grep "^3#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.5.txt"`; do sed 's/\t/#/g' $i|grep "^4#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.5.txt"`; do sed 's/\t/#/g' $i|grep "^5#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.5.txt"`; do sed 's/\t/#/g' $i|grep "^6#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'

#No of candidates of a particular size for query size=4 nodes.
for i in `ls|grep ".*.4.txt"`; do sed 's/\t/#/g' $i|grep "^1#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.4.txt"`; do sed 's/\t/#/g' $i|grep "^2#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.4.txt"`; do sed 's/\t/#/g' $i|grep "^3#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.4.txt"`; do sed 's/\t/#/g' $i|grep "^4#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.4.txt"`; do sed 's/\t/#/g' $i|grep "^5#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.4.txt"`; do sed 's/\t/#/g' $i|grep "^6#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'

#No of candidates of a particular size for query size=3 nodes.
for i in `ls|grep ".*.3.txt"`; do sed 's/\t/#/g' $i|grep "^1#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.3.txt"`; do sed 's/\t/#/g' $i|grep "^2#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.3.txt"`; do sed 's/\t/#/g' $i|grep "^3#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.3.txt"`; do sed 's/\t/#/g' $i|grep "^4#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.3.txt"`; do sed 's/\t/#/g' $i|grep "^5#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.3.txt"`; do sed 's/\t/#/g' $i|grep "^6#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'

#No of candidates of a particular size for query size=2 nodes.
for i in `ls|grep ".*.2.txt"`; do sed 's/\t/#/g' $i|grep "^1#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.2.txt"`; do sed 's/\t/#/g' $i|grep "^2#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.2.txt"`; do sed 's/\t/#/g' $i|grep "^3#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.2.txt"`; do sed 's/\t/#/g' $i|grep "^4#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.2.txt"`; do sed 's/\t/#/g' $i|grep "^5#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'
for i in `ls|grep ".*.2.txt"`; do sed 's/\t/#/g' $i|grep "^6#" ;done|awk -F"#" 'BEGIN{a=0;b=0;} {a=a+$2;b=b+1;} END{print a/b;}'

=======
DBLP Query Execution

dir="${baseHomeDir}/data/DBLP/";
time java -Xmx10g -cp ~/jars/*:. QueryExecution/QBSQueryExecutorV2 ${dir} graph.txt types.txt 2 queryGraph1.txt queryTypes1.txt dummy.spath 10 graph.topology graph.spd  1>${dir}/QBSQueryExecutorV2Query1.txt

time java -Xmx10g -cp ~/jars/*:. QueryExecution/QBSQueryExecutorV2 ${dir} graph.txt types.txt 2 queryGraph2.txt queryTypes2.txt dummy.spath 10 graph.topology graph.spd  1>${dir}/QBSQueryExecutorV2Query2.txt

gupta58@dmserv3:${baseHomeDir}/data/DBLP$ cat query*
#DBLP CaseStudy 1
#Nodes: 3
#Edges: 3
#Undirected graph (each pair of nodes is saved twice) -- contains no self loops. #edges is #directed edges
1#2#1.0
1#3#1.0
2#1#1.0
3#1#1.0
2#3#1.0
3#2#1.0
#DBLP CaseStudy 2
#Nodes: 4
#Edges: 3
#Undirected graph (each pair of nodes is saved twice) -- contains no self loops. #edges is #directed edges
1#2#1.0
2#1#1.0
2#3#1.0
3#2#1.0
2#4#1.0
4#2#1.0
1       1
2       2
3       1
1       1
2       2
3       1
4       3



Wikipedia Query Execution

dir="${baseHomeDir}/data/wikipedia/";
time java -Xmx10g -cp ~/jars/*:. QueryExecution/QBSQueryExecutorV2 ${dir} graph.txt nodeTypes.txt 2 queryGraph3.txt queryTypes3.txt dummy.spath 10 graph.topology graph.spd  1>${dir}/QBSQueryExecutorV2Query3.txt

time java -Xmx10g -cp ~/jars/*:. QueryExecution/QBSQueryExecutorV2 ${dir} graph.txt nodeTypes.txt 2 queryGraph4.txt queryTypes4.txt dummy.spath 10 graph.topology graph.spd  1>${dir}/QBSQueryExecutorV2Query4.txt

gupta58@dmserv3:${baseHomeDir}/data/wikipedia$ cat query*
#Wikipedia CaseStudy 1
#Nodes: 3
#Edges: 2
#Undirected graph (each pair of nodes is saved twice) -- contains no self loops. #edges is #directed edges
1#2#1.0
1#3#1.0
2#1#1.0
3#1#1.0
#Wikipedia CaseStudy 2
#Nodes: 4
#Edges: 3
#Undirected graph (each pair of nodes is saved twice) -- contains no self loops. #edges is #directed edges
1#2#1.0
2#1#1.0
2#3#1.0
3#2#1.0
2#4#1.0
4#2#1.0
1       7
2       3
3       7
1       7
2       1
3       7
4       8
