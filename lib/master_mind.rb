class MasterMind
    CODE_LENGTH = 4
    attr_accessor :code, :move_count, :current_guess, :game_over

    def initialize
        @code = (0...4).map { (65 + rand(6)).chr }.join
        @move_count = 0
        @game_over = false
    end
    
    def guess?
        puts "Enter code of length 4 and comprised of chars A..F: #{12-move_count} Moves left"
        code_guess = gets.chomp
        unless code_guess.length!=4
            @current_guess = code_guess
            @move_count += 1
            return true
        else
            puts "Invalid move!"
            return false
        end
    end
    
    def guess_feedback?
        correct_chars = @code.count @current_guess
        code_chars = @code.split("")
        guess_chars = @current_guess.split("")
        pos_count = 0

        code_chars.each_with_index do |letter, index|
            if letter == guess_chars[index]
                pos_count += 1
            end
        end 

        correct_chars -= pos_count

        for i in 0..(pos_count-1) do
            print "C"
        end

        for i in 0..(correct_chars-1) do
            print "A"
        end

        for i in 0..(CODE_LENGTH-pos_count-correct_chars-1) do
            print "I"
        end
        
        print "\n"

        pos_count == CODE_LENGTH
    end


    def run_game
        until @game_over
            until guess?
            end
            @game_over = self.guess_feedback? || @move_count > 11
        end
        puts code
        puts "Game Over!"
    end

end

new_game = MasterMind.new
#puts new_game.code
puts new_game.run_game