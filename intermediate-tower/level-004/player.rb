require 'coord'

class Player
  DIRS = [:forward, :left, :right, :backward]

  def initialize()
    @max_health = nil
    @warrior = nil
    @direction = :forward

    @prev_health = nil
    @health_history = []

    @location = Coord.new
    @hostiles = {@location => false}
  end

  def play_turn(warrior)
    @max_health ||= warrior.health

    @warrior = warrior
    updateHistory

    setDirection
    puts "#{@location.inspect} - #{@location.walk(@direction).inspect}"
    $stdout.flush

    saveHostileInfo
    p @hostiles
    return rescue! if feel.captive? && !wasHostile?
#?     puts "Exit? #{feel.stairs?}"
    return walk! if feel.stairs?
#?     puts "Rest? #{needRest} #{losingHealth}"
    return rest! if needRest && !losingHealth
#?     puts "Bind? #{losingHealthTooFast}"
    return bind! if losingHealthTooFast
#?     puts "Attack? #{feel.empty?}"
    return attack! unless feel.empty?
#?     puts "Walk!"

    walk!
  end

  def needRest
    @warrior.health < @max_health
  end

  def losingHealth
    @prev_health && @warrior.health < @prev_health
  end

  def saveHostileInfo
    DIRS.each do |dir|
      target = @location.walk dir
      next if @hostiles.has_key?(target)
      target_space = @warrior.feel dir
      @hostiles[target] = !(target_space.empty? || target_space.captive?)
    end
  end

  def wasHostile?
    @hostiles[@location.walk @direction]
  end

  def updateHistory
    @prev_health = @curr_health
    @curr_health = @warrior.health
    @health_history << @curr_health

    @others = @warrior.listen
  end

  def setDirection
    @direction = @warrior.direction_of @warrior.listen[0]
  rescue
    @direction = @warrior.direction_of_stairs
  end

  def walk!
    @warrior.walk! @direction
    @location = @location.walk(@direction)
  end
  def attack!
    @warrior.attack! @direction
  end
  def rescue!
    @warrior.rescue! @direction
  end
  def rest!
    @warrior.rest!
  end
  def bind!
    DIRS.each do |dir|
      return @warrior.bind!(dir) unless @warrior.feel(dir).empty? || @warrior.feel(dir).captive?
    end
  end
  def feel
    @warrior.feel @direction
  end

  def captive_nearby?
    DIRS.each do |dir|
      return @direction = dir if @warrior.feel(dir).captive?
    end
    nil
  end

  def find_empty_direction
    DIRS.each do |dir|
      return @direction = dir if @warrior.feel(dir).empty?
    end
  end

  def losingHealthTooFast
    !@prev_health.nil? && @prev_health-@curr_health > 3
  end
end
