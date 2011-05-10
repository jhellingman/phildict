% dollars.pat --- add tagging based on dollar signs.

@patterns 0

"$"         1 "<span style='background-color:yellow'>"
"$$"        2 "<span style='background-color:green'>"

"[~g]"      p "##g"
"n[~g]"     p "##&ntilde;g"
"ñ[~g]"     p "##&ntilde;g"
"N[~g]"     p "##&Ntilde;g"
"m[~g]a"    p "##mga"
"M[~g]a"    p "##Mga"

"_"         p "##_"
"^"         p "##^"


@patterns 1     % single dollar sign

"$"         0 "</span>"
"\n\n"      0 "##</span>"

% "[~g]"    p "&gtilde;"

"[~g]"      p "##g"
"n[~g]"     p "&ntilde;g"
"ñ[~g]"     p "&ntilde;g"
"N[~g]"     p "&Ntilde;g"
"m[~g]a"    p "mga"
"M[~g]a"    p "Mga"

"_a"        p "à"
"_á"        p "â"
"_e"        p "è"
"_é"        p "ê"
"_i"        p "ì"
"_í"        p "î"
"_o"        p "ò"
"_ó"        p "ô"
"_u"        p "ù"
"_ú"        p "û"

"_"         p "##_"

"^"         f


@patterns 2     % double dollar sign

"$"         p "##$"

"$$"        0 "</span>"
"\n\n"      0 "##</span>"


@end
