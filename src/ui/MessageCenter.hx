package ui;

class MessageCenter {

    public static var x:Int = 0;
    public static var y:Int = 0;

    static var currentMessages:Array<MessageItem> = [];
    static var messageQueue:Array<MessageItem> = [];
    static var currentMessageDisplayRoutine: Future;

    public static function show(message:String) {
            }

    static function slideUp(message:MessageItem): Future {}
    static function messageLifecycle(message:MessageItem): Future {
                                    }
}