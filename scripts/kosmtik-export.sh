#!/bin/bash

MIN_ZOOM=13
MAX_ZOOM=18
X_MIN=-1.80
X_MAX=-1.61
Y_MIN=48.08
Y_MAX=48.16

#THREADS=4 --workers $THREADS : [Default: number of CPUs = os.cpus().length] see https://github.com/kosmtik/kosmtik-tiles-export/blob/master/Export.js
#THREADS=2 29mn THREADS=4 27mn 

start=`date +%s`

cd /openstreetmap-carto/
rm -Rf /openstreetmap-carto/data/export
mkdir -p /openstreetmap-carto/data/export

kosmtik export /openstreetmap-carto/project.mml --format tiles --output /openstreetmap-carto/data/export --minZoom $MIN_ZOOM --maxZoom $MAX_ZOOM -bounds=$X_MIN,$Y_MIN,$X_MAX,$Y_MAX

end=`date +%s`

echo "-----------------------------------------"
diri="/openstreetmap-carto/data/export/"
echo "Statistics"
echo " "
echo Output dir : $diri
echo Execution time : $(( ($end - $start) / 60 )) minutes.
echo " "
echo -e "Zoom\tFiles\tMo"
cd $diri
dirs=`ls -d * | grep -v .log 2>/dev/null`
dirsP=$dirs" ."
for diri in $dirsP; do
  filecount=`find $diri -type f | wc -l`
  sizeB=`du -b -s $diri | awk -F" " '{ print $1 / 1024 / 1024 }'`
  echo -e "$diri \t$filecount\t$sizeB"
done
echo " "
