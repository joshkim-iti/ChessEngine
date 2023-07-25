#spec/ceasar_cipher_spec.rb
require './lib/ceasar_cipher'

describe Encrypt do
    describe "shift" do
        it "shifts a non-empty lowercase string" do
            encrypter = Encrypt.new
            expect(encrypter.ceasar_cipher("what a string", 5)).to eql("bmfy f xywnsl")
        end

        it "shifts an empty lowercase string" do
            encrypter = Encrypt.new
            expect(encrypter.ceasar_cipher("", 5)).to eql("")
        end 

        it "shifts an empty lowercase string with special chars" do
            encrypter = Encrypt.new
            expect(encrypter.ceasar_cipher("what a string!", 5)).to eql("bmfy f xywnsl!")
        end 
    end
end

