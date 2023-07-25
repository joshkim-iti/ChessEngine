require "json"

class Hangman
    GUESSES = 12
    attr_accessor :key, :move_count, :game_over, :current_state, :guessed_chars
   
    def load (key = nil, move_count = nil, game_over = nil, current_state = nil, guessed_chars = nil)
        @key = key
        @move_count = move_count
        @game_over = game_over
        @current_state = current_state
        @guessed_chars = guessed_chars
    end

    def from_json(string)
        data = JSON.load string
        self.load(data['key'], data['move_count'], data['game_over'], data['current_state'], data['guessed_chars'])
    end

    def initialize 
        puts "Load a save file (Y/N)"
        ans = gets.chomp
        if ans.upcase == "Y"
            fname = "/Users/josh.kim/Desktop/OdinProjects/hangman_save_files.txt"
            save_file = File.open(fname)
            from_json(save_file.read)
            save_file.close
        else
            file = File.open "/Users/josh.kim/Desktop/OdinProjects/google-10000-english-no-swears.txt"
            @key = ""
            @move_count = 0
            @game_over = false
            @guessed_chars = Array.new
            until @key.length >= 5 && @key.length <= 12
                n = 1 + rand(9894)
                n.times{ file.gets }
                @key = $_.chomp
                file.rewind
            end
            file.close
            @current_state = Array.new(@key.length, "_")
            
        end

    end 

    

    def guess_feedback (guess)
        @game_over = true
        key_chars = @key.split("")
        @guessed_chars.push(guess)
        correct_guess = false
        
        #puts guess_chars
        #puts key_chars

        for i in 0..@key.length-1
            if @current_state[i] == key_chars[i] 
                print current_state[i]+" "
            elsif guess == key_chars[i]
                @current_state[i] = guess
                print guess+" "
                correct_guess = true
            else
                print "_ "
                @game_over = false                
            end
        end

        unless correct_guess
            @move_count += 1
        end

        unless @game_over
            puts " Moves left: #{GUESSES-move_count}    Type \"save\" to save the current state"
            for i in 0..(guessed_chars.length-1)
                print guessed_chars[i] + " "
            end
            puts "Already Guessed\n\n"
        end
        
    end

    def to_json
        JSON.dump({
            :key => @key,
            :move_count => @move_count,
            :game_over => @game_over, 
            :current_state => @current_state, 
            :guessed_chars => @guessed_chars
        })
    end
    
    def run_game
        for i in 0..@key.length-1
            print current_state[i] + " "
        end
        puts " Moves left: #{GUESSES}"
        
        unless guessed_chars.empty?
            for i in 0..(guessed_chars.length-1)
                print guessed_chars[i] + " "
            end
            puts "Already Guessed\n\n"
        end
        
        saved = false
        until @game_over || @move_count > GUESSES-1 || saved
            guess = gets.chomp
            if guess == "save"
                fname = "/Users/josh.kim/Desktop/OdinProjects/hangman_save_files.txt"
                file = File.open(fname, "w")
                file.puts to_json
                file.close

                saved = true
            else
                until guess.length == 1 && !guessed_chars.include?(guess)
                    puts "Invalid guess! Enter a new letter"
                    guess = gets.chomp
                end
                guess_feedback (guess.downcase)
            end

        end
        unless saved
            puts " Game Over! #{@key}"
        end
    end 

    
    
   

end

new_game = Hangman.new
new_game.run_game
