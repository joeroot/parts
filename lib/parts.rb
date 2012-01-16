class Array
  def sum; inject(:+); end;
  def mean; sum.to_f / size; end; 
end

module Parts
  
  class Tagger

    attr_accessor :bigrams, :words, :tags, :bigram_smoothing, :suffixes

    def initialize sentences
      # Tag-bigrams are stored such that P(T2|T1) = @bigrams[T1][T2].
      # Word-tag pairs are stored such that P(W|T) = @words[W][T].
      # Tags are stored such that @tags[T] = no. of occurences of T.
      @bigrams = Hash.new { |h, t| h[t] = Hash.new { |h, t| h[t] = 0 } }
      @words = Hash.new { |h, t| h[t] = Hash.new { |h, t| h[t] = 0 } }
      @tags = Hash.new { |h, t| h[t] = 0 }
      @bigram_smoothing = Hash.new { |h, t| h[t] = 0 }
      @suffixes = Hash.new { |h, t| h[t] = Hash.new { |h, t| h[t] = 0 } }
      self.load sentences
    end

    def load sentences
      # Sentences are passed in as an ordered array of hash maps, where each 
      # hash map represents a word/tag pair, {:word => word, :tag => tag}.
  
      # We append and prepend a start tag and end tag to the sentence, and 
      # iterate over each bigram in the sentence and increment the relevant 
      # counters accordingly.
      sentences.each do |sentence|
        sentence = [{:word => "$start", :tag => "$start"}] + sentence
        sentence += [{:word => "$end", :tag => "$end"}]
        sentence.each_cons(2) do |previous, current|
            @words[current[:word]][current[:tag]] += 1
            @bigrams[previous[:tag]][current[:tag]] += 1
            @tags[current[:tag]] += 1
            (1..4).each do |i| 
              @suffixes[current[:word][-i..-1]][current[:tag]] += 1
            end
        end
      end
  
      # For each tag-bigram, we convert its counter value into a probability. We
      # also take into account the effect add 1 smoothing will have on each tag.
      @bigrams.each do |tag, grams|
        total = grams.values.inject(:+)
        grams.each {|g,n| grams[g] = n.to_f/total}
        @bigram_smoothing[tag] = 1 / (@tags.length + total)
      end
  
      # For each word-tag pair, we convert its counter value into a probability.
      @words.each do |word, tags|
        # If a word occurs less than once in the corpora we remove it.
        if tags.values.sum > 1
          tags.each {|t,n| tags[t] = n.to_f/@tags[t]}
        else
          @words.delete word
        end
      end
  
      # For each suffix-tag pair, we convert its counter value into a probability.
      @suffixes.each do |suffix, tags|
        tags.each {|t,n| tags[t] = n.to_f/@tags[t]}
      end
  
      # We have now initialised our two probability measures for tag-bigrams and
      # word-tag pairs, storing them in hash map data structures for easy 
      # access.
    end

    def classify sentence
      # Sentences for classification are passed in as an array of words, e.g. 
      # ["Hello", ",", "world"]. I have adapted the Viterbi algorithm to play to 
      # the strengths of Ruby. That or, it's just an implementation of Viterbi 
      # as I understand it.

      # The variable, paths, will store an array of the most succesful paths up 
      # to all of the possible word-tag pairs for our present word. For example,
      # if we are currently on the word 'world' from the above example, paths
      # will store the two highest scoring paths which result in the "NN" and
      # "NNP" variants of the word 'world.
  
      # We intialise the first stage of our paths with the start tag, and set 
      # the score to 1. We also add the end tags to our sentence.
      paths = [{:words => [{:word => "$start", :tag => "$start"}], :score => 1}]
      sentence += [{:word => "$end", :tag => "$end"}]
  
      # We iterate over each word in the sentence, initialising a new hash map
      # for each word, in which we will store the most succesful path up to each 
      # possible tag.
      sentence.each do |word|
        new_paths = Hash.new { |h, t| h[t] = {:score => -1} } 
    
        # For each path leading up to the previous word's tags, we now calculate
        # a new score for how well they lead on to each of our current word's 
        # tags.
        paths.each do |path|
          prev_tag = path[:words].last[:tag]
          tags = @words[word].keys
          # tags = @bigrams[prev_tag].keys if tags.empty?
          tags = @tags.keys if tags.empty?
      
          # For each of our current word's potential tags we generate a new
          # score. If the score for this is larger than any other scores we have
          # registered along other paths with this tag, we set it as the highest
          # achieving path for the tag we are currently looking at. In effect
          # this prunes our search space. When calculating word_score, in order 
          # to account for unseen words, we distribute the tag likelihood 
          # evenely across all tags. For our bigram score, we introduce the 
          # smoothing for each tag we look at. Bere mind that due to our 
          # initialisation of @bigrams, @bigrams[T1][T2] for a tag T1 or T2 
          # which has not appeared, will always return 0, thus ensuring our
          # smoothing will always work, even for tags we have no registered a
          # bigram probability for.
          tags.each do |tag|
            word_score = @words[word][tag] != 0 ? @words[word][tag] : classify_unknown(word, tag)
            bigram_score = @bigram_smoothing[prev_tag] + @bigrams[prev_tag][tag]
            score = path[:score] * word_score * bigram_score
            new_paths[tag] = {
              :words => (path[:words] + [{:word => word, :tag => tag}]), 
              :score => score
            } if score > new_paths[tag][:score]
          end
        end
    
        # Here we update our best paths up until this word, for each of the 
        # word's potential tags.
        paths = new_paths.values
      end
  
      # Having looped over every word, we have now covered the entire sentence,
      # and need simply pick the highest scoring path. We use [1..-1] to remove 
      # the start word-tag pair from our returned path.
      return paths.max_by {|a| a[:score]}[:words][1..-2]
  
    end

    def classify_unknown word, tag
      suffixes_weight = [0.05,0.15,0.5,0.3]
      suffixes_probability = (1..4).map do |i|
        @suffixes[word[-i..-1]][tag]
      end
      probability = suffixes_probability.zip(suffixes_weight).map{|i| i[0] * i[1]}.sum
    end

  end
  
end

require 'parts/tester'
