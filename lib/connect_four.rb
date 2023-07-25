
class ConnectFour
    attr_accessor :board, :p1_turn, :move_count

    def initialize
        @board = Array.new(7) {Array.new(7, "_")}
        @p1_turn = true
        @move_count = 0
    end

    def see_board
        @board.each do |arr| 
            arr.each do |val| 
                if val == "_"
                    print val + "_ "
                else
                    print val + " "
                end
            end 
            puts ""
        end
    end

    def successfully_make_move? (pos)
        index = pos.to_i - 1
        iter = 6

        if index < 0|| index > 6
            puts "Invalid move!"
            return false
        end

        until iter < 0 || @board[iter][index] == "_"
            iter -= 1
        end
        
        if iter < 0
            puts "Invalid move!"
            return false
        elsif p1_turn
            @board[iter][index] = "⚪"
            @p1_turn = !@p1_turn
        else
            @board[iter][index] = "⚫"
            @p1_turn = !@p1_turn
        end
        
        true
    end

    def four_in_a_row?
        for i in 0...7
            for j in 0...4
                horizontal_check = ""
                vertical_check = ""
                for k in 0...4
                    horizontal_check += @board[i][j+k]
                    vertical_check += @board[j+k][i]
                end
                if horizontal_check == "⚫⚫⚫⚫" || horizontal_check == "⚪⚪⚪⚪" || vertical_check == "⚫⚫⚫⚫" || vertical_check == "⚪⚪⚪⚪"
                    puts "[#{i},#{j}]"
                    return true
                end
            end
        end

        for i in 0...4
            for j in 0...4
                diagonal_right_check = ""
                diagonal_left_check = ""
                for k in 0...4
                    diagonal_right_check += @board[i+k][j+k]
                    diagonal_left_check += @board[i+k][6-j-k]
                end
                if diagonal_right_check == "⚫⚫⚫⚫" || diagonal_right_check == "⚪⚪⚪⚪" || diagonal_left_check == "⚫⚫⚫⚫" || diagonal_left_check == "⚪⚪⚪⚪"
                    return true
                end
            end
        end
        false
    end

    def run_game
        until four_in_a_row? || @move_count == 49
            see_board
            puts "Select a non-full column (1-7) to drop your piece\n\n"
            pos = gets.chomp
            until successfully_make_move? (pos)
                pos = gets.chomp
            end
            @move_count += 1
        end
        see_board
        puts "Game Over!"
    end
end

new_game = ConnectFour.new
new_game.run_game