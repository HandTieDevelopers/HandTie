import processing.video.*;
import gifAnimation.*;

public class CameraManager {

  final String[] cameraNames = new String[]{"FaceTime HD Camera"};
  final int[] frameRates = new int[]{30,15,1};
  final String defaultImgFormat = ".png";

//-- parameters

  private final int cameraIndex = 0;
  private final int resWidth = 1280;
  private final int resHeight = 720; 
  private final int frameRateIndex = 0;
  private final int scaleDownFactor = 2;
	
//--

  PApplet app;
	Capture cam = null;
	int mResHeight = 0;
	int mResWidth = 0;
  boolean camIsReady = false;
  String currentSketchPath = null;
  String imageDirName = "TakenPhotos";
  String imagesDirPath;
  Gif processingGif;
  final int timerInterval = 1000;
  final int startingTimerTime = 5;
  int currentTimerTime = startingTimerTime;
  Timer countDownTimer;
  Capture camForShowingOnUI = null;
  String cameraNameBeChosen;
  String textToShowOnUI = "camera isn't ready";
  boolean showCameraVideo = true;
  boolean showCameraStateText = true;
  boolean isCountingDown = false;
  boolean isPlayingCaptureEffect = false;
  boolean endPlayingCaptureEffect = false;
  float currentAlphaVal = 0;
  float currentTargetVal = 0;
  Timer anotherTimer;

	//use camera index to choose camera in cameraNames
	public CameraManager(PApplet parent) { 
    app = parent;
		currentSketchPath = parent.sketchPath("");
    countDownTimer = new Timer(timerInterval);
    anotherTimer = new Timer(3000);

    // processingGif = new Gif(this, currentSketchPath + "ProcessAnimationSmall.gif");
    // processingGif.loop();

		imagesDirPath =  currentSketchPath + "/" + imageDirName + "/";
		mResWidth = resWidth;
		mResHeight = resHeight;
		final PApplet parentToUse = parent;
		/*
    cameraNameBeChosen = cameraNames[cameraIndex];
    println("you choose:" + cameraNameBeChosen);
		*/
    println(Capture.list());

    int temp = frameRates[0];
    if(frameRateIndex < frameRates.length && frameRateIndex >= 0) {
			temp = frameRates[frameRateIndex];
		}
		else {
			println("illegal frame rate index has been given, use default frame rate : " + temp);
		}
		final int frameRateToUse = temp;
    frameRate(frameRateToUse);

		(new Thread(new Runnable() {
			public void run() {

				try {
					File dir = new File(imagesDirPath);
					if(!dir.exists()) {
						if(!dir.mkdirs()) {
							println("making dir " + imageDirName + " failed");
							return;
						}
					}
				}
				catch(Exception e) {

				}

        camIsReady = false;
				String[] availableCameraNames = Capture.list();
				boolean camExisted = false;
        /*
				println("available cameras:");
				for(String camName : availableCameraNames) {
					if(camName.contains(cameraNameBeChosen)) {
						camExisted = true;
            cameraNameBeChosen = camName;
            break;
					}
				}
        */
        camExisted = true;
				if(!camExisted) {
					println("chosen camera doesn't available right now");
					return;
				}

				try {
					cam = new Capture(parentToUse, mResWidth, mResHeight, frameRateToUse);
					cam.start();

					camForShowingOnUI = new Capture(parentToUse, mResWidth/scaleDownFactor, mResHeight/scaleDownFactor, frameRateToUse);
		      camForShowingOnUI.start();
				}
				catch(Exception e) {

				}

        updateUIText("camera init done");
			}
		})).start();

	}
    
	public void setIndividualImageDirPath(String userDirName) {
		imagesDirPath = currentSketchPath + "/" + imageDirName + "/" + userDirName + "/";
		try {
			File dir = new File(imagesDirPath);
			if(!dir.exists()) {
				dir.mkdirs();
			}
			dir = null;
		}
		catch(Exception e) {
			println(e.getLocalizedMessage());
		}
	}

  String imgFileNameForSaving = null;
  void saveImageFromCamera() {
    try {
      ((PImage)cam).save(imagesDirPath + imgFileNameForSaving + defaultImgFormat);  
    }
    catch(Exception e) {
      println(e.getLocalizedMessage());
    } 
    imgFileNameForSaving = null;
  }

	public void captureImage(String imgFileName) {
		if(cam == null) {
	    	println("camera hasn't been correctly initialized");
        return;
		}
    imgFileNameForSaving = imgFileName;
    thread("saveImageFromCamera");
    startCaptureImageEffect(255);
	}

	public void updateUIText(String text) {
		textToShowOnUI = text;
	}

  private int xCor = 0;
  private int yCor = 0;
  private final int mvStep = 10;
  
	public void performKeyPress(char k) {
		switch(k) {
			case '/':
				showCameraVideo = !showCameraVideo;
				break;
			case '.':
				showCameraStateText = !showCameraStateText;
				break;
      case ']':
        if(xCor + mvStep > app.height) {
          xCor = app.height;
        }
        else {
          xCor += mvStep;  
        }
        break;
      case '[':
        if(xCor - mvStep >= 0) {
          xCor -= mvStep;
        } 
        else {
          xCor = 0;
        }
        break;
      case '=':
        if(yCor + mvStep > app.width) {
          yCor = app.width;
        }
        else {
          yCor += mvStep; 
        }
        break;
      case '-':
        if(yCor - mvStep >= 0) {
          yCor -= mvStep;
        }
        else {
          yCor = 0;
        }
        break;
      case 'p':
        println("x:" + xCor + ",y:" + yCor);
        break;
      case '`':
        println("take photo now");
        startCountDown();
        break;

		}
	}

  private void startCaptureImageEffect(float targetVal) {
    isPlayingCaptureEffect = true;
    camForShowingOnUI.stop();
    currentTargetVal = targetVal;
    anotherTimer.start();
  }

  private void startCountDown() {
    isCountingDown = true;
   
    //reset count down UI
    currentTimerTime = startingTimerTime;
    countDownTimer.start();
  }

  private final float easing = 2f;
  private float simpleEase(float targetVal, float currentVal) {
    float diffVal = targetVal - currentVal;
    if(abs(diffVal) > 1) {
      return (currentVal + diffVal * easing);
    }
    else {
      return targetVal;
    }
  }

	public void draw() {
		if(showCameraStateText) {
			textSize(32);
			text(textToShowOnUI, 10, 60);
			fill(0, 102, 153, 51);
		}

		if(showCameraVideo) {
      if(isPlayingCaptureEffect) {
        tint(255, simpleEase(currentTargetVal, currentAlphaVal));
        if(anotherTimer.isFinished()) {
          if(endPlayingCaptureEffect) {
            endPlayingCaptureEffect = false;
            isPlayingCaptureEffect = false;
            camForShowingOnUI.start();
          }
          startCaptureImageEffect(0);
          endPlayingCaptureEffect = true;
        }
      }

      if(camForShowingOnUI != null) {
				image(cam, 200, 200);
			}
		}

    if(isCountingDown) {

      textSize(32);
      text(String.valueOf(currentTimerTime), 10, 60);
      fill(0, 102, 153, 51);
      
      if(countDownTimer.isFinished()) {
        currentTimerTime--;
        countDownTimer.start();
      }

      if(currentTimerTime == 0) {
        isCountingDown = false;
        captureImage("testImage");
      }
    }

	}

}


