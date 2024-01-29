#!/usr/bin/env bash

url=$1
TOTAL=0
COUNT=100
HIGHEST=false
LOWEST=false
for ((i=1;i<=$COUNT;i++));
do
    TIME=$(curl -o /dev/null -s -w %{time_total}\\n  http://$1)
    TOTAL=$(echo "$TOTAL+$TIME" | bc)
    if [[ "$HIGHEST" = false ]] || [  $(echo "$HIGHEST < $TIME" |bc -l) -gt 0 ];
    then
        HIGHEST=$TIME
    fi
    if [[ "$LOWEST" = false ]] || [ $(echo "$LOWEST > $TIME" |bc -l) -gt 0 ];
    then
        LOWEST=$TIME
    fi
done
AVERAGE=$(echo "scale=4; $TOTAL/$COUNT" | bc)
echo "-----DONE----"
echo "total: $TOTAL"
echo "lowest: $LOWEST"
echo "average: $AVERAGE"
echo "highest: $HIGHEST"

