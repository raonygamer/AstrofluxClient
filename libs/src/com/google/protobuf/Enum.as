package com.google.protobuf {
public class Enum {
    public function Enum(name:String, value:int) {
        _name = name;
        _value = value;
    }

    private var _value:int;

    public function get value():int {
        return _value;
    }

    private var _name:String;

    public function get name():String {
        return _name;
    }

    public function toString():String {
        return "(name=" + _name + ", value=" + value + ")";
    }
}
}
