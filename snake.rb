require 'curses'
include Curses

begin
  cbreak; noecho; curs_set(0)

  Thread.abort_on_exception = true

  key = nil
  vector = [1, 0]
  snake = [[2, 2]]
  score = 0
  food = [rand(2..79), rand(2..24)]

  # put text at x (col), y (row)
  put = -> x, y, t { print "\033[#{y};#{x}f#{t}" }

  # clear screen
  print "\033[2J"

  # print border
  (1..25).to_a.product([1, 80]).each { |y, x| put.(x, y, '|') }
  (1..80).to_a.product([1, 25]).each { |x, y| put.(x, y, '-') }

  Thread.new do
    loop do
      put.(35, 1, "score: #{score}")                          # show score
      put.(food[0], food[1], 'x')                             # show food
      (x, y) = snake[0]                                       # get previous head
      (x, y) = [x + vector[0], y + vector[1]]                 # make a new head at next position
      x = 79 if x < 2
      x = 2  if x > 79
      y = 24 if y < 2
      y = 2  if y > 24
      exit if snake.include?([x, y])                          # die if head touches another part of snake
      snake.unshift [x, y]                                    # place the head on the snake
      put.(x, y, 'O')                                         # put the new head on screen
      if [x, y] == food                                       # found food!
        score += 10                                           # increase score
        food = [rand(2..79), rand(2..24)]                     # create new food
      else
        (x, y) = snake.pop                                    # delete the old tail
        put.(x, y, ' ')                                       # remove the old tail from screen
      end
      sleep 0.1
      sleep 0.1 if vector[1] != 0
    end
  end

  begin
    key = STDIN.getc
    case key
      # vim keys ftw
      when 'w' then vector = [ 0, -1] if vector != [ 0,  1]
      when 'a' then vector = [-1,  0] if vector != [ 1,  0]
      when 's' then vector = [ 0,  1] if vector != [ 0, -1]
      when 'd' then vector = [ 1,  0] if vector != [-1,  0]
    end
  end until key == 'Q'

ensure
  nocbreak; echo; curs_set(1)
end
