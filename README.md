# wordle

A naive first approach to a Wordle solver.

Plays only in hard mode. Guesses only words on the current-as-of-writing Wordle wordlist.

## Usage

```
$ ruby solve.rb
```

Suggests optimal guesses. You can use the suggested guess or your own.

Enter the feedback you receive as five colors, `b` for black, `y` for yellow, or `g` for green.

Based on the feedback that you enter, suggests optimal followup guesses. You can use the suggested guess, or your own.

Lather, rinse, repeat.

Example:

```
$ ruby solve.rb
I suggest: stare
What word will you try? fuzzy
How did that word do? (bgy): bbbbb
I suggest: stare
What word will you try? stare
How did that word do? (bgy): bbbby
I suggest: melon
What word will you try? melon
How did that word do? (bgy): bggyb
I suggest: cello
What word will you try? cello
How did that word do? (bgy): bgggg
I suggest: hello
What word will you try? hello
How did that word do? (bgy): ggggg
Nice! We got it in 5!
```

### What does 'optimal' mean?

This is why I call the solution naive. Unlike more sophisticated ideas that use information theory and entropy, this evaluates each word in the candidate list to see how many yellows or greens would be produced by guessing each word, when compared to the rest of the candidate list.

This is not necessarily the same (in fact, usually not the same) as actually evaluating which word would give the player the most information.

However, at an average guess rate of 3.6-ish, as compared to the (unproven-but-demonstrable) 'optimal' of around 3.3, it's pretty good for what I was hoping to achieve on a first try.

## Testing

```
$ ruby test.rb
```

Evaluates the solver algorithm to ensure that it is capable of solving each word on the Wordle wordlist.

The starting word is normally hardcoded, but if you wish to use another starting word to evaluate its performance, you can do so by specifying it as an argument in all caps:

```
$ ruby test.rb OCEAN
```

Or if you wish to evaluate how the current algorithm will solve one particular word, you can do so by specifying it as an all-lowercase argument:

```
$ ruby test.rb quilt
```

You can also combine the two, to observe how the algorithm would traverse from a starting word to a target word.

```
$ ruby test.rb OCEAN quilt
# or equivalently
$ ruby test.rb quilt OCEAN
```

The single-word test method gives nice (I think) colorized output:

![image](https://user-images.githubusercontent.com/3988134/152879645-80a12c54-fc4d-4078-a5a5-b55d124c2f1e.png)
