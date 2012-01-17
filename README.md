# Parts: a probabilistic part of speech tagger

Parts is a simple to use probabilistic part of speech tagger. At its core, parts is an adapted [Viterbi](http://en.wikipedia.org/wiki/Viterbi_algorithm) [bi-gram](http://en.wikipedia.org/wiki/Bigram) classifier. As such it looks to classify a sentence's parts of speech by identifying the most probable sequence of tags, given the sentence's words. This is done by training the tagger with a pre-tagged corpora. By default the tagger is trained using the [Treebank 3](http://www.ldc.upenn.edu/Catalog/CatalogEntry.jsp?catalogId=LDC99T42) corpora. 

Any questions please do get in contact via [email](mailto:joe@onlysix.co.uk).

## Basics

Parts is packaged as a [gem](https://rubygems.org/pages/download) and thus installed accordingly. 

	gem install parts

With the gem installed, we must first `require` it within any code making use of it.

	require 'parts'

In order to create a tagger with parts, we must first initialise a new `Parts::Tagger`.

	tagger = Parts::Tagger.new

This will create a new tagger, and assuming no arguments are passed in, will train it with the default Treebank 3 corpora. With our tagger now created and trained, we can classify a sentence using the tagger's `classify` method. For example, if we wish to classify the string, `Hello world, this is a sentence`, we would write the following.

	tagger.classify ["Hello", "world", ",", "this", "is", "a", "sentence"]

The tagger requires you to split a sentence up into its appropriate tokens, thus when calling the `classify` method, an array of tokens must be passed in rather than the sentence string itself.

As the tagger is trained by default using the Penn Treebank 3 corpora, sentences are tagged with the [Penn Treebank tags](http://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html). 

## Training parts

Training and evaluating parts with your own corpora is simple. In order to train a tagger with your own corpora, parts requires you to pass in an array of tagged sentences.

	tagger = Parts::Tagger.new sentences

Sentences are stored as array's of word-tag pairs, where each sentence will be [{:word => w1, :tag => t1},...,{:word => wn, :tag => tn}]. For example, were we to train it with one sentence, we might create a `sentences` array as such.

	sentences = [
	  [
	    {:word => "Rolls-Royce"", :tag => "NNP"}
	    {:word => "said", :tag => "VBD"},
	    {:word => "it", :tag => "PRP"},
		{:word => "expects", :tag => "VBZ"},
		{:word => "to", :tag => "TO"},
		{:word => "remain", :tag => "VB"},
		{:word => "steady", :tag => "JJ"}
 	  ]
	]

Parts aims to stay out of your way as much as possible, thus you are free to use whatever tags you want within your corpora. It is worth noting that we automatically prepend and append `$start` and `$end` tags to all sentence arrays when training, thus full-stops need *not* be included in each sentence in the `sentences` array.

## TODO

There is still significant work to be done on parts, in particular looking at:

* integrate the k-fold tester such that it can be used with user built corporas
* noun phrase grouping, e.g. *The British Broadcasting Company*
* exploring mechanisms for automatically splitting sentences into their tokens
* introducing tri-gram tagging as an option
* writing a full featured test suite

## Contributing to parts
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Joe Root. See LICENSE.txt for
further details.

