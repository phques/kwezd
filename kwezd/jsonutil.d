// jsonutil.d - utilities for using JSON in D
// Copyright 2012 Philippe Quesnel
// Licensed under the Academic Free License version 3.0
module kwezd.jsonutil;

import std.stdio;
import std.exception;

version(MinGW)
    import json; // need to use local modified json.d  w. mingw64 gdc 4.6.1 !
else
    import std.json;


// Wrap JSONValue
class JsonWrap {
    JSONValue json;
    string name;

    this(string jsonString, string name) { this.name = name; this.json = parseJSON(jsonString); }
    this(JSONValue json, string name) { this.name = name; this.json = json; }

    // shortcut objWrap.memberX = objWrap.json.object["memberX"]
    JsonWrap opDispatch(string part)() {
        return opIndex(part);
    }

    // objWrap["memberX"] = objWrap.memberX = objWrap.json.object["memberX"]
    JsonWrap opIndex(string part) {
        string fullname = name ~ '.' ~ part;
        enforce(json.type == JSON_TYPE.OBJECT, "Expecting JSON.OBJECT, to access " ~ fullname);
        enforce(part in json.object, "Missing json member: " ~ fullname);

        auto v = json.object[part];
        return new JsonWrap(v, fullname);
    }

    string str() {
        enforce(json.type == JSON_TYPE.STRING, "Expecting JSON.STRING, for " ~ name);
        return json.str;
    }
    long integer() {
        enforce(json.type == JSON_TYPE.INTEGER, "Expecting JSON.INTEGER, for " ~ name);
        return json.integer;
    }
    bool boolean() {
        switch (json.type) {
            case JSON_TYPE.TRUE: return true;
            case JSON_TYPE.FALSE: return false;
            default: break;
        }
        enforce(false, "Expecting JSON.TRUE/FALSE, for " ~ name);
        return false; // keep compiler from complaining ;-)
    }

    JSONValue[string] object() {
        enforce(json.type == JSON_TYPE.OBJECT, "Expecting JSON.OBJECT, for " ~ name);
        return json.object;
    }

    //--------

    void Populate(Class)(ref Class obj) {

        this.object(); // enforce(type=object) !

        // for each member of the class
        foreach (m; __traits(derivedMembers, Class)) {

            // do we have a member with same name in json objet ?
            // if so, assign according to type of class member
            if (m in json.object) {
                static if (is(typeof(__traits(getMember, obj, m)) == string)) {
                    __traits(getMember, obj, m) = this[m].str;
                }
                else static if (is(typeof(__traits(getMember, obj, m)) == int)) {
                    __traits(getMember, obj, m) = cast(int)this[m].integer;
                }
                else static if (is(typeof(__traits(getMember, obj, m)) == long)) {
                    __traits(getMember, obj, m) = this[m].integer;
                }
                else static if (is(typeof(__traits(getMember, obj, m)) == bool)) {
                    __traits(getMember, obj, m) = this[m].boolean;
                }
                else static if (is(typeof(__traits(getMember, obj, m)) == class)) {
                    this[m].Populate(__traits(getMember, obj, m));  // object, recurse
                }
                else {
                    assert(false, "Unsupported type " ~ typeof(__traits(getMember, obj, m)).stringof);
                }
            }
        }
    }

}

