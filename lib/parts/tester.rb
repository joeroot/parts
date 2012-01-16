class Parts::Tester

  attr_accessor :sentences

  def initialize path="#{File.dirname(__FILE__)}/treebank3.2.txt"
    # Sentences are stored as array's of word-tag pairs, where each sentence
    # will be [{:word => w1, :tag => t1},...,{:word => wn, :tag => tn}].
    @sentences = []
    self.load path
  end

  def load path
    # For each sentence we split on empty space, and then use regex to split
    # each word/tag pair into its word and tag constituents. Whenever a full
    # stop is encountered we create a new sentence.
    File.open(path, "r") do |file|
      sentence  = []
      while (line = file.gets)
        line.split(' ').each do |part|
          md = /(.+)+(\/){1}(.+)+/.match part
          if md
            if md[3] == "."
              @sentences << sentence if not sentence.empty?
              sentence = []
            else
              sentence << {:word => md[1].downcase, :tag => md[3]}
            end
          end
        end
      end
    end
  end

  def create_tagger
    Parts::Tagger.new @sentences
  end

  def test_tagger k=10
    # This method performs k-fold validation, with the default number being 10
    # folds. We first shuffle our sentences to ensure that we do not always
    # run exactly the same test, enabling us to further repeat our k-fold
    # validation. We then create an offset value along which we make our
    # folds.
    sentences = @sentences.shuffle
    total = sentences.length
    offset = (total.to_f*k.to_f/100).floor
  
    # For each fold, we divide our sentences up into test and training
    # sentences, by rotating the list by our offset amount, then partitioning
    # accordingly. We then initialise a tagger with our training set 
    # before passing in each of our test sentences for classification.
    results = (0...k).map do |i|
      print "Starting fold #{i+1}..."
      sentences = sentences.rotate offset
      test = sentences[0...offset]
      train = sentences[offset...total]
    
      c = Parts::Tagger.new train
    
      # For each sentence in our array of test sentences, we calculate the
      # accuracy with which its words were classified, before mapping these
      # results to a new array, which we finally take the mean of.
      percentage = test.map {|s| test_tagger_with_sentence c, s}
    
      # Here we simply print out that we've completed our fold, along with the
      # fold's accuracy. "%.2f" returns our accuracy percentage to 2.d.p.
      puts "done"
      puts "Fold #{i+1} accuracy: #{"%.2f" % (percentage.mean * 100)}%"
      percentage.mean
    end
  
    # Here we take the mean of each fold and print it out.
    puts "Avg. #{k}-fold accuracy: #{"%.2f" % (results.mean * 100)}%"
  
    # Finally return the k-fold validation's mean accuracy.
    return results.mean
  end

  def test_tagger_with_sentence tagger, sentence
    cs = tagger.classify sentence.map{|w| w[:word]}
    correct = cs.zip(sentence).select{|ws| ws[0][:tag] == ws[1][:tag]}.length
    correct.to_f / sentence.length
  end

end
