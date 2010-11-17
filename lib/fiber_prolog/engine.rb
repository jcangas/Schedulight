module FiberProlog

  module Engine

    def self.find_var(vname, new_var=true)
      sf = @sframes.last
      vars = sf[:vars]
      v = vars.select{|v| v.name == vname}.first
      if v
        result = v
      else
        result = new_var ? Lang::Var.new(vname) : vname
        vars << result if new_var
      end

      trace :vars, "find #{vname} for #{sf[:rule]} -> #{result}"
      show_stack(:find_stack) if trace?(:vars)
      result
    end

    def self.caller_val(v)
      v.is_a?(Symbol) ? find_var(v) : v
    end

    def self.new_sf(rule)
      @stack_frames ||= []
      {rule: rule, vars: [], ip: 0}
    end

    def self.push_sf(sf)
      @sframes ||= []
      r = sf[:rule]
      r.vars.each_index {|i| r.vars[i].value = caller_val(r.args[i])}
      @sframes.push sf
      show_stack(:push) if trace?(:stack)
    end

    def self.pop_sf
      vars = @sframes.last[:vars]
      vars.each_index {|i| vars[i].unbind!}
      @sframes.pop
      unless @sframes.empty?
        vars = @sframes.last[:vars]
        vars.each_index {|i| vars[i].mark_ip!(@sframes.last[:ip])}
      end
      show_stack(:pop) if trace?(:stack)
    end

    def self.show_stack(opration)
      puts "#{opration}: "
      puts @sframes.reverse.join("\n")
      puts "----------"
    end

    def self.trace!(v)
      @trace_on = v
    end

    def self.trace?(chn)
      @trace_on[chn] && @trace_on[:trace]
    end

    def self.trace(kind, *msg)
      puts *msg if trace?(kind)
    end
#-----------------------------
    class << self
      attr_accessor :main_goal
      attr_accessor :sframes
    end

  end
end

