require_relative 'solver'
require 'colorize'
require 'pry-byebug'

MAX_GUESS_COUNT = 6

wordlist_text = File.read 'wordlist.txt'
wordlist = wordlist_text.split('","')
wordlist.first.gsub! '"', ''
wordlist.last.gsub! '"', ''


@starting_words = ["doesn't matter, this value will be overriden if it matters"]
if ARGV.any?
  args = ARGV.map(&:chomp)
  if args.any? { |arg| arg.include? 'help' }
    puts "Usage: ruby test.rb [word to test] [STARTING WORD]"
    puts "An argument in all lowercase will be the single word tested."
    puts "An argument in all caps will be used as the starting word, instead of the word initially suggested by the solver."
    puts "Use argument FIND_SAFEST_STARTING_WORD to find the safest starting word (least failed words) given the current solver configuration."
    exit
  end
  if args.any? { |arg| arg == 'FIND_SAFEST_STARTING_WORD' }
    @find_safest_starting_word = true
    @testing_starting_word = true
    @starting_words = wordlist.shuffle
    puts "Finding safest starting word."
  else
    args.each do |arg|
      if arg == arg.downcase
        @testing_single_word = true
        @word_to_test = arg
      elsif arg == arg.upcase
        @testing_starting_word = true
        @starting_words = [arg.downcase]
      end
    end
  end
end

if @testing_single_word
  unless wordlist.include? @word_to_test
    puts "#{@word_to_test} is not in the Wordle wordlist."
    exit
  end
  wordlist = [@word_to_test]
end

def colorize_result(word, input)
  input.each_char.map.with_index do |input_char, word_index|
    letter = word[word_index].upcase
    case input_char
    when 'b' then letter
    when 'g' then letter.colorize(color: :black, background: :light_green)
    when 'y' then letter.colorize(color: :black, background: :light_yellow)
    end
  end.join
end

def construct_input(target_word, suggested_word)
  target_word_letters = target_word.each_char.to_a
  suggested_word_letters = suggested_word.each_char.to_a
  input = Array.new target_word_letters.count
  # Check for greens. Eliminate any matched.
  0.upto(target_word_letters.count - 1).each do |n|
    if suggested_word_letters[n] == target_word_letters[n]
      input[n] = 'g'
      target_word_letters[n] = nil
      suggested_word_letters[n] = nil
    end
  end
  # Process yellow and black.
  0.upto(target_word_letters.count - 1).each do |n|
    next if input[n] == 'g'
    if target_word_letters.include? suggested_word_letters[n]
      input[n] = 'y'
    else input[n] = 'b'
    end
  end
  input.join
end

guesses_to_solve = {}
total_guesses = 0
total_yellows = 0
total_greens = 0
least_failed_words = wordlist.count
safest_starting_word = nil

@starting_words.each do |starting_word|
  failed_words = []
  puts "Testing starting word #{starting_word}. Current safest starting word: #{safest_starting_word}" if @find_safest_starting_word
  wordlist.each.with_index(1) do |target_word, word_count| 
    guesses = 0
    solver = Solver.new
    while !solver.solved? do
      guesses += 1
      suggested_word = solver.best_word
      if guesses == 1 && @testing_starting_word
        suggested_word = starting_word  
      end
      input = construct_input target_word, suggested_word
      total_yellows += input.each_char.count 'y'
      total_greens += input.each_char.count 'g'
      solver.process_input suggested_word, input
      if @testing_single_word
        puts colorize_result(suggested_word, input)
        puts if solver.solved?
      end
      if solver.best_word.nil?
        puts "Error: solver has nil best word based on input #{input} constructed for target word #{target_word} and suggested word #{suggested_word}"
        exit
      end
    end
    guesses_to_solve[guesses] ||= []
    guesses_to_solve[guesses] << target_word
    if guesses > MAX_GUESS_COUNT
      failed_words << target_word
    end
    total_guesses += guesses
    if @testing_single_word
      puts "Solved in #{guesses} guesses."
    end
  end
  if @find_safest_starting_word && failed_words.count < least_failed_words
    least_failed_words = failed_words.count
    safest_starting_word = starting_word
    puts "New safest starting word: #{safest_starting_word} (#{least_failed_words} failed words)."
  end
end

if @find_safest_starting_word
  puts "Safest starting word: #{safest_starting_word} (#{least_failed_words} failed words)."
end

unless @testing_single_word || @find_safest_starting_word
  guesses_to_solve.keys.sort.each do |guess_count|
    examples = guesses_to_solve[guess_count][0...5]
    puts "#{guess_count} guesses to solve: #{guesses_to_solve[guess_count].count} words (examples: #{examples.join(', ')})"
  end
  failed_word_count = guesses_to_solve.keys.select do |guess_count|
    guess_count > MAX_GUESS_COUNT
  end.map do |guess_count|
    guesses_to_solve[guess_count].count
  end.inject(:+)
  puts "Failed words: #{failed_word_count}"
  puts "Total guesses: #{total_guesses} (Green: #{(total_greens * 20 / total_guesses.to_f).round 2}%, Yellow: #{(total_yellows * 20 / total_guesses.to_f).round 2}%)"
  puts "Average guesses per word: #{(total_guesses / wordlist.count.to_f).round 3}"
end