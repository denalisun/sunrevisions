init_sunmod_vars() {
    level.sunmod_vars = [];

    // 0 = Easy
    // 1 = Normal
    // 2 = Hard
    // 3 = Rampage
    // 4 = Apocalypse
    level.sunmod_vars["difficulty"] = 1;
}

convert_to_roman(value) {
    result = "";

    while (value >= 1000) { result += "M"; value -= 1000; }
    while (value >= 900)  { result += "CM"; value -= 900; }
    while (value >= 500)  { result += "D"; value -= 500; }
    while (value >= 400)  { result += "CD"; value -= 400; }
    while (value >= 100)  { result += "C"; value -= 100; }
    while (value >= 90)   { result += "XC"; value -= 90; }
    while (value >= 50)   { result += "L"; value -= 50; }
    while (value >= 40)   { result += "XL"; value -= 40; }
    while (value >= 10)   { result += "X"; value -= 10; }
    while (value >= 9)    { result += "IX"; value -= 9; }
    while (value >= 5)    { result += "V"; value -= 5; }
    while (value >= 4)    { result += "IV"; value -= 4; }
    while (value >= 1)    { result += "I"; value -= 1; }

    return result;
}