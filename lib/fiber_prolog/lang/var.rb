
# These core ext are not in self file because I have plans to don't need it

class Object
  def bound?
    true
  end

  def value
    self
  end
end

module FiberProlog

  module  Lang
    class Var
      attr_reader :name
      attr_reader :value
      attr_reader :bindings
      attr_reader :ip
      attr_accessor :init_bounded

      def initialize(name, rule=nil)
        @name = name
        @bindings = []
        @ip = nil
        @rule = rule
        @init_bounded = false
      end

      def to_s
        v = value || '?'
        bo = self.bound? ? '+' : '-'
        i = "#{bo}(#{@init_bounded} | #{@ip})"
        i = nil unless Environment.trace?(:vars)
        bi = @bindings.map{|v| "#{v.name}"}
        bi = nil if bi.empty? || !Environment.trace?(:binds)
        Environment.trace?(:binds) ? "#{name}#{i}#{bi} = #{v}" : "#{name}#{i} = #{v}"
      end

      def backtrack!(at_ip)
        return if self.ip != at_ip
        trace :set_var, "#{name} cleared for #{ip}"
        @ip = nil
        #@value = nil
        @init_bounded = false
      end

      def mark_ip!(at_ip)
        @ip = at_ip if !@ip && @value
      end

      def unbind!
        Environment.trace :set_var, "unbind! #{self}"
        @bindings.each {|b| b.remove_binding(self)}
        @bindings = []
        @init_bounded = false
      end

      def value
        @value
      end

      def value=(other)
        if other.is_a?(Var)
          bind_to(other)
          new_value = other.value
          new_value = other.value.map{|x| x.clone rescue x} if new_value.is_a?(Array)
        else
          new_value = other
        end
        trace :set_var, "set #{name} = #{new_value} <#{other}>"
        update!(new_value, other.is_a?(Var) ? other : nil)
        self
      end

      def binded_to?(target)
        bindings.map{|x| x.object_id}.include?(target.object_id)
      end

      def bind_to(target)
        return if binded_to?(target)
        add_binding(target)
        target.bind_to(self)
      end

      def add_binding(target)
        @bindings << target
      end

      def remove_binding(target)
        @bindings.delete(target)
      end

      def trace(channel, msg)
        Environment.trace channel, msg
      end

      def update!(new_value, updated_by)
        return if @value == new_value
        trace :set_var, "update! #{name} = #{new_value} <#{updated_by}>"
        @value = new_value
        @value.init_args if value.is_a?(Rule) #FIXME: I think can be moved to Environment.solve_syms

        update_bindings
      end

      def update_bindings
        @bindings.each {|b| b.update!(@value, self)}
      end

      def free?
        @value.nil?
      end

      def bound?
       (@init_bounded && !self.free?) || !@ip.nil? && ((@rule.ip > @ip))
      end

      def unify(other)
        ok = true
        if bound? && other.bound?
            ok = self.value == other.value
        elsif !other.bound?
            other.value = self
        else
          self.value = other
        end
        ok
      end

    end
  end
end

