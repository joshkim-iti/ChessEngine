def substrings (sentence, arr)
    dict = Hash.new
    arr.each do |word|
        count = sentence.downcase.scan(word).length
        if(count>0)
            dict[word] = count
        end
    end
    dict
end

#input = gets.chomp
dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
puts substrings("below", dictionary)
puts substrings("Howdy partner, sit down! How's it going?", dictionary) 