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
			if(!camExisted && camConfig.contains(cameraNames[cameraIndex])) {
				camExisted = true;
			}
		}

		if(!camExisted) {
			println("chosen camera doesn't available right now");
			return;
		}

		mResWidth = resWidth;
		mResHeight = resHeight;

		int frameRateToUse = frameRates[0];
		if(frameRateIndex < frameRates.length && frameRateIndex >= 0) {
			frameRateToUse = frameRates[frameRateIndex];
		}
		else {
			println("illegal frame rate index has been given, use default frame rate : " + frameRateToUse);
		}
		
		try {
			cam = new Capture(parent, resWidth, resHeight, cameraNames[cameraIndex], frameRateToUse);
			cam.start();

			camForShowingOnUI = new Capture(parent, 480, 360, cameraNames[cameraIndex], frameRateToUse);
            camForShowingOnUI.start();
		}
		catch(Exception e) {

		}

	}
    
	public void setIndividualImageDirPath(String userDirName) {
		imagesDirPath = currentSketchPath + "/" + imageDirName + "/" + userDirName + "/";
		try {
			(new File(imagesDirPath)).mkdirs();
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

	String textToShowOnUI = "";
	boolean showCameraVideo = false;
	
	public void performKeyPress(char k) {
		switch(k) {
			case '/':
				showCameraVideo = !showCameraVideo;
				break;
			case '.': //for testing
				captureImage("QAQ_Test"); 
				break;
		}
	}

	public void draw() {
		textSize(32);
		text(textToShowOnUI, 10, 60);
		fill(0, 102, 153, 51);
		if(showCameraVideo) {
			if(camForShowingOnUI != null) {
				image(camForShowingOnUI, 0, 0);
			}
		}
	}

}


