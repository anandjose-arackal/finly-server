#******** class definition start **************

class ChequerBoard

  def initialize(size)
    @board = Array.new(size) { Array.new(size) { '#' } }
    @size = size
    @current = 1
  end

  def move_available?(i, j)
    if i >= 0 && i < @size && j >= 0 && j < @size
      @board[i][j] == '#'
    else
      false
    end
  end


  # Rules
  # 3 tiles moving North (N), West (W), South (S) and East (E)
  # 2 tiles moving NE, SE, SW and NW
  

  # Visualization of rules
  # (row + 3,  col        )=> East
  # (row + 2,  col - 2    )=> NorthEast
  # (row    ,  col - 3    )=> North
  # (row - 2,  col - 2    )=> NorthWest
  # (row - 3,  col        )=> West
  # (row - 2,  col + 2    )=> SouthWest
  # (row    ,  col + 3    )=> South
  # (row + 2,  col + 2    )=> SouthEast


  # Valid Coordinates following rules
  # [
    # [3, 0],
    # [-3, 0],
    # [0, 3],
    # [0, -3],
    # [2, 2],
    # [2, -2],
    # [-2, 2],
    # [-2, -2]
  # ]



  def available_from(i, j)
    valid_moves = [
                  [i, j-3],
                  [i+2, j-2],
                  [i+3, j],
                  [i+2, j+2],
                  [i, j+3],
                  [i-2, j+2],
                  [i-3, j],
                  [i-2, j-2]
                ]
    available_move = valid_moves.map{ |pair| move_available?(*pair) ? pair : nil }.compact
    return available_move
  end

  def full?
    # For 10 x 10 board, current < 101 always
    @size**2 < @current
  end



  # Marks the move number on the board
  def mark(i, j)
    if move_available?(i, j)
      @board[i][j] = @current
      @current += 1
    else 
      raise "#{i},#{j} position is not available"
    end
  end



  # Pretty print output
  def to_s
    lines = "_" + "_"*5*@size + "\n"
    out = ""
    out << lines
    @board.each do |row|
      out << "|" << row.map{ |num| num.to_s.rjust(4) }.join(' ') << "|\n"
    end
    out << lines
  end
end

#******** class definition end **************



# Size of board
# size = ARGV[0].to_i if size of board is passed as command line arguements
size = 10

# This problem statement is valid if board size is greater than 4

raise "Board size should be greater than 4" if size < 5

# Set defalt value of success as false
success = false


# Loop until success is true
until success
  board = ChequerBoard.new(size)

  # Starting point

  # i = 3
  # j = 2


  # Random starting point within board size
  i = rand(size)
  j = rand(size)

  puts "Initial position => (#{i}, #{j})"

  # Mark the board
  board.mark(i, j)
  success = true

  until board.full?
    avail = board.available_from(i, j).sort { rand }

    # No moves available

    if avail.empty?
      puts "Cannot proceed"
      succes = false
      break
    end


    # Pick the best available move
    best_move = avail.inject { |best, pair|
                          board.available_from(*pair).length < board.available_from(*best).length ? pair : best
                        }

    # Mark the board
    i, j = best_move
    board.mark(i, j)
  end
end

puts board
