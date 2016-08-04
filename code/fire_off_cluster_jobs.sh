#!/bin/bash

LIBRARY=$1
TYPE=$2

FRACTIONS=(1_0 0_8 0_6 0_4 0_2)
REPS=(01 02 03 04 05 06 07 08 09 10)

for F in ${FRACTIONS[@]}
do

for R in ${REPS[@]}
do
cat head8.batch > $LIBRARY.$F.$R.qsub
echo "make data/$LIBRARY/$LIBRARY.$F.$R.accuracy.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.an.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.f1score.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.fn.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.mcc.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.nn.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.swarm.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.vagc_1.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_1.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.vagc_8.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_8.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.uagc.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.udgc.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_split5_1.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_split5_8.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.an_split5_1.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.an_split5_8.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.mcc_split5_1.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.mcc_split5_8.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.otuclust.$TYPE;
make data/$LIBRARY/$LIBRARY.$F.$R.sumaclust.$TYPE;" >> $LIBRARY.$F.$R.qsub

cat tail.batch >> $LIBRARY.$F.$R.qsub
qsub $LIBRARY.$F.$R.qsub
rm $LIBRARY.$F.$R.qsub
done

done
