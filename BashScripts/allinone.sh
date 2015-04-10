#!/bin/bash

#-- config --

numsForIter=" 0 1 2 4 5 6 7 8 9 10 "
rowNumsForIter=" 0 1 2 3 4 5 6 7 01 12 23 34 45 56 67 "
#--

if [ $# == 0 ]; then
  echo "usage:$0 inputDataFolderPath [outputResultFolderPath] [-v number]"
  exit
fi

inputDataFolderPath=$1
outputResultFolderPath=$2

#-- train and then test
cd $inputDataFolderPath
#echo $allTestingData
#trainingOpts=''
#testingOpts=''
#accuracyFile=`date +"%Y-%m-%d_%k-%M-%S"`'.accuracy'
for rowNum in $rowNumsForIter; do
    allTrainingData=`ls . | grep 'User.*_training_rows'"$rowNum"'_.*.txt'`
    # echo $allTrainingData | cut -d' ' -f1
    trainingFile=`echo $allTrainingData | cut -d' ' -f1`
    resultFile=${trainingFile%%.*}'.txt'
    echo $resultFile
    fileID=${resultFile%%_*}
    echo $fileID
    # cat $allTrainingData > $outputResultFolderPath"/$resultFile"

    allTestingData=`ls . | grep 'User.*_testing_rows'"$rowNum"'_.*.txt'`
    # echo $allTrainingData | cut -d' ' -f1
    testingFile=`echo $allTestingData | cut -d' ' -f1`
    resultFile=${testingFile%%.*}'.txt'
    # echo $resultFile
    # cat $allTestingData > $outputResultFolderPath"/$resultFile"
done

# if [ -d $outputResultFolderPath ] && [ "$outputResultFolderPath" != "$inputDataFolderPath" ]; then 
#   mv *.abc $outputResultFolderPath
# fi




