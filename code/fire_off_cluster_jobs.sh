#!/bin/bash

LIBRARY=$1

FRACTIONS=(1_0 0_8 0_6 0_4 0_2)
REPS=(01 02 03 04 05 06 07 08 09 10)

for F in ${FRACTIONS[@]}
do

for R in ${REPS[@]}
do
cat head8.batch > $LIBRARY.$F.$R.qsub
echo "make data/$LIBRARY/$LIBRARY.$F.$R.accuracy.list;
make data/$LIBRARY/$LIBRARY.$F.$R.an.list;
make data/$LIBRARY/$LIBRARY.$F.$R.f1score.list;
make data/$LIBRARY/$LIBRARY.$F.$R.fn.list;
make data/$LIBRARY/$LIBRARY.$F.$R.mcc.list;
make data/$LIBRARY/$LIBRARY.$F.$R.nn.list;
make data/$LIBRARY/$LIBRARY.$F.$R.swarm.list;
make data/$LIBRARY/$LIBRARY.$F.$R.vagc_1.list;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_1.list;
make data/$LIBRARY/$LIBRARY.$F.$R.vagc_8.list;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_8.list;
make data/$LIBRARY/$LIBRARY.$F.$R.uagc.list;
make data/$LIBRARY/$LIBRARY.$F.$R.udgc.list;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_split5_1.list;
make data/$LIBRARY/$LIBRARY.$F.$R.vdgc_split5_8.list;
make data/$LIBRARY/$LIBRARY.$F.$R.an_split5_1.list;
make data/$LIBRARY/$LIBRARY.$F.$R.an_split5_8.list;
make data/$LIBRARY/$LIBRARY.$F.$R.mcc_split5_1.list;
make data/$LIBRARY/$LIBRARY.$F.$R.mcc_split5_8.list;
make data/$LIBRARY/$LIBRARY.$F.$R.otuclust.list;
make data/$LIBRARY/$LIBRARY.$F.$R.sumaclust.list;" >> $LIBRARY.$F.$R.qsub

cat tail.batch >> $LIBRARY.$F.$R.qsub
qsub $LIBRARY.$F.$R.qsub
rm $LIBRARY.$F.$R.qsub
done

done

