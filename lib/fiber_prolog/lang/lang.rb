module FiberProlog

  module Lang

    def self.goal
      Environment.main_goal ||= define_rule(:goal)
    end

    def self.trace!(v)
      Environment.trace!(v)
    end

    def self.trace?(chn)
      Environment.trace?(chn)
    end

    def self.method_missing(name, *args)
      rule_class = self.define_rule(name, args)
      define_singleton_method name do |*actual_args|
        rule_class.new(*actual_args)
      end
      rule_class
    end

    def self.define_rule(name, formal_args=[])
      kname = name.to_s.dup
      kname[0] = kname[0].capitalize
      unless const_defined?(kname)
        rule_class = Class.new(Rule)
        const_set(kname, rule_class)
        rule_class.vars = formal_args
      end
      const_get(kname)
    end

  end

end

