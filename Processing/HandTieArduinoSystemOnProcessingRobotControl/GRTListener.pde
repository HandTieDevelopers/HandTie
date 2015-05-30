public interface GRTListener{
   public void registerToGRTNotifier(GRTNotifier notifier);
   public void removeToGRTNotifier(GRTNotifier notifier);

   public void updateGRTResults(int label, float likelihood);
}