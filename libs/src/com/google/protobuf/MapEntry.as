package com.google.protobuf {
public class MapEntry {
    public function MapEntry(key:*, value:*) {
        _key = key;
        _value = value;
    }

    private var _key:*;

    public function get key():* {
        return _key;
    }

    public function set key(value:*):void {
        _key = value;
    }

    private var _value:*;

    public function get value():* {
        return _value;
    }

    public function set value(value:*):void {
        _value = value;
    }
}
}
