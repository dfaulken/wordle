require 'pry-byebug'

class Solver
  VALID_INPUT_LENGTH = 5
  VALID_INPUT_CHARACTERS = %w[b g y]
  GREEN_EXTRA_VALUE_FACTOR = 2.0

  def best_word
    return 'stare' if guess_count == 0 # comment and re-cache whenever algorithm changed

    occurrences = Hash.new 0
    occurrences_in_position = {}

    0.upto(VALID_INPUT_LENGTH).each do |index|
      occurrences_in_position[index] = Hash.new 0
    end
    @words.each do |word|
      word_letters = word.each_char.uniq
      word_letters.each.with_index do |word_letter, word_index|
        occurrences[word_letter] += 1
        occurrences_in_position[word_index][word_letter] += 1
      end
    end

    @words.max_by do |word|
      word_letters = word.each_char.uniq
      matching_occurrences = word_letters.map do |word_letter|
        occurrences[word_letter]
      end.inject(:+)
      matching_occurrences_in_position = word_letters.map.with_index do |word_letter, word_index|
        occurrences_in_position[word_index][word_letter]
      end.inject(:+)
      # It's faster (and only marginally less effective) to just favor yellows or greens, rather than favoring greens over yellows.
      # But getting more greens earlier is more impressive, I think.
      # Uncomment the line below to revert that behavior.
      # matching_occurrences
      matching_occurrences_in_position * GREEN_EXTRA_VALUE_FACTOR + matching_occurrences
    end
  end

  def guess_count
    @guesses.keys.count
  end

  def initialize
    @eliminated_letters = []
    @guesses = {}
    @words = read_wordlist_file
  end

  def process_input(guess_word, guess_result)
    @guesses[guess_word] = guess_result
    if guess_result.include? 'b'
      guess_result.each_char.with_index do |result_char, word_index|
        # Only eliminate a letter if it isn't green or yellow somewhere else in the word.
        if result_char == 'b' && guess_word.each_char.count(guess_word[word_index]) == 1
          @eliminated_letters << guess_word[word_index]
        end
      end
      @words.delete_if do |word|
        @eliminated_letters.any? do |letter|
          word.include? letter
        end
      end
    end
    if guess_result.include?('g') || guess_result.include?('y')
      @words.keep_if(&method(:is_candidate?))
    end
  end

  def solved?
    @guesses.values.any? do |guess_result|
      guess_result == 'ggggg'
    end
  end

  def self.input_valid?(input)
    input.each_char.all? do |input_char|
      VALID_INPUT_CHARACTERS.include? input_char
    end && input.length == VALID_INPUT_LENGTH
  end

  private

  def is_candidate?(word)
    word_letters = word.each_char
    return false if word_letters.any? do |word_letter|
      @eliminated_letters.include? word_letter
    end
    return false if @guesses.each_pair.any? do |guess_word, guess_result|
      !word_matches_guess?(word, guess_word, guess_result)
    end
    return true
  end

  def read_wordlist_file
    wordlist_text = File.read 'wordlist.txt'
    wordlist = wordlist_text.split('","')
    wordlist.first.gsub! '"', ''
    wordlist.last.gsub! '"', ''
    wordlist
  end

  def word_matches_guess?(word, guess_word, guess_result)
    guess_result.each_char.with_index do |result_char, word_index|
      guess_letter = guess_word[word_index]
      if result_char == 'g'
        return false if word[word_index] != guess_letter
      elsif result_char == 'y'
        return false unless word.include? guess_letter
        return false if word[word_index] == guess_letter
      elsif result_char == 'b' && guess_word.count(guess_letter) > 1
        # If guess letter is already green somewhere else in guess word,
        # but black at this index,
        # guess word contains too many of guess letter.
        guess_word_guess_letter_results = guess_word.each_char.with_index.map do |guess_word_char, guess_word_index|
          guess_result[guess_word_index] if guess_word_char == guess_letter
        end.compact
        okay_guess_letter_count = guess_word_guess_letter_results.count('g') + guess_word_guess_letter_results.count('y')
        guess_word_has_too_many_guess_letter = guess_word_guess_letter_results.include? 'b'
        # If word also contains too many of guess letter, reject.  
        word_has_too_many_guess_letter = word.each_char.count(guess_letter) > okay_guess_letter_count 
        return false if guess_word_has_too_many_guess_letter && word_has_too_many_guess_letter
      end
    end
    return true
  end
end