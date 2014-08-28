# -*- coding: utf-8 -*-
import sys;
import os;
import time;
import re;
import tempfile;
import urllib;
# import urllib.request;
import rfc3987;

dir = tempfile.gettempdir() + "/lview";
# os.makedirs(dir, exist_ok=True);
if (not os.path.exists(dir)):
  os.makedirs(dir);

for arg in sys.argv[1:]:
  if (rfc3987.match(arg, "URI")):
    h = rfc3987.parse(arg, "URI");
    filename = os.path.basename(h["path"]);
    ext = os.path.splitext(filename)[1];

    if (ext.lower() in ( ".bmp", ".jpg", ".jpeg", ".png", ".gif" )):
      response = urllib.urlopen(arg);
      # response = urllib.request.urlopen(arg);
      filename = str(int(time.time())) + "_" + os.path.basename(h["path"]);
      fpw = open(dir + "/" + filename, "wb");
      fpw.write(response.read());
      fpw.close();
