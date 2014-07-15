library dax_demo_utils;

import 'dart:html';

/**
 * Parse and returns the URL's GET parameters in the form of a key => value Map.
 */
Map<String, String> parseQueryString() {
  Map urlParameters = {};
  String search = window.location.search;
  if (search.startsWith("?")) {
    search = search.substring(1);
  }
  List<String> params = search.split("&");
  for (String param in params) {
    List<String> pair = param.split("=");
    if (pair.length == 1) {
      urlParameters[pair[0]] = "";
    } else {
      urlParameters[pair[0]] = pair[1];
    }
  }

  return urlParameters;
}