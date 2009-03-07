class Coord
  attr_reader :x, :y

  def initialize(x=0, y=0)
    @x = x
    @y = y
  end

  def walk(direction)
    case direction
      when :left
        Coord.new(@x-1, @y)
      when :right
        Coord.new(@x+1, @y)
      when :forward
        Coord.new(@x, @y+1)
      when :backward
        Coord.new(@x, @y-1)
    end
  end

  def ==(other)
    @x == other.x && @y == other.y
  end
  def eql?(other)
    @x == other.x && @y == other.y
  end
  def hash
    @x*10+@y
  end
end
