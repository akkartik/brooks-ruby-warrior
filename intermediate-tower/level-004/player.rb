require 'set'

require 'coord'
require 'actions'

class Player
  # Layers
  AVOID = 5
  REST = 4
  UNBIND = 3
  PLAN = 2

  def process_layers
    unbind_captives
    manage_hostiles
    run_from_fire
    rest_when_low_health
    skip_invalid
  end

  def unbind_captives
    DIRS.each {|d| @actions.emphasize(:rescue!, d, UNBIND) if captive?(@warrior.feel(d))}
  end

  def manage_hostiles
    num_hostiles = DIRS.inject(0) {|sum, d| hostile_space?(@warrior.feel(d)) ? sum+1 : sum}
    case num_hostiles
    when 1
      DIRS.each {|d| @actions.emphasize(:attack!, d, PLAN) if hostile_space?(@warrior.feel(d))}
    when 0
      @actions.emphasize(:walk!, towards_next_goal, PLAN)
    else
      DIRS.each {|d| return @actions.emphasize(:bind!, d, PLAN) if hostile_space?(@warrior.feel(d))}
    end
  end

  def towards_next_goal
    @warrior.direction_of(@warrior.listen.first)
  rescue
    @warrior.direction_of_stairs
  end

  def run_from_fire
    return if @health_history.empty?

    health_bound = @action_history.last[0] == :rest! ? @health_history.last : @health_history.last-3
    return if @warrior.health >= health_bound

    DIRS.each {|d| @actions.emphasize(:walk!, d, AVOID)}
  end

  def rest_when_low_health
    return if @warrior.health >= @max_health
    return if @action_history.empty?
    return if @warrior.health > @max_health/4 && @action_history.last[0] != :rest!
    @actions.emphasize(:rest!, :here, REST)
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
    !space.empty? && !space.captive? && !space.stairs? && !space.wall? && @hostile_captives.add(space.location)
  end

  def captive?(space)
    space.captive? && !@hostile_captives.include?(space.location)
  end

  def play_turn(warrior)
    preprocess warrior
    process_layers
    pick_best_option
    postprocess
  end

  def initialize
    @health_history = []
    @action_history = []
    @hostile_captives = Set.new
  end

  def preprocess(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health
    @actions = Actions.new
  end

  def postprocess
    @health_history << @warrior.health
  end

  def pick_best_option
    action, dir = @actions.pick
    @action_history << [action, dir]
    puts "Decision from level #{@actions.options[action][dir]-1}"
    action == :rest! ?
      @warrior.send(action) :
      @warrior.send(action, dir)
  end
end
