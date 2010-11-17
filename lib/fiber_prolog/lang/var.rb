class Object
  def free?
    false
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

      def initialize(name)
        @name = name
        @bindings = []
        @ip = nil
      end

      def backtrack!(at_ip)
        return if self.ip != at_ip
        @ip = nil
        @value = nil
      end

      def mark_ip!(at_ip)
        @ip = at_ip if !@ip && !free?
      end

      def to_s
        v = value || '?'
        i = @ip ? "*(#{@ip})" : ''
        b = @bindings.map{|v| "#{v.name}<#{v.object_id}>"}
        b = nil if b.empty?
        Engine.trace?(:vars) ? "#{name}<#{object_id}>#{i}#{b} = #{v}" : "#{name}#{i} = #{v}"

      end

      def unbind!
        @bindings.each {|b| b.remove_binding(self)}
        @bindings = []
        @value = nil
      end

      def value
        @value
      end

      def value=(other)
        Engine.trace :set_var, "set #{name} = #{other}"
        if other.is_a?(Var)
          bind_to(other)
          new_value = other.value
        else
          new_value = other
        end
        if @value != new_value
          @value = new_value
          value.init_args if value.is_a?(Rule)
          update_bindings
        end
        self
      end

      def binded_to?(target)
        @bindings.include? target
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

      def update_bindings
        @bindings.each {|b| b.value = value }
      end

      def free?
        @value.nil?
      end

      def ==(other)
        unify(other)
      end

      def unify(other)
        ok = nil
        if !free? && !other.free?
            ok = self.value == other.value
        elsif other.free?
            other.value = self
            ok = true
        else
          self.value = other
          ok = true
        end
        ok
      end

    end
  end
end

