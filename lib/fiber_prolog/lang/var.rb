
# These core ext are not in self file because I have plans to don't need it

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
        Environment.trace :set_var, "#{name} cleared for #{ip}"
        @ip = nil
        value = nil
      end

      def mark_ip!(at_ip)
        @ip = at_ip if !@ip && !free?
      end

      def to_s
        v = value || '?'
        i = @ip ? "*(#{@ip})" : ''
        b = @bindings.map{|v| "#{v.name}<#{v.object_id}>"}
        b = nil if b.empty?
        Environment.trace?(:vars) ? "#{name}<#{object_id}>#{i}#{b} = #{v}" : "#{name}#{i} = #{v}"
      end

      def unbind!
        @value = nil
        Environment.trace :set_var, "unbind! #{name}"
        return
        @bindings.each {|b| b.remove_binding(self)}
        @bindings = []
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
        if @value != new_value
          Environment.trace :set_var, "set #{name} = #{new_value}"
          @value = new_value
          value.init_args if value.is_a?(Rule) #FIXME: I think can be moved to Environment.solve_syms
          update_bindings
        end
        self
      end

      def binded_to?(target)
        # THIS line gets stack overflow!!
        #@bindings.include?(target)
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

      def update_bindings
          Environment.trace :set_var, "#{name} updates #{@bindings}"
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

