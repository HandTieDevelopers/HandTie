public enum Gesture{
   NO_GESTURE(0,"Gesture Pending",null,false),

   UP_READY(0,"Up Ready",null,true),
   UP_DONE(0,"Up",UP_READY,false),

   DOWN_READY(0,"Down Ready",null,true),
   DOWN_DONE(0,"Down",DOWN_READY,false),

   LEFT_READY(0,"Left Ready",null,true),
   LEFT_DONE(0,"Left",LEFT_READY,false),

   RIGHT_READY(0,"Right Ready",null,true),
   RIGHT_DONE(0,"Right",RIGHT_READY,false),

   OK(0,"Ok",null,false),

   TAKE_PHOTO(0, "Take Photo",null,false);
   
   private int label;
   private String gestureName;
   private Gesture lastState; //this gesture requires a previous gesture
   private boolean isReady;

   Gesture(final int label, final String gestureName, Gesture lastState, boolean isReady){
      this.label = label;
      this.gestureName = gestureName;
      this.lastState = lastState;
      this.isReady = isReady;
   }

   public int getLabel(){
      return label;
   }

   public String toString() {
      return gestureName;
   }

   public Gesture getLastState(){
      return lastState;
   }

   public boolean isReadyState(){
      return isReady;
   }

   public boolean equals(Gesture g){
      return (label == g.label) && (gestureName == g.gestureName);
   }

   public static Gesture getGestureByLabel(int label){
      for (Gesture g : Gesture.values()) {
         if (g.label == label) {
            return g;
         }
      }
      return null;
   }

   public static Gesture getGestureByGestureName(String gestureName) {
      for (Gesture g : Gesture.values()) {
         if (g.gestureName == gestureName) {
            return g;
         }
      }
      return null;
   }
}