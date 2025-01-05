extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String convertString() {
    var maxLength = 100;

    var returnString = toLowerCase();
    //Convert Characters
    returnString = returnString.replaceAll("ö", 'o');
    returnString = returnString.replaceAll("ç", 'c');
    returnString = returnString.replaceAll("ş", 's');
    returnString = returnString.replaceAll("ı", 'i');
    returnString = returnString.replaceAll("ğ", 'g');
    returnString = returnString.replaceAll("ü", 'u');

    // if there are other invalid chars, convert them into blank spaces
    returnString = returnString.replaceAllMapped(
        RegExp(r'/[^a-z0-9\s-]/g'), (match) => "");
    // convert multiple spaces and hyphens into one space
    returnString =
        returnString.replaceAllMapped(RegExp(r'/[\s-]+/g'), (match) => " ");
    // trims current string
    returnString =
        returnString.replaceAllMapped(RegExp(r'/^\s+|\s+$/g'), (match) => "");
    // cuts string (if too long)
    if (returnString.length > maxLength) {
      returnString = returnString.substring(0, maxLength);
    }
    // add hyphens
    // returnString = returnString.replace(/\s/g, "-");

    return returnString;
  }

  List<String> createSearchText() {
    var searchTerms = <String>[];

    var nameList = convertString().split(" ");

    for (var text in nameList) {
      if (text.length > 3) {
        for (var i = 3; i <= text.length; i++) {
          var result = text.substring(0, i);

          if (result.isNotEmpty) {
            searchTerms.add(result.toLowerCase());
          }
        }
      } else {
        searchTerms.add(text);
      }
    }
    return searchTerms;
  }
}
