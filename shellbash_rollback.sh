#!/bin/bash
# Created By hojintop

# 윈도우에서 txt 저장시 개행문자 ^M 이 포함되어 표기 되어 제거하고 작업하도록 한다
tr -d '\015' < depList.txt > depList1.txt
mv depList1.txt ./depList.txt


echo "백업된 파일은 삭제되지않습니다. 현재 반영된 파일 모두 원복(롤백) 하시겠습니까? (Y:Yes , N:No)"
	        read input
		
if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]; then
	NOW=$(DATE)
echo "롤백시작시간 : $NOW"
# 원복된 파일항목을 담을배열
rbFileList=()
# 롤백 실패한 항목을 담을 배열	
rbfailFileList=()
rbcnt=0
rbfailCnt=0

while read List
	do
	if [ -n "$List" ]; then
		# txt 에서 읽어온 라인의 txt를 구분자 '/' 로 잘라 오른쪽 첫번째 단어를 추출한다 (순수 파일명및 확장자)
		valueparam=`echo $List | rev | cut -d'/' -f1 | rev`
	
		# 파일명.확장자 이전(filepath)경로값만 가져와 옳바른 디렉터리인지 확인하기 위해추출
		valuePathParam="${List%%$valueparam}"

		# 기존에 백업된 파일 명 (롤백할 파일)
		backupvalue="$List"'_'`date +%Y%m%d`

		# 현재 읽어올 txt 파일의 위치에 파일 존재유무를 판단
		# $backupvalue 앞에 절대경로(/)를 붙여준이유는 어차피 절대경로를 가지로들어오며 특수문자가 있을수 있어 처리함.
		if [ -e "/$backupvalue" ]; then
			# 있다면 롤백을 진행한다.	
			echo "롤백진행 : $List"
			
			cp "$backupvalue" "$List"

			if [ -e "$List" ]; then
				echo "롤백완료 : $List"

            	#롤백완료항목을 배열에 담는다
            	rbFileList+=("$backupvalue")
            	rbcnt=$((rbcnt+1))
			else
				# 롤백실패(원복한 파일이 존재하지않는) 항목을 배열에 담는다
                rbfailFileList+=("$backupvalue : 롤백실패")
                rbfailCnt=$((rbfailCnt+1))

				echo "롤백실패"
			fi
		fi		
	fi
	done < depList.txt
	
	
	NOW=$(DATE)
	echo "롤백종료시간 : $NOW"
	echo "롤백완료 하였습니다. 롤백파일 : $rbcnt , 롤백실패항목 : $rbfailCnt"
	echo "롤백 성공 항목은 rbFileList.log 파일을 확인하세요"
	echo "롤백 실패 항목이 있다면 rbfailedFileList.log 파일을 확인하세요"
	echo "*** 기존 백업된 파일은 삭제되지않고 해당 path 에 존재 합니다. ***"

	#롤백실패항목log처리
	rbfailFileListSize=${#rbfailFileList[@]}

	if [ 0 -lt $rbfailFileListSize ]; then
		echo "롤백종료시간 : $NOW"
		echo "롤백 실패한 파일 항목"
		for rbfailedFile in "${rbfailFileList[@]}"; do
			echo $rbfailedFile
		done
	fi > rbfailedFileList.log

	#롤백성공항목log처리
	rbFileListSize=${#rbFileList[@]}

	if [ 0 -lt $rbFileListSize ]; then
		echo "롤백종료시간 : $NOW"
		echo "롤백 성공한 파일 항목"
		for rbFile in "${rbFileList[@]}"; do
			echo $rbFile
		done
	fi > rbFileList.log
else
	echo "롤백을 진행하지 않고 종료합니다."
fi


