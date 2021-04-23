#!/bin/bash
# Created By hojintop

NOW=$(DATE)
echo "반영시작시간 : $NOW"
# 신규반영항목을 담을배열
newFileList=()
# 반영실패한 항목을 담을 배열	
failFileList=()

while read List
	do
	if [ -n "$List" ]; then
		# txt 에서 읽어온 라인의 txt를 구분자 '/' 로 잘라 오른쪽 첫번째 단어를 추출한다 (순수 파일명및 확장자)
		valueparam=`echo $List | rev | cut -d'/' -f1 | rev`
	
		# 파일명의 특수문자 여부 처리 '$' || '-' 만 확인 추가검증 필요시 조건 추가할것.	
		# 필요시 주석해제
		#if [[ "$List" =~ '$' ]] || [[ "$List" =~ '-' ]]; then
		#	echo "특수문자확인"
		#else
		#	echo "미확인"
		#fi

		# 현재 읽어올 txt 파일의 위치에 파일 존재유무를 판단
		# $List 앞에 절대경로(/)를 붙여준이유는 어차피 절대경로를 가지로들어오며 특수문자가 있을수 있어 처리함.
		if [ -e "/$List" ]; then
			# 있다면 백업을 진행한다.	
			echo "백업진행 : $List"
			backupvalue="$List"'_'`date +%Y%m%d`
			mv "$List" "$backupvalue"

			if [ -e "/$backupvalue" ]; then
				echo "백업완료 : $backupvalue"
			else
				echo "백업실패"
			fi
			
			# 해당파일 반영을 진행한다.
                	cp "$valueparam" "$List"
			cnt=$((cnt+1)) 
			echo "반영완료 : $valueparam"
		else
			# 기존File이 미존재하는(신규반영파일) 파일항목은 배열에 담는다
			newFileList+=("$List")
		fi		
	fi
	done < 위치.txt
	
	# 아래 부터는 기존 File이 없어 반영하지 않은 파일에 대한 검증부
	newFileListSize=${#newFileList[@]}
	newCnt=0
	failCnt=0
	
	if [ 0 -lt $newFileListSize ]; then
		echo "------------아래항목은 반영될 경로에 파일이 존재 하지않는(신규반영) LIST 로 판단 ------------"
	
		for newFile in "${newFileList[@]}"; do
                	echo $newFile
        	done
		
		echo "신규 파일을 반영 하시겠습니까?"
	        read
	
	        for newFile in "${newFileList[@]}"; do
        	        # 해당파일 반영을 진행한다.
                	newParam=`echo $newFile | rev | cut -d'/' -f1 | rev`
			thisFilePath=`pwd`'/'"$newParam"
			
			if [ -e "/$thisFilePath" ]; then
				cp "$newParam" "$newFile"
				newCnt=$((newCnt+1))
				echo "반영완료 : $newParam"	
			else
				# 반영실패(존재하지않는 파일) 항목을 배열에 담는다
				failFileList+=("$newFile")
				failCnt=$((failCnt+1))
			fi
        	done
	fi
	
NOW=$(DATE)
echo "반영종료시간 : $NOW"
echo "반영완료 하였습니다. 기존파일 : $cnt , 신규파일 : $newCnt , 반영실패항목 : $failCnt"
echo "반영 실패 항목이 있다면 failedFileList.log 파일을 확인하세요"


#반영실패항목log처리
failFileListSize=${#failFileList[@]}

if [ 0 -lt $failFileListSize ]; then
	echo "반영종료시간 : $NOW"
	echo "반영 실패한 파일 항목"
	for failedFile in "${failFileList[@]}"; do
		echo $failedFile
	done
fi > failedFileList.log
