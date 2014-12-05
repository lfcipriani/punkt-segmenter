#!/usr/local/bin/python

# This is the Python script I used to save JSON data from the NLTK pickle files. 

import json
import pickle

langs = ('czech', 'danish', 'dutch', 'english', 'estonian', 'finnish', 'french', 'german', 'greek', 'italian', 'norwegian', 'polish', 'portuguese', 'slovene', 'spanish', 'swedish', 'turkish')

# Originally used this for a Go project.
for l in langs:
  print l
  src_file = "/nltk_data/tokenizers/punkt/" + l + ".pickle"
  dest_file = "/code/gocode/src/github.com/harrisj/punkt/data/" + l + ".json"
  p = pickle.load(open(src_file,"rb"))

  data = {"sentence_starters": list(p._params.sent_starters), "collocations": list(p._params.collocations), "abbrev_types": list(p._params.abbrev_types), "ortho_context": p._params.ortho_context}

  with open(dest_file, 'w') as fp:
    json.dump(data, fp)
