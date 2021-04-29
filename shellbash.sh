#!/bin/bash
# Created By hojintop

# 윈도우에서 txt 저장시 개행문자 ^M 이 포함되어 표기 되어 제거하고 작업하도록 한다
tr -d '\015' < depList.txt > depList1.txt
mv depList1.txt ./depList.txt


NOW=$(DATE)
echo "반영시작시간 : $NOW"
# 신규반영항목을 담을배열
newFileList=()
# 반영성공한 항목을 담을 배열
succFileList=()
# 반영실패한 항목을 담을 배열	
failFileList=()
cnt=0
failCnt=0

while read List
	do
	if [ -n "$List" ]; then
		# txt 에서 읽어온 라인의 txt를 구분자 '/' 로 잘라 오른쪽 첫번째 단어를 추출한다 (순수 파일명및 확장자)
		valueparam=`echo $List | rev | cut -d'/' -f1 | rev`
	
		# 파일명.확장자 이전(filepath)경로값만 가져와 옳바른 디렉터리인지 확인하기 위해추출
		valuePathParam="${List%%$valueparam}"

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
				
				# 해당파일 반영을 진행한다.
                        	cp "$valueparam" "$List"
                        	echo "반영완료 : $valueparam"

                        	#반영완료항목을 배열에 담는다
                        	succFileList+=("$List")
                        	cnt=$((cnt+1))
			else
				# 반영실패(백업파일이 존재하지않는 - 백업실패) 항목을 배열에 담는다
                                failFileList+=("$newFile : 백업실패")
                                failCnt=$((failCnt+1))

				echo "백업실패"
			fi
		else
			#  반영하고자하는 파일의 경로가 디렉터리(정상경로) 인지 확인하여 정상이라면 신규파일 비정상이라면 경로불분명으로 실패항목에 담는다.
			if [ -d "$valuePathParam" ]; then
				# 기존File이 미존재하는(신규반영파일) 파일항목은 배열에 담는다
                newFileList+=("$List")
                newCnt=$((newCnt+1))
			else
				failFileList+=("$List : 파일경로불분명")
                failCnt=$((failCnt+1))
                echo "옳바르지않은경로확인:$List"
			fi
		fi		
	fi
	done < depList.txt
	
	# 아래 부터는 기존 File이 없어 반영하지 않은 파일에 대한 검증부
	newFileListSize=${#newFileList[@]}
	newCnt=0
	
	if [ 0 -lt $newFileListSize ]; then
		echo "------------아래항목은 반영될 경로에 파일이 존재 하지않는(신규반영) LIST 로 판단 ------------"
	
		for newFile in "${newFileList[@]}"; do
                	echo $newFile
        	done
		
		echo "신규 파일을 반영 하시겠습니까?(Y:Yes , N:No)"
	        read input
		
		if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]; then
			for newFile in "${newFileList[@]}"; do
                    # 해당파일 반영을 진행한다.
                    newParam=`echo $newFile | rev | cut -d'/' -f1 | rev`
                    thisFilePath=`pwd`'/'"$newParam"

                    if [ -e "/$thisFilePath" ]; then
                            cp "$newParam" "$newFile"
                            newCnt=$((newCnt+1))
                            echo "반영완료 : $newParam"
							succFileList+=("$newFile")
							cnt=$((cnt+1))
                    else
                            # 반영실패(미존재 파일) 항목을 배열에 담는다
                            failFileList+=("$newFile : 반영할 파일 미존재")
                            failCnt=$((failCnt+1))
                    fi
            done
		else
			# 반영종료 (적용원하지 않는 신규  파일) 항목을 배열에 담는다
			for newFile in "${newFileList[@]}"; do
					failFileList+=("$newFile : 미반영")
                    failCnt=$((failCnt+1))
            done
		fi
	fi
	
NOW=$(DATE)
echo "반영종료시간 : $NOW"
echo "반영완료 하였습니다. 기존파일 : $cnt , 신규파일 : $newCnt , 반영실패항목 : $failCnt"
echo "반영 성공 항목은 succedFileList.log 파일을 확인하세요"
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

#반영성공항목log처리
succFileListSize=${#succFileList[@]}

if [ 0 -lt $succFileListSize ]; then
	echo "반영종료시간 : $NOW"
	echo "반영 성공한 파일 항목"
	for succFile in "${succFileList[@]}"; do
		echo $succFile
	done
fi > succedFileList.log
