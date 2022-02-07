require_relative 'solver'

solver = Solver.new

while !solver.solved? do
  word = solver.best_word
  if word.nil?
    puts "Every word has been eliminated. Please restart, checking feedback for mistakes."
    exit
  end
  puts "I suggest: #{word}"
  print "What word will you try? "
  provided_word = gets.chomp
  # validate
  print "How did that word do? (#{Solver::VALID_INPUT_CHARACTERS.join}): "
  provided_input = gets.chomp
  while !Solver.input_valid?(provided_input) do
    puts "Invalid input. Input must be #{Solver::VALID_INPUT_LENGTH} of #{Solver::VALID_INPUT_CHARACTERS.join ', '}."
    provided_input = gets.chomp
  end
  solver.process_input provided_word, provided_input
end
puts "Nice! We got it in #{solver.guess_count}!"