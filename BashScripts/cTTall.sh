#!/bin/bash

#-- config --

# usingTool='linear'
usingTool='nonLinear'

liblinearPath='/Users/kevinljw/Documents/SVM/liblinear-1.96'
libSVMPath='/Users/kevinljw/Documents/SVM/libsvm-3.20'
numsForIter=" 0 "

# linearOrRBF="0"
linearOrRBF="2"

# UsingGrid="1"
UsingGrid="0"

#--

if [ $# == 0 ]; then
  echo "usage:$0 inputDataFolderPath [outputResultFolderPath] [-v number]"
  exit
fi

inputDataFolderPath=$1
outputResultFolderPath=$2
outputResultFolderTmpPath=$2'/atmp'
rm -r $outputResultFolderPath
mkdir $outputResultFolderPath
mkdir $outputResultFolderTmpPath
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
  grid=$libSVMPath'/tools/grid.py'
fi


#-- train and then test
cd $inputDataFolderPath
#echo $allTestingData
#trainingOpts=''
#testingOpts=''
#accuracyFile=`date +"%Y-%m-%d_%k-%M-%S"`'.accuracy'


for num in $numsForIter; do
  allTrainingData=`ls . | grep 'User'"$num"'_.*training.*.txt'`
  allTestingData=`ls . | grep 'User'"$num"'_.*testing.*.txt'` 
  accuracyFile='User'"$num"'.accuracy'
  # ls . | grep 'User'"$num"'_.*testing.*.txt' | cut -d'_' -f4 >>"$accuracyFile"
  

  for trainingFile in $allTrainingData; do
    sScaleFile=${trainingFile%%.*}'.scale'
    rangeFile=${trainingFile%%.*}'.rfile'
    $scale -l 0 -u 1 -s $rangeFile $trainingFile > $sScaleFile
    modelFile=${trainingFile%%.*}'.model'

    if [ $UsingGrid == "1" ]; then
      # gridResult=`python $grid -out "null" $sScaleFile`
      gridResult=`python $grid -gnuplot "null" -out "null" $sScaleFile`
      paraC=`echo $gridResult | cut -d' ' -f1`
      paraG=`echo $gridResult | cut -d' ' -f2`
      echo $paraC $paraG
      $train -q -t $linearOrRBF -c $paraC -g $paraG $sScaleFile $modelFile
    else
      $train -q -t $linearOrRBF $sScaleFile $modelFile
    fi
      
    
    fileID=${trainingFile%%_*} #use this fileID to find its complementary testing file
    #echo $fileID
    for testingFile in $allTestingData; do
      if [[ $testingFile =~ ^"$fileID"_.* ]]; then #matching the first one
        pureTestFileName=${testingFile%%.*}
        rScaleFile=${testingFile%%.*}'.scale'
        # rangeFile=${trainingFile%%.*}'.rfile'
        $scale -r $rangeFile $testingFile > $rScaleFile
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

if [ -d $outputResultFolderPath ] && [ "$outputResultFolderPath" != "$inputDataFolderPath" ]; then 
  mv *.result *.model *.scale *.rfile $outputResultFolderTmpPath
  mv *.accuracy $outputResultFolderPath
fi

#-- do cross validation

if [ $3 == '-v' ]; then
  numFold=$4
else
  numFold="10"
fi

  
  for num in $numsForIter; do
    allTrainingData=`ls . | grep 'User'"$num"'_.*training.*.txt'`
    accuracyFCVFile='FCV_User'"$num"'.accuracy'
    # ls . | grep 'User'"$num"'_.*testing.*.txt' | cut -d'_' -f4 >>"$accuracyFCVFile"
    
    for trainingFile in $allTrainingData; do
        cScaleFile=${trainingFile%%.*}'.scale'
        $scale $trainingFile > $cScaleFile

        $train -q -t $linearOrRBF -v $numFold $cScaleFile  | awk '{print $5}' >>"$accuracyFCVFile"
      
    done
  done

if [ -d $outputResultFolderPath ] && [ "$outputResultFolderPath" != "$inputDataFolderPath" ]; then 
  mv *.scale $outputResultFolderTmpPath
  mv *.accuracy $outputResultFolderPath
fi




