class Parts::Treebank
  
  def initialize path="#{File.dirname(__FILE__)}/treebank3.2.txt"
    # Sentences are stored as array's of word-tag pairs, where each sentence
    # will be [{:word => w1, :tag => t1},...,{:word => wn, :tag => tn}].
    @sentences = []
    self.load path
  end
  
  def sentences
    @sentences
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
  
end