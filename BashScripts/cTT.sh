#!/bin/bash

#-- config --

# usingTool='linear'
usingTool='nonLinear'

liblinearPath='/Users/kevinljw/Documents/SVM/liblinear-1.96'
libSVMPath='/Users/kevinljw/Documents/SVM/libsvm-3.20'
numsForIter=" 0 1 2 3 4 5 6 7 8 9 "

linearOrRBF="0"
# linearOrRBF = "2"

#--

if [ $# == 0 ]; then
  echo "usage:$0 inputDataFolderPath [outputResultFolderPath] [-v number]"
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
  scale=$liblinearPath'/scale'
else
  train=$libSVMPath'/svm-train'
  predict=$libSVMPath'/svm-predict'
  scale=$libSVMPath'/svm-scale'
fi


#-- train and then test
cd $inputDataFolderPath
#echo $allTestingData
#trainingOpts=''
#testingOpts=''
#accuracyFile=`date +"%Y-%m-%d_%k-%M-%S"`'.accuracy'


for num in $numsForIter; do
  allTrainingData=`ls . | grep 'User'"$num"'.*training.*.txt'`
  allTestingData=`ls . | grep 'User'"$num"'.*testing.*.txt'` 
  accuracyFile='User'"$num"'.accuracy'
  ls . | grep 'User'"$num"'.*testing.*.txt' | cut -d'_' -f4 >>"$accuracyFile"

  for trainingFile in $allTrainingData; do
    sScaleFile=${trainingFile%%.*}'.scale'
    $scale -s scale $trainingFile > $sScaleFile
    modelFile=${trainingFile%%.*}'.model'
    $train -q -t $linearOrRBF $sScaleFile $modelFile
    fileID=${trainingFile%%_*} #use this fileID to find its complementary testing file
    #echo $fileID
    for testingFile in $allTestingData; do
      if [[ $testingFile =~ ^"$fileID"_.* ]]; then #matching the first one
        pureTestFileName=${testingFile%%.*}
        rScaleFile=${trainingFile%%.*}'.scale'
        $scale -r scale $testingFile > $rScaleFile
        resultFile=$pureTestFileName'.result'
        #echo $resultFile >>"$accuracyFile"
        #$predict $testingFile $modelFile $resultFile >>"$accuracyFile" 2>&1
        #rowNums=`echo $resultFile | cut -d'_' -f4`
        #$predict $testingFile $modelFile $resultFile | awk -v var="$rowNums" '{print var','$3}' >>"$accuracyFile"
        $predict $rScaleFile $modelFile $resultFile | awk '{print $3}' >>"$accuracyFile"
        break
      fi
    done
  done
done


#-- do cross validation

if [ $3 == '-v' ]; then
  numFold=$4
else
  numFold="10"
fi

  
  for num in $numsForIter; do
    allTrainingData=`ls . | grep 'User'"$num"'.*training.*.txt'`
    accuracyFCVFile='FCV_User'"$num"'.accuracy'

    for trainingFile in $allTrainingData; do
        sScaleFile=${trainingFile%%.*}'.scale'
        $scale -s scale $trainingFile > $sScaleFile
        $train -q -t $linearOrRBF -v $numFold $sScaleFile  | awk '{print $5}' >>"$accuracyFCVFile"
      
    done
  done

if [ -d $outputResultFolderPath ] && [ "$outputResultFolderPath" != "$inputDataFolderPath" ]; then 
  mv *.accuracy *.result *.model *.scale $outputResultFolderPath
fi




