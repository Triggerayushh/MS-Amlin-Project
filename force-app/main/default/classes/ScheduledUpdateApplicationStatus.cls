public class ScheduledUpdateApplicationStatus implements Schedulable {
    public void execute(SchedulableContext SC) {
        // Execute the batch class
        UpdateApplicationStatusBatch batch = new UpdateApplicationStatusBatch();
        Database.executeBatch(batch);
    }
}