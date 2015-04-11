#!/bin/bash

#-- config --

#usingTool='linear'
usingTool='nonLinear'

foldNum="10"
liblinearPath='/Users/lab430/Documents/SVM/liblinear-1.96'
libSVMPath='/Users/lab430/Documents/SVM/libsvm-3.20'
numsForIter=" 0 1 2 3 4 5 6 7 8 9 10 "

#--

if [ $# == 0 ]; then
  echo "usage:$0 inputDataFolderPath [outputResultFolderPath]"
  exit
fi

inputDataFolderPath=$1
outputResultFolderPath=$2

# if [ "$emptyResultFolder" ==  true ]; then
#   rm -d $outputResultFolderPath
# fi

if [ $usingTool == 'linear' ]; then
  train=$liblinearPath'/train'
  predict=$liblinearPath'/predict'
else
  train=$libSVMPath'/svm-train'
  predict=$libSVMPath'/svm-predict'
fi


#-- train and then test
cd $inputDataFolderPath
#echo $allTestingData
#trainingOpts=''
#testingOpts=''
#accuracyFile=`date +"%Y-%m-%d_%k-%M-%S"`'.accuracy'

for num in $numsForIter; do
  accuracyFile='User'"$num"'_10fold.accuracy'
  allRowsComb=`ls . | grep 'User'"$num"'_.*training.*.txt' | cut -d'_' -f4 | awk '!a[$0]++'` #awk is to remove duplication
  echo $allRowsComb >>"$accuracyFile"
  for rowNum in $allRowsComb; do 
    allTrainingData=`ls . | grep 'User'"$num"'_.*training.*'"$rowNum"'_.*.txt'` #select a user and a row
    allTestingData=`ls . | grep 'User'"$num"'_.*testing.*'"$rowNum"'_.*.txt'` 
    accuracySum='0'
    for trainingFile in $allTrainingData; do
      modelFile=${trainingFile%%.*}'.model'
      $train -q $trainingFile $modelFile
      fileID=${trainingFile%%_*} #use this fileID to find its complementary testing file
      #echo $fileID
      for testingFile in $allTestingData; do
        if [[ $testingFile =~ ^"$fileID"_.* ]]; then #matching the first one
          pureTestFileName=${testingFile%%.*}
          resultFile=$pureTestFileName'.result'
          #echo $resultFile >>"$accuracyFile"
          #$predict $testingFile $modelFile $resultFile >>"$accuracyFile" 2>&1
          #rowNums=`echo $resultFile | cut -d'_' -f4`
          #$predict $testingFile $modelFile $resultFile | awk -v var="$rowNums" '{print var','$3}' >>"$accuracyFile"
          oneResult=`$predict $testingFile $modelFile $resultFile | awk '{print $3}'`
          accuracySum=`bc <<< 'scale=2;'${oneResult//%}'+'$accuracySum`
          break
        fi
      done
    done
    avgAccuracy=`bc <<< 'scale=2;'$accuracySum'/'$foldNum`
    echo $avgAccuracy >>"$accuracyFile"
  done
done

if [ -d $outputResultFolderPath ] && [ "$outputResultFolderPath" != "$inputDataFolderPath" ]; then 
  mv *.accuracy *.result *.model $outputResultFolderPath
fi
