#!/bin/bash

#-- config --

numsForIter=" 0 1 2 4 5 6 7 8 9 10 "
rowsForIter=" 0 1 2 3 4 5 6 7 01 12 23 34 45 56 67 "
#--

if [ $# == 0 ]; then
  echo "usage:$0 inputDataFolderPath [outputResultFolderPath] [-v number]"
  exit
fi

inputDataFolderPath=$1
outputResultFolderPath=$2

#-- train and then test
cd $inputDataFolderPath


for rowNum in $rowsForIter; do
  for num in $numsForIter; do
    TestingData=`ls . | grep 'User'"$num"'_training_rows'"$rowNum"'_.*.txt'`
    cat $TestingData > $outputResultFolderPath"/${TestingData%%_*}"'_User'"$num"'_testing_rows'"$rowNum"'_trials0123456789.txt'
    # outputTrainingIter=" "
    TrainingData=''
    for outputTrainingNum in $numsForIter; do
      if [ "$outputTrainingNum" != "$num" ]; then
        singleTrainingData=`ls . | grep 'User'"$outputTrainingNum"'_training_rows'"$rowNum"'_.*.txt'`
        TrainingData=$TrainingData" $singleTrainingData"
      fi
    done
    # echo $TrainingData

    cat $TrainingData > $outputResultFolderPath"/${TestingData%%_*}"'_User'"$num"'_training_rows'"$rowNum"'_trials0123456789.txt'
    # echo $outputTrainingIter
    # TrainingData=`ls . | grep 'User'"$num"'_training_rows'"$rowNum"'_.*.txt'`
    
    # echo $TrainingData
  done
done