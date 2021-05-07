#!/bin/ksh
# Created By hojintop

# 윈도우에서 txt 저장시 개행문자 ^M 이 포함되어 표기 되어 제거하고 작업하도록 한다
tr -d '\015' < depList.txt > depList.txt
mv depList1.txt ./depList.txt

now=$(date)
echo "롤백시작시간 : $now"
# 원복된 파일항목을 담을배열
set -A rbFileList
# 롤백 실패한 항목을 담을 배열		
set -A rbfailFileList

rbfailCnt=0
rbcnt=0

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
		# $List 앞에 절대경로(/)를 붙여준이유는 어차피 절대경로를 가지로들어오며 특수문자가 있을수 있어 처리함.
		if [ -e "/$backupvalue" ]; then
			# 있다면 롤백을 진행한다.	
			echo "롤백진행 : $List"
			
			mv "$backupvalue" "$List"

			if [ -e "/$List" ]; then
				echo "롤백완료 : $List"
				
				# 해당파일 롤을 진행한다.
	        	cp "$valueparam" "$List"
	        	echo "롤완료 : $valueparam"

	        	#롤백완료항목을 배열에 담는다
	        	rbFileList[cnt]="$backupvalue"
				((rbcnt+=1))
			else
				# 롤백실패(원복한 파일이 존재하지않는) 항목을 배열에 담는다
                rbfailFileList[failCnt]="$List:백업실패"
                ((failCnt+=1))
				echo "롤백실패"
			fi
		fi		
	fi
	done < depList.txt
	

now=$(date)
echo "롤백종료시간 : $now"
echo "롤백완료 하였습니다. 롤완료파일 : $cnt , 롤백실패항목 : $failCnt"
echo "롤백 성공 항목은 rbFileList.log 파일을 확인하세요"
echo "롤백 실패 항목이 있다면 rbfailedFileList.log 파일을 확인하세요"


#롤백실패항목log처리
rbfailFileListSize=${#rbfailFileList[*]}

if [ 0 -lt $rbfailFileListSize ]; then
	echo "롤종료시간 : $now"
	echo "롤 실패한 파일 항목"
	for failedFile in ${rbfailFileList[*]}; do
		echo "$failedFile\n"
	done
fi > failedFileList.log

#롤백성공항목log처리
rbFileListSize=${#succFileList[*]}

if [ 0 -lt $rbFileListSize ]; then
	echo "롤백종료시간 : $now"
	echo "롤백 성공한 파일 항목"
	for rbFile in ${rbFileList[*]}; do
		echo "$rbFile"
	done
fi > succedFileList.log
