class Player
  def initialize()
    @max_health = nil
    @prev_health = nil
    @warrior = nil
    @direction = :forward
    @health_history = []
    @direction_history = []
    @sludgesNearby = {}
  end

  def play_turn(warrior)
    @max_health ||= warrior.health

    @warrior = warrior
    updateHistory

    return rescue! if captive_nearby? && !captiveWasSludge?
    return walk! if feel.stairs?
    return rest! if needRest && !losingHealth
    return bind! if losingHealthTooFast
    return attack! unless feel.empty?

#?     find_empty_direction
#?     reverse_direction if walking_into_fire
    walk!
  end

  def needRest
    @warrior.health < @max_health
  end

  def losingHealth
    @prev_health && @warrior.health < @prev_health
  end

  def captiveWasSludge?
    return @sludgesNearby[@direction] unless @sludgesNearby[@direction].nil?
    @sludgesNearby[@direction] = @health_history[-3] && @health_history[-3] > @curr_health
  end

  def updateHistory
    @prev_health = @curr_health
    @curr_health = @warrior.health
    @health_history << @curr_health

    @others = @warrior.listen

    @direction = @warrior.direction_of @warrior.listen[0]
#?     @direction_history << @direction
  end

  def walk!
    @sludgesNearby = {}
    @warrior.walk! @direction
  end
  def attack!
    @warrior.attack! @direction
  end
  def rescue!
    p @direction
    @warrior.rescue! @direction
  end
  def rest!
    @warrior.rest!
  end
  def bind!
    [:forward, :left, :right, :backward].each do |dir|
      return @warrior.bind!(dir) unless @warrior.feel(dir).empty? || @warrior.feel(dir).captive?
    end
  end
  def feel
    @warrior.feel @direction
  end

  def captive_nearby?
    [:forward, :left, :right, :backward].each do |dir|
      return @direction = dir if @warrior.feel(dir).captive?
    end
    nil
  end

  def find_empty_direction
    [:forward, :left, :right, :backward].each do |dir|
      return @direction = dir if @warrior.feel(dir).empty?
    end
  end

  def walking_into_fire
    return false if @direction_history[-1] != @direction_history[-2] ||
        @direction_history[-2] != @direction_history[-3]
    @health_history[-1] < @health_history[-2] && @health_history[-2] < @health_history[-3]
  rescue
    false
  end

  def losingHealthTooFast
    !@prev_health.nil? && @prev_health-@curr_health > 2
  end

  def reverse_direction
    @direction = (@direction == :forward) ? :backward : :forward
  end
end
