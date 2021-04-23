#!/bin/bash
confirm() {
  local message="계속 진행 하시겠습니까?"
  local result=''

  echo "$message (Y:es/N:o/C:ancel) " >&2

  while [ -z "$result" ] ; do
    read -n 1 choice
    case "$choice" in
      y|Y ) result='Y' ;;
      n|N ) result='N' ;;
      c|C ) result='C' ;;
    esac
  done

  echo $result
}


case $(confirm 'Confirm?') in
  Y ) echo "Yes" ;;
  N ) echo "No" ;;
  C ) echo "Cancel" ;;
esac
