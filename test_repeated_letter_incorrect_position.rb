require_relative 'solver'

# Target word is 'ruder'.
solver = Solver.new
# There is only one E in the target word, and it is in the correct position (4) in defer,
# so the first E should be black.
solver.process_input 'defer', 'ybbgg'
if solver.best_word.nil?
  puts "Case failed! All possible alternates erroneously eliminated."
  exit
end
possible_alternates = %w[alder rider under wider]
if possible_alternates.include? solver.best_word
  puts "Case passed!"
  exit
else
  puts "Case failed! Unexpected suggested word #{solver.best_word}."
  exit
end