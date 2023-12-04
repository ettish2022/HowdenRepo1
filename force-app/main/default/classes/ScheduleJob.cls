public with sharing class ScheduleJob{
    public String jobName{get;set;} 
    public String cronExp{get;set;} 
    public String className{get;set;}
    public PageReference doScheduleJob() {
        Type t = Type.forName(className);
        System.schedule(jobName, cronExp, (Schedulable)t.newInstance());
        return null;
    }
    
    public PageReference dummy() {
        return null;
    }

}