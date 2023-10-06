#!/bin/bash

usage(){
  echo "Usage: unpack [-r] [-v] file [file...]"
}


mx="-maxdepth"
num="1"
count=0
decompress(){

  local location="$1"
  local maxdepth=$2
  local depthnum=$3
  fileList=$(find $location $maxdepth $depthnum 2> /dev/null)
  for file in ${fileList[@]};do
    type=$(file -b "$file" | awk '{print $1}')
    if [[ $type =~ "bzip2" ]];then
      bunzip2 -f $file
      ((count++))
    elif [[ $type =~ "compress" ]];then
      mv "$file" "$file.gz"
      gunzip -f "$file.gz"
      ((count++))
    elif [[ $type =~ "gzip" ]];then
      gunzip -f "$file"
      ((count++))
    elif [[ $type =~ "Zip" ]];then
      unzip -o "$file"
    else
      if [[ $verbose == 'true' ]];then
        echo "Ignoring $file"
        fi
    fi
  done

}

while getopts ":vrh" arg;do
  case $arg in
  r)
    recursive="true" ;;
  v)
    verbose="true";;
  h|*)
    usage
    exit 1;;
  esac
  done

shift $((OPTIND-1))

ls="$@"
if [[ $recursive == "true" ]];then
  for i in ${ls[@]};do
    decompress $i
    done
  echo "Decompressed $count Archive(s)"
else
  for i in ${ls[@]};do
    decompress $i $mx $num
  done
  echo "Decompressed $count Archive(s)"
fi
