public interface GRTNotifier{
   public void registerForGRTListener(GRTListener listener);
   public void removeGRTListener(GRTListener listener);

   public void notifyAllWithGRTResults(int label, float likelihood);
}