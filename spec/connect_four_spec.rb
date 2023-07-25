#spec/connect_four_spec.rb
require './lib/connect_four'

describe ConnectFour do
    describe "board" do
        it "initializes an empty board" do
            new_game = ConnectFour.new
            expect(new_game.board).to eql([["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"]])
        end
        
        it "initializes a board and makes a move" do
            new_game = ConnectFour.new
            new_game.successfully_make_move?(1)
            #new_game.see_board
            expect(new_game.board).to eql([["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["⚪","_","_","_","_","_","_"]])
        end

        it "initializes a board and makes 2 moves" do
            new_game = ConnectFour.new
            new_game.successfully_make_move?(1)
            new_game.successfully_make_move?(1)
            #new_game.see_board
            expect(new_game.board).to eql([["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["⚫","_","_","_","_","_","_"],["⚪","_","_","_","_","_","_"]])
        end

        it "initializes a board and makes an out of bounds move" do
            new_game = ConnectFour.new
            expect(new_game.successfully_make_move?(8)).to eql(false)
        end

        it "checks 4 in a row on custom board state (horizontal)" do
            new_game = ConnectFour.new
            new_game.board = [["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["⚫","_","_","_","_","_","_"],["⚪","⚪","⚪","⚪","⚫","⚫","⚫"]]
            new_game.see_board
            expect(new_game.four_in_a_row?).to eq(true)
        end

        it "checks 4 in a row on custom board state (diagonal)" do
            new_game = ConnectFour.new
            new_game.board = [["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","_"],["_","_","_","_","_","_","⚪"],["_","_","_","_","_","⚪","_"],["⚫","_","_","_","⚪","_","_"],["⚪","_","_","⚪","⚫","⚫","⚫"]]
            new_game.see_board
            expect(new_game.four_in_a_row?).to eq(true)
        end

    end
end