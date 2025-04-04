package com.google.protobuf {
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class Message {
    public static function toByteArray(message:Message):ByteArray {
        var bytes:ByteArray = new ByteArray();
        message.writeTo(new CodedOutputStream(bytes));
        return bytes;
    }

    public function Message() {
    }

    public function writeTo(output:CodedOutputStream):void {
    }

    public function readFrom(input:CodedInputStream):void {
    }
}
}
