class BoardState
    attr_accessor :board, :move_count
    
    def initialize
        @board = Array.new(3) { Array.new(3, " ")}
        @move_count = 0
    end
    
    def show_board
        for i in 0..2
            puts (@board[i].reduce { |row, value| row + "|" +value}).delete_prefix('|')
            if i < 2
                puts "- - -"
            end
        end
    end

    def move? (turn)
        puts "Enter x value [0,2]"
        x = gets.chomp.to_i
        puts "Enter y value [0,2]"
        y = gets.chomp.to_i
        unless x > 2 || y > 2 || @board[x][y] != " "
            if turn
                @board[x][y] = "x"
            else
                @board[x][y] = "o"
            end
            return true
        else
            puts "Invalid move!"
            return false
        end
    end
    
    def game_end?
        if @move_count > 8
            return true
        end
        for i in 0..2
            if @board[i].all? { |val| val == "x" } || @board[i].all? { |val| val == "o"}
                return true
            end
        end
        for i in 0..2
            temp_board = @board.flatten
            if temp_board[i] + temp_board[i+3] + temp_board[i+6] == "xxx" || temp_board[i] + temp_board[i+3] + temp_board[i+6] == "ooo"
                return true
            end
        end
        if @board[0][0] + @board[1][1] + @board[2][2] == "xxx" || @board[0][0] + @board[1][1] + @board[2][2] == "ooo"
            return true
        end
        if @board[0][2] + @board[1][1] + @board[2][0] == "xxx" || @board[0][2] + @board[1][1] + @board[2][0] == "ooo"
            return true
        end
        false
    end

    def run_game
        turn = true
        until game_end?
            until self.move?(turn)
            end
            turn = !turn
            @move_count += 1
            self.show_board
        end
    end
end

new_game = BoardState.new
new_game.run_game