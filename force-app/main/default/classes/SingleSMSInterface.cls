global interface SingleSMSInterface{

    boolean sendSMS(String smsBody, list<String> phonesList, String senderName);

}