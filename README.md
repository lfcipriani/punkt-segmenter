# Punkt sentence tokenizer

This code is a ruby 1.9.x port of the Punkt sentence tokenizer algorithm implemented by the NLTK Project ([http://www.nltk.org/]). Punkt is a **language-independent**, unsupervised approach to **sentence boundary detection**. It is based on the assumption that a large number of ambiguities in the determination of sentence boundaries can be eliminated once abbreviations have been identiﬁed.

The full description of the algorithm is presented in the following academic paper:

> Kiss, Tibor and Strunk, Jan (2006): Unsupervised Multilingual Sentence Boundary Detection.  
> Computational Linguistics 32: 485-525.  
> [Download paper]

Here are the credits for the original implementation:

- Willy (willy@csse.unimelb.edu.au) (original Python port)
- Steven Bird (sb@csse.unimelb.edu.au) (additions)
- Edward Loper (edloper@gradient.cis.upenn.edu) (rewrite)
- Joel Nothman (jnothman@student.usyd.edu.au) (almost rewrite)

I simply did the ruby port and some API changes.

## Install

    gem install punkt-segmenter

Currently, this gem only runs on ruby 1.9.x (because of unicode_utils dependency)

## How to use

Let's suppose we have the following text:

*"A minute is a unit of measurement of time or of angle. The minute is a unit of time equal to 1/60th of an hour or 60 seconds by 1. In the UTC time scale, a minute occasionally has 59 or 61 seconds; see leap second. The minute is not an SI unit; however, it is accepted for use with SI units. The symbol for minute or minutes is min. The fact that an hour contains 60 minutes is probably due to influences from the Babylonians, who used a base-60 or sexagesimal counting system. Colloquially, a min. may also refer to an indefinite amount of time substantially longer than the standardized length."* (source: http://en.wikipedia.org/wiki/Minute)

You can separate in sentences using the Punkt::SentenceTokenizer object:

    tokenizer = Punkt::SentenceTokenizer.new(text)
    result    = tokenizer.sentences_from_text(text, :output => :sentences_text)

The result will be:

    result    = [
        [0] "A minute is a unit of measurement of time or of angle.",
        [1] "The minute is a unit of time equal to 1/60th of an hour or 60 seconds by 1.",
        [2] "In the UTC time scale, a minute occasionally has 59 or 61 seconds; see leap second.",
        [3] "The minute is not an SI unit; however, it is accepted for use with SI units.",
        [4] "The symbol for minute or minutes is min.",
        [5] "The fact that an hour contains 60 minutes is probably due to influences from the Babylonians, who used a base-60 or sexagesimal counting system.",
        [6] "Colloquially, a min. may also refer to an indefinite amount of time substantially longer than the standardized length."
    ]

The algorithm uses the text passed as parameter to train and tokenize in sentences. Sometimes the size of the input text is not enough to have a well trained set, which may cause some mistakes on the sentences splitting. For these cases you can train the Punkt segmenter:

    trainer = Punkt::Trainer.new()
    trainer.train(trainning_text)
    
    tokenizer = Punkt::SentenceTokenizer.new(trainer.parameters)
    result    = tokenizer.sentences_from_text(text, :output => :sentences_text)

In this case, instead of passing the text to SentenceTokenizer, you pass the trainer parameters.

A recommended use case for the trainning object is to train a big corpus in a specific language and then marshal the object to a file. Then you can load the already trained tokenizer from a file. You can even add more texts to the trainning set whenever you want.

The available options for *sentences_from_text* method are:

- array of sentences indexes (default)
- array of sentences string  (**:output => :sentences_text**)
- array of sentences tokens  (**:output => :tokenized_sentences**)	
- realigned boundaries (**:realign_boundaries => true**): do this if you want to realign sentences that end with, for example, parenthesis, quotes, brackets, etc
	
If you have a list of tokens, you can use the *sentences_from_tokens* method, which takes only the list of tokens as parameter.

Check the unit tests for more detailed examples in English and Portuguese.

----
*This code follows the terms and conditions of Apache License v2 (http://www.apache.org/licenses/LICENSE-2.0)*

*Copyright (C) Luis Cipriani*
  
  [http://www.nltk.org/]: http://www.nltk.org/
  [Download paper]: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.85.5017&rep=rep1&type=pdf

