#!/bin/bash

#-- config --

usingTool='linear'
#usingTool='nonLinear'

liblinearPath='/Users/lab430/Documents/SVM/liblinear-1.96'
libSVMPath='/Users/lab430/Documents/SVM/libsvm-3.20'

#--

if [ $# == 0 ]; then
  echo "usage:$0 inputDataFolderPath [outputResultFolderPath] [-v number]"
  exit
fi

inputDataFolderPath=$1
outputResultFolderPath=$2


if [ $usingTool == 'linear' ]; then
  train=$liblinearPath'/train'
  predict=$liblinearPath'/predict'
else
  train=$libSVMPath'/svm-train'
  predict=$libSVMPath'/svm-predict'
fi


#-- train and then test
cd $inputDataFolderPath
allTrainingData=`ls . | grep -e 'training.*.txt'`
allTestingData=`ls . | grep -e 'testing.*.txt'` 
#echo $allTestingData
#trainingOpts=''
#testingOpts=''

accuracyFile=`date +"%Y-%m-%d_%k-%M-%S"`'.accuracy'

for trainingFile in $allTrainingData; do
  modelFile=${trainingFile%%.*}'.model'
  $train -q $trainingFile $modelFile
  fileID=${trainingFile%%_*} #use this fileID to find its complementary testing file
  #echo $fileID
  for testingFile in $allTestingData; do
    if [[ $testingFile =~ ^"$fileID"_.* ]]; then #matching the first one
      #echo $testingFile
      pureTestFileName=${testingFile%%.*}
      resultFile=$pureTestFileName'.result'
      #echo $resultFile >>"$accuracyFile"
      #$predict $testingFile $modelFile $resultFile >>"$accuracyFile" 2>&1
      #rowNums=`echo $resultFile | cut -d'_' -f4`
      #$predict $testingFile $modelFile $resultFile | awk -v var="$rowNums" '{print var','$3}' >>"$accuracyFile"
      $predict $testingFile $modelFile $resultFile | awk '{print $3}' >>"$accuracyFile"
      break
    fi
  done
done
if [ -d $outputResultFolderPath ] && [ "$outputResultFolderPath" != "$inputDataFolderPath" ]; then 
  mv *.accuracy *.result *.model $outputResultFolderPath
fi

#if [ $3 == '-v' ]; then
#-- do cross validation
#numFold=$4.
#fi



