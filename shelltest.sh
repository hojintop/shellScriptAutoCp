#!/bin/bash
NOW=$(DATE)
echo "$NOW : 반영시작시간"

while read List
	do
	if [ -n "$List" ]; then 
		cnt=$((cnt+1))
		valueparam=`echo $List | rev | cut -d'/' -f1 | rev`
		echo "$valueparam"
		cp "$valueparam" "$List" > ./test.log
	fi
	done < 위치.txt

NOW=$(DATE)
echo "$NOW : 반영종료시간 & 반영완료 파일 $cnt"
