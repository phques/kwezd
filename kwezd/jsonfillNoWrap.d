// Copyright 2012 Philippe Quesnel
// Licensed under the Academic Free License version 3.0

// direct use of JSONValue
// this version would need manual checks on type of json value
// (w. ugly debug writeln()s ;-p)
void Fill(Class)(ref Class obj, JSONValue json) {

    debug writeln("fill: ", [__traits(derivedMembers, Class)]);
    debug writeln("with: ", to!string(json.object));

    // for each member of the class
    foreach (m; __traits(derivedMembers, Class)) {

        debug writeln(typeof(__traits(getMember, obj, m)).stringof, " ", m);

        // do we have a member with same name in json objet ?
        // if so, assign according to type of class member
        //## need check of jsonvalue type !!
        if (m in json.object) {
            static if (is(typeof(__traits(getMember, obj, m)) == string)) {
                debug writeln("  assigning str to ", m);
                __traits(getMember, obj, m) = json.object[m].str;
            }
            else static if (is(typeof(__traits(getMember, obj, m)) == int)) {
                debug writeln("  assigning int to ", m);
                __traits(getMember, obj, m) = cast(int)json.object[m].integer;
            }
            else static if (is(typeof(__traits(getMember, obj, m)) == long)) {
                debug writeln("  assigning int to ", m);
                __traits(getMember, obj, m) = json.object[m].integer;
            }
            else static if (is(typeof(__traits(getMember, obj, m)) == bool)) {
                debug writeln("  assigning bool to ", m);
                __traits(getMember, obj, m) = json.object[m].type == JSON_TYPE.TRUE;
            }
            else static if (is(typeof(__traits(getMember, obj, m)) == class)) {
                debug writeln("  recursing on object");
                Fill(__traits(getMember, obj, m), json.object[m]);
            }
            else {
                debug writeln("  unsupported type ");
            }
        }
        else {
            // nb: outputs for every method/CTOR etc...!
            debug writeln("  warning: no corresponding JSON member '", m, "'");
        }
    }
}

