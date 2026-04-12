strings {
%option merge
    alias ncompare = strncmp
    sub strncmp(str string1, str string2, ubyte length) -> byte {
        ubyte i
        ubyte s1,s2
        if length == 0 return -1
        repeat length {
            s1 = string1[i]
            s2 = string2[i]
            if s1 == 0 and s2 == 0 return 0
            if s1 != s2 {
                if s1 < s2 return -1
                if s1 > s2 return 1
            }
            i++
        }
        ; no mismatches in requested number of characters (length)
        return 0
    }
}
