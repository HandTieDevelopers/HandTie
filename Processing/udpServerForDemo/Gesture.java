public enum Gesture{
   NO_GESTURE(0,"Gesture Pending",null),

   UP_READY(0,"Up Ready",null),
   UP_DONE(0,"Up",UP_READY),

   DOWN_READY(0,"Down Ready",null),
   DOWN_DONE(0,"Down",DOWN_READY),

   LEFT_READY(0,"Left Ready",null),
   LEFT_DONE(0,"Left",LEFT_READY),

   RIGHT_READY(0,"Right Ready",null),
   RIGHT_DONE(0,"Right",RIGHT_READY),

   OK(0,"Ok",null),

   TAKE_PHOTO(0, "Take Photo",null);
   
   private int label;
   private String gestureName;
   private Gesture lastState;

   Gesture(final int label, final String gestureName, Gesture lastState){
      this.label = label;
      this.gestureName = gestureName;
      this.lastState = lastState;
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