ACTIONS = [:rest!, :walk!, :bind!, :attack!, :rescue!]
DIRS = [:left, :right, :forward, :backward]

class Actions
  attr_accessor :options
  ARGS = [:here, :left, :right, :forward, :backward]

  def initialize
    @options = {
      :rest! => {:here => 1},
      :walk! => {:left => 1, :right => 1, :forward => 1, :backward => 1},
      :bind! => {:left => 1, :right => 1, :forward => 1, :backward => 1},
      :attack! => {:left => 1, :right => 1, :forward => 1, :backward => 1},
      :rescue! => {:left => 1, :right => 1, :forward => 1, :backward => 1},
    }
  end

  def intersect(action)
    new_options = {}
    action.options.each do |a, o|
      new_options[a] = intersect_row @options[a], o
    end
    @options = new_options.reject{|k, v| v.nil? || v.empty?}
  end

  def drop(action, dir=nil)
    return drop_all(action) if action.is_a?(Array)
    @options[action][dir] = 0
  end

  def drop_all(actions)
    actions.each do |action, dir|
      @options[action][dir] = 0
    end
  end

  def accentuate(action, dir, num=1)
    @options[action][dir] += num
  end

  def pick
    max_score = max
    cands = select(max_score)
    pick_among(cands)
  end

  def max
    ans = 0
    each {|a, d| ans = @options[a][d] if @options[a][d] > ans}
    ans
  end

  def select(max_score)
    ans = []
    each {|a, d| ans << [a, d] if @options[a][d] == max_score}
    ans
  end

  def pick_among(cands)
    cands[rand(cands.length)]
  end

  def show_all_options
    each {|a, d| puts "#{a} #{d}" if @options[a][d] > 0 rescue nil}
  end

  def show_options(action)
    ARGS.each do |d|
      puts d if @options[action][d] > 0 rescue nil
    end
  end

  private

  def each
    ACTIONS.each do |a|
      ARGS.each do |d|
        next if @options[a][d].nil?
        yield a, d
      end
    end
  end

  def intersect_row(a, b)
    ans = {}
    a.each do |k, v|
      ans[k] = combine(a[k], b[k])
    end
    ans
  end

  def combine(a, b)
    return 0 if a == 0 || b == 0
    [a, b].max
  end
end
