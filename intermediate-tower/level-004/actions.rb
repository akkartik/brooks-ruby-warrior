class Actions
  attr_accessor :options

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

  def accentuate(action, dir)
    @options[action][dir] += 1
  end

  private

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
