require 'coord'
require 'actions'

class Player
  def initialize
    @health_history = []
  end

  def play_turn(warrior)
    preprocess warrior
    process_layers
    pick_best_option
    postprocess
  end

  def preprocess(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health
    @actions = Actions.new
    # HACK: never bind
    DIRS.each {|dir| @actions.drop(:bind!, dir)}
  end

  def postprocess
    @health_history << @warrior.health
  end

  # Layers
  RUN = 5
  REST = 4
  UNBIND = 3
  PLAN = 2
  INVALID = 1
  RANDOM = 0

  def process_layers
    unbind_captives
    chase_subgoals
    run_from_fire
    rest_when_low_health
    skip_invalid
  end

  def unbind_captives
    DIRS.each {|d| @actions.emphasize(:rescue!, d, UNBIND) if @warrior.feel(d).captive?}
  end

  def chase_subgoals
    num_hostiles = DIRS.inject(0) {|sum, d| hostile_space?(@warrior.feel(d)) ? sum+1 : sum}
    case num_hostiles
    when 1
      DIRS.each {|d| @actions.emphasize(:attack!, d, PLAN) if hostile_space?(@warrior.feel(d))}
    when 0
      @actions.emphasize(:walk!, @warrior.direction_of(@warrior.listen.first), PLAN)
    end
  end

  def run_from_fire
    return if @health_history.empty? || @warrior.health >= @health_history.last
    DIRS.each {|d| @actions.emphasize(:walk!, d, RUN)}
  end

  def rest_when_low_health
    @actions.emphasize(:rest!, :here, REST) if @warrior.health < @max_health
  end

  # Layer 1: valid
  def skip_invalid
    skip_invalid_moves
    skip_invalid_attacks
    skip_invalid_rescues
    skip_invalid_binds
    skip_invalid_rest
  end

  def skip_invalid_moves
    DIRS.each {|dir| @actions.drop(:walk!, dir) unless @warrior.feel(dir).empty?}
  end

  def skip_invalid_attacks
    DIRS.each {|dir| @actions.drop(:attack!, dir) unless hostile_space?(@warrior.feel(dir))}
  end
  def skip_invalid_binds
    DIRS.each {|dir| @actions.drop(:bind!, dir) unless hostile_space?(@warrior.feel(dir))}
  end

  def skip_invalid_rescues
    DIRS.each {|dir| @actions.drop(:rescue!, dir) unless @warrior.feel(dir).captive?}
  end

  def skip_invalid_rest
    @actions.drop(:rest!, :here) if @warrior.health == @max_health
  end

  def hostile_space?(space)
    !space.empty? && !space.captive? && !space.stairs? && !space.wall?
  end

  # Layer 0: random
  def pick_best_option
    action, dir = @actions.pick
    action == :rest! ?
      @warrior.send(action) :
      @warrior.send(action, dir)
  end
end
