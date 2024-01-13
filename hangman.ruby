require 'json'

class Game
  attr_accessor :word, :turns_remain, :incorrect_letter, :display_word
  def initialize
    @dictionary = File.readlines('google-10000-english-no-swears.txt') 
    @word = select_random_word(5, 12, @dictionary)
    @turns_remain = 10
    @incorrect_letter = []
    @display_word = Array.new(@word.size, "_")
  end
  
  def select_random_word(min_length, max_length, dictionary)
    word = ""
    while true
      number = rand(0..(dictionary.length-1))
      if dictionary[number].size.between?(min_length + 1, max_length + 1)   # include the \n at the end of the string
        word = dictionary[number].chomp
        break
      end
    end
    word
  end

  def show_current_game_state(display_word, turns_remain, incorrect_letter)
    puts "Current word: #{display_word.join("")}"
    print "Incorrect letters: #{incorrect_letter.join(", ")}"
    puts
    puts "Turns remain: #{turns_remain}"
  end

  def is_single_letter(letter)
    letter.is_a?(String) && letter.size == 1 && letter.match?(/[a-zA-Z]/)
  end

  def get_letter
    letter = ""
    while !is_single_letter(letter)
      puts "Type in one letter of your guess from a to z or A to Z: "
      letter = gets.chomp
    end
    letter.downcase
  end 

  def check_letter(letter, word)
    positions = []
    word.split("").each_with_index do |char, index|
      positions.push index if char == letter
    end
    positions
  end

  def guess(word, display_word, incorrect_letter)
    letter = get_letter
    p positions = check_letter(letter, word)
    if (positions.size == 0)
      incorrect_letter.push letter
    else
      positions.each do |position|
        display_word[position] = letter
      end
    end
  end

  def save_game(word, turns_remain, incorrect_letter, display_word)
    puts "Enter 1 to save the game, any other key to continue playing"
    query = gets.chomp
    if query == "1"
      File.open("save.txt", "w") do |f|
        data = JSON.dump([word, turns_remain, incorrect_letter, display_word])
        f.puts data        
      end
    end
  end

  def load_game
    while @turns_remain >= 0 && (@display_word.include? "_")
      show_current_game_state(@display_word, @turns_remain, @incorrect_letter)
      guess(@word, @display_word, @incorrect_letter)
      @turns_remain -= 1
      save_game(@word, @turns_remain, @incorrect_letter, @display_word)
    end
    show_current_game_state(@display_word, @turns_remain, @incorrect_letter)
    puts "Congrat you found the word: #{@word}" unless @display_word.include? "_"
  end

  def self.load_save(file)
    f = File.readlines(file)
    data = JSON.load(f[0])
    game = self.new
    game.word = data[0]
    game.turns_remain = data[1]
    game.incorrect_letter = data[2]
    game.display_word = data[3]
    game.load_game
  end
end

puts "Enter 1 to load the game you saved, anyother keys to start a new game"
loop do
  query = gets.chomp
  if query == '1' 
    Game.load_save('save.txt')
  else
    game = Game.new
    game.load_game
  end
end



