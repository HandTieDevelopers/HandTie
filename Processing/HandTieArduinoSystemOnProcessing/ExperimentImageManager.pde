import processing.video.*;


public class ExperimentImageManager{
	
	final String[] cameraNames = new String[]{"IPEVO Point 2 View","FaceTime HD Camera"};
	final int[] frameRates = new int[]{30,15,1};
	final String defaultImgFormat = ".png";

	Capture cam = null;
	int mResHeight = 0;
	int mResWidth = 0;
    boolean camIsReady = false;
    String currentSketchPath = null;
    String imageDirName = "ExperimentImages";
    String imagesDirPath;

    Capture camForShowingOnUI = null;

	//use camera index to choose camera in cameraNames
	public ExperimentImageManager(PApplet parent, int cameraIndex, int resWidth, int resHeight, int frameRateIndex) { 
		currentSketchPath = parent.sketchPath("");
		imagesDirPath =  currentSketchPath + "/" + imageDirName + "/";
		mResWidth = resWidth;
		mResHeight = resHeight;
		final PApplet parentToUse = parent;
		final String cameraNameBeChosen = cameraNames[cameraIndex];
		int temp = frameRates[0];
		if(frameRateIndex < frameRates.length && frameRateIndex >= 0) {
			temp = frameRates[frameRateIndex];
		}
		else {
			println("illegal frame rate index has been given, use default frame rate : " + temp);
		}
		final int frameRateToUse = temp;

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
		        String[] availableCameraConfig = Capture.list();
				boolean camExisted = false;
				println("available cameras:");
				for(String camConfig : availableCameraConfig) {
					println(camConfig);
					if(!camExisted && camConfig.contains(cameraNameBeChosen)) {
						camExisted = true;
					}
				}

				if(!camExisted) {
					println("chosen camera doesn't available right now");
					return;
				}

				
				
				try {
					cam = new Capture(parentToUse, mResWidth, mResHeight, cameraNameBeChosen, frameRateToUse);
					cam.start();

					camForShowingOnUI = new Capture(parentToUse, 480, 360, cameraNameBeChosen, frameRateToUse);
		            camForShowingOnUI.start();
				}
				catch(Exception e) {

				}

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

	public void captureImage(String imgFileName) {
		if(cam == null) {
	    	println("camera hasn't been correctly initialized");
		}

        try {
        	((PImage)cam).save(imagesDirPath + imgFileName + defaultImgFormat);  
        }
        catch(Exception e) {
        	println(e.getLocalizedMessage());
        }
	}

	public void updateUIText(String text) {
		textToShowOnUI = text;
	}

	String textToShowOnUI = "camera not ready";
	boolean showCameraStateText = true;
	boolean showCameraVideo = false;
	
	public void performKeyPress(char k) {
		switch(k) {
			case '1':
				showCameraVideo = true;
				break;
			case '2':
				showCameraVideo = false;
				showCameraStateText = false;
				break;
			case '/':
				showCameraVideo = !showCameraVideo;
				break;
			// case '.': //for testing
			// 	captureImage("QAQ_Test"); 
			// 	break;
			case ',':
				showCameraStateText = !showCameraStateText;
				break;

		}
	}

	public void draw() {
		if(showCameraStateText) {
			textSize(32);
			text(textToShowOnUI, 10, 60);
			fill(0, 102, 153, 51);
		}

		if(showCameraVideo) {
			if(camForShowingOnUI != null) {
				image(camForShowingOnUI, 0, 0);
			}
		}
	}

}


