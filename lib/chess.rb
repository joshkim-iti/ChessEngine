require "json"

class Chess
    attr_accessor :board, :p1_turn, :white_pieces, :black_pieces, :can_castle, :en_passant, :w_king, :b_king, :game_over    

    def load (board, p1_turn, can_castle, en_passant, w_king, b_king)
        @board = board
        @p1_turn = p1_turn
        @can_castle = can_castle
        @en_passant = en_passant
        @w_king = w_king
        @b_king = b_king
    end

    def from_json(string)
        data = JSON.load string
        self.load(data['board'], data['p1_turn'], data['can_castle'], data['en_passant'], data['w_king'], data['b_king'])
    end

    def to_json
        JSON.dump({
            board: @board,
            p1_turn: @p1_turn,
            can_castle: @can_castle,
            en_passant: @en_passant,
            w_king: @w_king,
            b_king: @b_king
        })
    end

    def initialize
        @white_pieces = ["♖", "♘", "♗", "♕", "♔", "♙"]
        @black_pieces = ["♜", "♞", "♝", "♛", "♚", "♟︎"]
        puts "Load a save file? (Y/N)"
        ans = gets.chomp
        if ans.upcase == "Y"
            fname = "/Users/josh.kim/Desktop/OdinProjects/lib/chess_save_file.txt"
            save_file = File.open(fname)
            from_json(save_file.read)
            save_file.close
        else
            @board = Array.new(8) {Array.new(8, "_")}
            @board[0] = ["♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜"]
            @board[7] = ["♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"]
            for i in 0..7
                @board[1][i] = "♟︎"
                @board[6][i] = "♙"
            end
            @p1_turn = true
            @en_passant = Array.new
            @did_en_passant = false
            @can_castle = [true, true, true, true, true, true] #[moved left white rook, moved white king, moved right white rook, moved left black rook, moved white king, moved right black rook]  
            @w_king = [7, 4]
            @b_king = [0, 4]
        end
        @game_over = false
    end

    def see_board
        count = 8
        @board.each do |arr|
            print count.to_s + " |"
            arr.each do |val|
                print val + "|"
            end
            count -= 1
            puts ""
        end
        puts "   a b c d e f g h\n\n"
    end

    def pawn_moves(piece, x, y)
        moves = Array.new
        if piece == "♙" || piece == "♔"
            if x == 6 && @board[x-2][y] == "_"
                moves.push([x-2, y])
            end
            if x > 0 && @board[x-1][y] == "_"
                moves.push([x-1, y])
            end
            if x > 0 && y < 7 && @black_pieces.include?(@board[x-1][y+1])
                if piece == "♔" && @board[x-1][y+1] == "♟︎"
                    return "check"
                end
                moves.push([x-1, y+1])
            end
            if x > 0 && y > 0 && @black_pieces.include?(@board[x-1][y-1])
                if piece == "♔" && @board[x-1][y-1] == "♟︎"
                    return "check"
                end
                moves.push([x-1, y-1])
            end
        else
            if x == 1 && @board[x+2][y] == "_"
                moves.push([x+2, y])
            end
            if x < 7 && @board[x+1][y] == "_"
                moves.push([x+1, y])
            end
            if x < 7 && y < 7 && @white_pieces.include?(@board[x+1][y+1])
                if piece == "♚" && @board[x+1][y+1] == "♙"
                    return "check"
                end
                moves.push([x+1, y+1])
            end
            if x < 7 && y > 0 && @white_pieces.include?(@board[x+1][y-1])
                if piece == "♚" && @board[x+1][y-1] == "♙"
                    return "check"
                end
                moves.push([x+1, y-1])
            end
        end
        if @en_passant.include?([x,y]) && @en_passant.include?(piece)
            moves.push([@en_passant[2],@en_passant[3]])
        end
        moves
    end

    def knight_moves (piece, x, y)
        moves = Array.new
        temp_moves = []
        temp_moves.push([x+1,y+2])
        temp_moves.push([x+1,y-2])
        temp_moves.push([x-1,y+2])
        temp_moves.push([x-1,y-2])
        temp_moves.push([x+2,y+1])
        temp_moves.push([x+2,y-1])
        temp_moves.push([x-2,y+1])
        temp_moves.push([x-2,y-1])
        temp_moves.each do |arr|
            #puts arr[0].to_s + " " + arr[1].to_s
            if piece == "♘" || piece == "♔"
                if arr[0]>=0 && arr[0]<=7 && arr[1]>=0 && arr[1]<=7 && !white_pieces.include?(@board[arr[0]][arr[1]])
                    if piece == "♔" && @board[arr[0]][arr[1]] == "♞"
                        return "check"
                    end
                    moves.push(arr)
                end
            else
                if arr[0]>=0 && arr[0]<=7 && arr[1]>=0 && arr[1]<=7 && !black_pieces.include?(@board[arr[0]][arr[1]])
                    if piece == "♚" && @board[arr[0]][arr[1]] == "♘"
                        return "check"
                    end
                    moves.push(arr)
                end
            end
        end
        moves
    end

    def rook_moves (piece, x, y)
        moves = Array.new
        iter = 1 #down
        while x + iter < 8 && @board[x+iter][y] == "_"
            moves.push([x+iter,y])
            iter += 1
        end
        if piece == "♖" || piece == "♕" || piece == "♔"
            if x + iter < 8 && @black_pieces.include?(@board[x+iter][y])
                if piece == "♔" && (@board[x+iter][y] == "♜" || @board[x+iter][y] == "♛")
                    return "check"
                end
                moves.push([x+iter,y])
            end
        else
            if x + iter < 8 && @white_pieces.include?(@board[x+iter][y])
                if piece == "♚" && (@board[x+iter][y] == "♖" || @board[x+iter][y] == "♕")
                    return "check"
                end
                moves.push([x+iter,y])
            end
        end

        iter = 1 #up
        while x - iter >= 0 && @board[x-iter][y] == "_"
            #puts "got here"
            #puts x - iter
            #puts @board[x-iter][y]
            moves.push([x-iter,y])
            #puts moves
            iter += 1
        end
        if piece == "♖" || piece == "♕" || piece == "♔"
            if x - iter >=0 && @black_pieces.include?(@board[x-iter][y])
                if piece == "♔" && (@board[x-iter][y] == "♜" || @board[x-iter][y] == "♛")
                    return "check"
                end
                moves.push([x-iter,y])
            end
        else
            if x - iter >=0 && @white_pieces.include?(@board[x-iter][y])
                if piece == "♚" && (@board[x-iter][y] == "♖" || @board[x-iter][y] == "♕")
                    return "check"
                end
                moves.push([x-iter,y])
            end
        end

        iter = 1 #right
        while y + iter < 8 && @board[x][y+iter] == "_"
            moves.push([x,y+iter])
            iter += 1
        end
        if piece == "♖" || piece == "♕" || piece == "♔"
            if y + iter < 8 && @black_pieces.include?(@board[x][y+iter])
                if piece == "♔" && (@board[x][y+iter] == "♜" || @board[x][y+iter] == "♛")
                    return "check"
                end
                moves.push([x,y+iter])
            end
        else
            if y + iter < 8 && @white_pieces.include?(@board[x][y+iter])
                if piece == "♚" && (@board[x][y+iter] == "♖" || @board[x][y+iter] == "♕")
                    return "check"
                end
                moves.push([x,y+iter])
            end
        end

        iter = 1 #left
        while y - iter >= 0 && @board[x][y - iter] == "_"
            moves.push([x,y - iter])
            iter += 1
        end
        if piece == "♖" || piece == "♕" || piece == "♔"
            if y - iter >= 0 && @black_pieces.include?(@board[x][y - iter])
                if piece == "♔" && (@board[x][y - iter] == "♜" || @board[x][y - iter] == "♛")
                    return "check"
                end
                moves.push([x,y - iter])
            end
        else
            if y - iter >= 0 && @white_pieces.include?(@board[x][y - iter])
                if piece == "♚" && (@board[x][y - iter] == "♖" || @board[x][y - iter] == "♕")
                    return "check"
                end
                moves.push([x,y - iter])
            end
        end
        moves
    end

    def bishop_moves(piece, x, y)
        moves = Array.new
        iter = 1 #down right
        while x + iter < 8 && y + iter < 8 && @board[x + iter][y + iter] == "_"
            moves.push([x + iter, y + iter])
            iter += 1
        end
        if piece == "♗" || piece == "♕" || piece == "♔"
            if x + iter < 8 && y + iter < 8 && @black_pieces.include?(@board[x + iter][y + iter])
                if piece == "♔" && (@board[x + iter][y + iter] == "♝" || @board[x + iter][y + iter] == "♛")
                    return "check"
                end
                moves.push([x + iter, y + iter])
            end
        else
            if x + iter < 8 && y + iter < 8 && @white_pieces.include?(@board[x + iter][y + iter])
                if piece == "♚" && (@board[x + iter][y + iter] == "♗" || @board[x - iter][y + iter] == "♕")
                    return "check"
                end
                moves.push([x + iter, y + iter])
            end
        end

        iter = 1 #up right
        while x - iter >= 0 && y + iter < 8 && @board[x-iter][y + iter] == "_"
            moves.push([x - iter, y + iter])
            #puts moves
            iter += 1
        end
        if piece == "♗" || piece == "♕" || piece == "♔"
            if x - iter >=0 && y + iter < 8 && @black_pieces.include?(@board[x-iter][y + iter])
                if piece == "♔" && (@board[x - iter][y + iter] == "♝" || @board[x - iter][y + iter] == "♛")
                    return "check"
                end
                moves.push([x - iter, y + iter])
            end
        else
            if x - iter >=0 && y + iter < 8 && @white_pieces.include?(@board[x-iter][y + iter])
                if piece == "♚" && (@board[x - iter][y + iter] == "♗" || @board[x - iter][y + iter] == "♕")
                    return "check"
                end
                moves.push([x - iter, y + iter])
            end
        end

        iter = 1 #down left
        while x + iter < 8 && y - iter >= 0 && @board[x + iter][y - iter] == "_"
            moves.push([x + iter, y - iter])
            iter += 1
        end
        if piece == "♗" || piece == "♕" || piece == "♔"
            if x + iter < 8 && y - iter >= 0 && @black_pieces.include?(@board[x + iter][y - iter])
                if piece == "♔" && (@board[x + iter][y - iter] == "♝" || @board[x + iter][y - iter] == "♛")
                    return "check"
                end
                moves.push([x + iter, y - iter])
            end
        else
            if x + iter < 8 && y - iter >= 0 && @white_pieces.include?(@board[x + iter][y - iter])
                if piece == "♚" && (@board[x + iter][y - iter] == "♗" || @board[x + iter][y - iter] == "♕")
                    return "check"
                end
                moves.push([x + iter, y - iter])
            end
        end

        iter = 1 #up left
        while x - iter >= 0 && y - iter >= 0 && @board[x - iter][y - iter] == "_"
            moves.push([x - iter, y - iter])
            iter += 1
        end
        if piece == "♗" || piece == "♕" || piece == "♔"
            if x - iter >= 0 && y - iter >= 0 && @black_pieces.include?(@board[x - iter][y - iter])
                if piece == "♔" && (@board[x - iter][y - iter] == "♝" || @board[x - iter][y - iter] == "♛")
                    return "check"
                end
                moves.push([x - iter, y - iter])
            end
        else
            if x - iter >= 0 && y - iter >= 0 && @white_pieces.include?(@board[x - iter][y - iter])
                if piece == "♚" && (@board[x - iter][y - iter] == "♗" || @board[x - iter][y - iter] == "♕")
                    return "check"
                end
                moves.push([x - iter, y - iter])
            end
        end
        moves
    end

    def queen_moves (piece, x, y)
        #puts "queen moves"
        #puts rook_moves(piece, x, y).concat(bishop_moves(piece, x, y))
        rook_moves(piece, x, y).concat(bishop_moves(piece, x, y))
    end

    def in_check? (piece, x, y)
        if pawn_moves(piece, x, y) == "check" 
            #puts "check by pawn"
            return true
        end
        if knight_moves(piece, x, y) == "check" 
            #puts "check by knight"
            return true
        end
        if rook_moves(piece, x, y) == "check" 
            #puts "check by rook or queen"
            return true
        end
        if bishop_moves(piece, x, y) == "check"
            #puts "check by bishop or queen"
            return true
        end
        false
        #if pawn_moves(piece, x, y) == "check" || knight_moves(piece, x, y) == "check" || rook_moves(piece, x, y) == "check" || bishop_moves(piece, x, y) == "check"
        #    return true
        #end
        #false
    end

    def king_moves (piece, x, y)
        moves = Array.new
        for i in -1..1
            for j in -1..1
                unless i == 0 && j == 0
                    if x + i < 8 && x + i >= 0 && y + j < 8 && y + j >=0
                        if piece == "♔"
                            if @board[x + i][y + j] == "_" || @black_pieces.include?(@board[x + i][y + j])
                                unless in_check?(piece, x + i, y + j)
                                    moves.push([x + i, y + j])
                                end
                            end
                        else
                            if @board[x + i][y + j] == "_" || @white_pieces.include?(@board[x + i][y + j])
                                unless in_check?(piece, x + i, y + j)
                                    moves.push([x + i, y + j])
                                end
                            end
                        end
                    end
                end
            end
        end

        #castling
        if piece == "♔" && @can_castle[0] && @can_castle[1] #castle white king queen side
            unless in_check?(piece, x, y) || in_check?(piece, x, y - 1) || in_check?(piece, x, y - 2)
                if @board[x][y-1] == "_" && @board[x][y-2] == "_" && @board[x][y-3] == "_"
                    moves.push([x, y - 2])
                end
            end
        end
        if piece == "♔" && @can_castle[2] && @can_castle[1] #castle white king king side
            unless in_check?(piece, x, y) || in_check?(piece, x, y + 1) || in_check?(piece, x, y + 2)
                if @board[x][y+1] == "_" && @board[x][y+2] == "_"
                    moves.push([x, y + 2])
                end
            end
        end
        if piece == "♚" && @can_castle[3] && @can_castle[4] #castle black king queen side
            unless in_check?(piece, x, y) || in_check?(piece, x, y - 1) || in_check?(piece, x, y - 2)
                if @board[x][y-1] == "_" && @board[x][y-2] == "_" && @board[x][y-3]
                    moves.push([x, y - 2])
                end
            end
        end
        if piece == "♚" && @can_castle[5] && @can_castle[4] #castle black king king side
            unless in_check?(piece, x, y) || in_check?(piece, x, y + 1) || in_check?(piece, x, y + 2)
                if @board[x][y + 1] == "_" && @board[x][y + 2] == "_"
                    moves.push([x, y + 2])
                end
            end
        end
        moves
    end

    def legal_moves (piece, x, y)
        case piece
        when "♙", "♟︎"
            #puts "pawn move"
            return pawn_moves(piece, x, y)
        when "♘","♞"
            #puts "knight move"
            return knight_moves(piece, x, y)
        when "♖", "♜"
            #puts "rook move"
            return rook_moves(piece, x, y)
        when "♗", "♝"
            #puts "bishop move"
            return bishop_moves(piece, x, y)
        when "♕", "♛"
            #puts "queen move"
            return queen_moves(piece, x, y)
        when "♔", "♚"
            #puts "king move"
            return king_moves(piece, x, y)
        end
        puts "???? move"
        moves = Array.new
    end

    def update_game_state(piece, start_x, start_y, end_x, end_y)
        #puts "updated??? "
        #piece = @board[start_x][start_y]
        #puts "#{start_x}, #{start_y}, #{@board[start_x][start_y]}"

        #moved rook or king? (for castling purposes)
        if start_x == 7 && start_y == 0
            @can_castle[0] = false
        elsif start_x == 7 && start_y == 4
            @can_castle[1] = false
        elsif start_x == 7 && start_y == 7
            @can_castle[2] = false
        elsif start_x == 0 && start_y == 0
            @can_castle[3] = false
        elsif start_x == 0 && start_y == 4
            @can_castle[4] = false
        elsif start_x == 0 && start_y == 7
            @can_castle[5] = false
        end
        
        #puts "#{piece} #{start_x} #{start_y} #{end_y} #{end_x}"

        #en_passant opporunity for opponent?
        if piece == "♙" && start_x == 6 && start_x - 2 == end_x
            @en_passant = [[start_x - 2, start_y + 1], [start_x - 2, start_y - 1], start_x - 1, start_y, "♟︎"]
        elsif piece == "♟︎" && start_x == 1 && start_x + 2 == end_x
            @en_passant = [[start_x + 2, start_y + 1], [start_x + 2, start_y - 1], start_x + 1, start_y, "♙"]
        else
            @en_passant.clear
        end

        #king position
        #puts "#{start_x}, #{start_y}  and  #{@b_king[0]}, #{@b_king[1]}"
        if start_x == @b_king[0] && start_y == @b_king[1]
            #puts "b_king moved to #{end_x}, #{end_y}"
            @b_king = [end_x, end_y]
        elsif [start_x, start_y] == @w_king
            @w_king = [end_x, end_y]
        end

        #puts "#{piece}, #{end_x}"
         #promote?
         if (piece == "♙" && end_x == 0) || (piece == "♟︎" && end_x == 7)
            puts "Promotion! Promote to: Queen (Q), Rook (R), Bishop (B), or Knight (N)"
            input = gets.chomp.upcase
            case input
            when "Q"
                if piece == "♙" 
                    @board[end_x][end_y] = "♕"
                else
                    @board[end_x][end_y] = "♛"
                end
            when "R"
                if piece == "♙" 
                    @board[end_x][end_y] = "♖"
                else
                    @board[end_x][end_y] = "♜"
                end
            when "B"
                if piece == "♙" 
                    @board[end_x][end_y] = "♗"
                else
                    @board[end_x][end_y] = "♝"
                end
            when "N"
                if piece == "♙" 
                    @board[end_x][end_y] = "♘"
                else
                    @board[end_x][end_y] = "♞"
                end
            end
            #see_board
        end

        @p1_turn = !@p1_turn
    end

    def do_move (start_x, start_y, end_x, end_y)
        piece = @board[start_x][start_y]

        @board[end_x][end_y] = piece
        @board[start_x][start_y] = "_"

        #did castle?
        if piece == "♔"
            if end_y - start_y == 2
                @board[7][7] = "_"
                @board[7][5] = "♖"
            elsif start_y - end_y == 2
                @board[7][0] = "_"
                @board[7][3] = "♖"
            end
        elsif piece == "♚"
            if end_y - start_y == 2
                @board[0][7] = "_"
                @board[0][5] = "♜"
            elsif start_y - end_y == 2
                @board[0][0] = "_"
                @board[0][3] = "♜"
            end
        end

        #did en passant?
        if (!@en_passant.empty?) && @en_passant[2] == end_x && @en_passant[3] == end_y 
            if piece == "♙"
                @board[end_x + 1][end_y] = "_"
            else
                @board[end_x - 1][end_y] = "_"
            end
        end
    end

    def puts_check? (start_x, start_y, end_x, end_y) #called when piece is not king
        temp_board = @board.clone.map(&:clone)
        do_move(start_x, start_y, end_x, end_y)
        if @p1_turn
            if in_check?("♔", @w_king[0], @w_king[1])
                @board = temp_board
                true
            else
                @board = temp_board
                false
            end
        else
            if in_check?("♚", @b_king[0], @b_king[1])
                @board = temp_board
                true
            else
                @board = temp_board
                false
            end
        end
    end

    def any_legal_move?
        #legal_moves = Array.new
        if @p1_turn
            @board.each_with_index do |arr, x_index|
                arr.each_with_index do |piece, y_index|
                    if white_pieces.include? piece
                        moves = legal_moves(piece, x_index, y_index)
                        moves.each do |pos|
                            unless puts_check?(x_index, y_index, pos[0], pos[1])
                                return true
                            end
                        end
                    end
                end
            end
        else
            @board.each_with_index do |arr, x_index|
                arr.each_with_index do |piece, y_index|
                    if black_pieces.include? piece
                        moves = legal_moves(piece, x_index, y_index)
                        moves.each do |pos|
                            unless puts_check?(x_index, y_index, pos[0], pos[1])
                                return true
                            end
                        end
                    end
                end
            end
        end
        false
    end

    def move_piece? (start_x, start_y, end_x, end_y)
        unless start_x <= 7 && start_x >= 0 && start_y <= 7 && start_y >= 0 && end_x <= 7 && end_x >= 0 && end_y <= 7 && end_y >= 0
            puts "Invalid Move! -Out of Bounds"
            return false
        end

        piece = @board[start_x][start_y]
        unless piece != "_"
            puts "Invalid Move! -Empty Square"
            return false
        end
        if (@p1_turn && @black_pieces.include?(piece)) || ((!@p1_turn) && @white_pieces.include?(piece))
            puts "Invalid Move! -Not your piece"
            return false
        end

        moves = legal_moves(piece, start_x, start_y)

        unless moves.include?([end_x, end_y])
            puts "Invalid Move! -Can't Go There"
            return false
        else

            #if king is in check move must remedy that
            if piece != "♔" && piece != "♚"
                puts piece
                if @p1_turn && in_check?("♔", @w_king[0], @w_king[1] ) && (puts_check?(start_x, start_y, end_x, end_y)) 
                    puts "Invalid Move! -King is in check"
                    return false
                elsif (!@p1_turn) && in_check?("♚", @b_king[0], @b_king[1] ) && (puts_check?(start_x, start_y, end_x, end_y))
                    puts "Invalid Move! -King is in check"
                    return false
                end
                
                #move cannot cause own king to be in check
                if puts_check?(start_x, start_y, end_x, end_y) 
                    puts "Invalid Move! -Puts king in check"
                    return false
                end
            end

            do_move(start_x, start_y, end_x, end_y)     
            update_game_state(piece, start_x, start_y, end_x, end_y)      
        end
        true
    end

    def to_index(char)
        char.ord - 97
    end

    def to_move (str)
        moves = str.split(" ")
        s_moves = moves[0].split("")
        e_moves = moves[1].split("")
        start_x = 8 - s_moves[1].to_i
        start_y = to_index(s_moves[0])
        end_x = 8 - e_moves[1].to_i
        end_y = to_index(e_moves[0])
        [start_x, start_y, end_x, end_y]
    end

    def get_move
        input = gets.chomp
        if input == "save"
            fname = "/Users/josh.kim/Desktop/OdinProjects/lib/chess_save_file.txt"
            save_file = File.open(fname, "w")
            save_file.puts to_json
            save_file.close
        else
            moves = to_move(input)
            until move_piece?(moves[0], moves[1], moves[2], moves[3])
                input = gets.chomp
                moves = to_move(input)
            end
        end
    end

    def run_game
        see_board
        #end game
        until @game_over
            unless any_legal_move?
                if @p1_turn && in_check?("♔", @w_king[0], @w_king[1])
                    puts "Game Over! Black wins"
                elsif (!@p1_turn) && in_check?("♚", @b_king[0], @b_king[1])
                    puts "Game Over! White Wins"
                else
                    puts "Game Over! Stalemate (No legal moves)"
                end
                @game_over = true
            else
                get_move
                see_board
            end
        end
        #puts "the black king is at #{@b_king[0]}, #{@b_king[1]} and the white king is at #{@w_king[0]}, #{@w_king[1]}"
    end

end

#new_game = Chess.new
#new_game.board = [["♜", "♞", "♝", "_", "♚", "♝", "♞", "♜"], ["♟︎","♟︎","_","♟︎","♟︎","♟︎","♟︎","♟︎"], ["_", "♙", "_", "_","_","_","_", "_"], ["_", "_", "♟︎", "_","_","_","_", "_"], ["_", "_", "_", "_","_","_","_", "_"], ["_", "_", "♙", "_","_","_","_", "_"], ["_", "_","_","♙", "♙", "♙", "♙", "♙"], ["♖", "♘", "♛", "♕", "♔", "♗", "♘", "♖"]]
#new_game.see_board
#puts new_game.in_check?("♔", 2, 3)
#puts new_game.in_check?("♚", 6, 3)
#new_game.run_game