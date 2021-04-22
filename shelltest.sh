#!/bin/bash
NOW=$(DATE)
echo "$NOW : 반영시작시간"

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
			echo "File존재 백업진행 : $List"
			backupvalue="$List"'_'`date +%Y%m%d`
			mv "$List" "$backupvalue"

			if [ -e "/$backupvalue" ]; then
				echo "백업완료"
			else
				echo "백업실패"
			fi

			cnt=$((cnt+1))
			# 해당파일 반영을 진행한다.
                	cp "$valueparam" "$List" 
			
			if [ -e "/$List" ]; then
                                echo "반영완료: $valueparam"
                        else
                                echo "반영실패 : $valueparam"
                        fi

			> ./test.log
		else
			echo "기존File이존재하지않음 : $List"
		fi 
	fi
	done < 위치.txt

NOW=$(DATE)
echo "$NOW : 반영종료시간 & 반영완료 파일 $cnt"
