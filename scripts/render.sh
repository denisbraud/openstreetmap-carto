#!/bin/bash

MIN_ZOOM=13
MAX_ZOOM=18
X_MIN=-1.80
X_MAX=-1.61
Y_MIN=48.08
Y_MAX=48.16
THREADS=4

start=`date +%s`

cd /openstreetmap-carto/
rm -Rf /var/lib/mod_tile/ajt
rm -Rf /openstreetmap-carto/data/render
mkdir -p /openstreetmap-carto/data/render

carto project.mml > mapnik.xml
echo "-----------------------------------------"
echo "Starting renderd\n"
/usr/local/bin/renderd --config /usr/local/etc/renderd.conf --foreground yes &
sleep 10
scripts/render_list_geo.pl -m ajt -n $THREADS -f -z $MIN_ZOOM -Z $MAX_ZOOM -x $X_MIN -X $X_MAX -y $Y_MIN -Y $Y_MAX > /openstreetmap-carto/data/render/render_list_geo.log
echo "-----------------------------------------"
echo "Rendering finished\n"
cat /openstreetmap-carto/data/render/render_list_geo.log | grep -e "Zoom ..:"
echo " "
dirToExplore="/var/lib/mod_tile/ajt"
du -h --max-depth=1 $dirToExplore
echo " "
for diri in `ls -d $dirToExplore/*/`; do
  filecount=`find $diri -type f | wc -l`
  echo -e "$filecount files\t$diri"
done
echo "-----------------------------------------"
echo "Creating png tiles from .meta files using meta2tile\n"
mkdir -p data/render
meta2tile /var/lib/mod_tile/ajt /openstreetmap-carto/data/render
echo " "

end=`date +%s`

echo "-----------------------------------------"
diri="/openstreetmap-carto/data/render/"
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
