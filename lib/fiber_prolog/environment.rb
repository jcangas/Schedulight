module FiberProlog

  module Environment

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
      write_stack(:find_stack) if trace?(:vars, :stack)
      result
    end

    def self.solve_syms(a)
      case a
        when Symbol
          Environment.find_var(a)
        when Array
          a.map{|x| solve_syms(x)}
        else
          a
      end
    end

    def self.new_sf(rule)
      @stack_frames ||= []
      {rule: rule, vars: [], ip: 0}
    end

    def self.push_sf(sf)
      @sframes ||= []
      r = sf[:rule]
      r.vars.each_index {|i| r.vars[i] == solve_syms(r.args[i])}
      @sframes.push sf
      write_stack(:push) if trace?(:stack)
    end

    def self.pop_sf
      vars = @sframes.last[:vars]
      vars.each_index {|i| vars[i].unbind!}
      @sframes.pop
      unless @sframes.empty?
        vars = @sframes.last[:vars]
        vars.each_index {|i| vars[i].mark_ip!(@sframes.last[:ip])}
      end
      write_stack(:pop) if trace?(:stack)
    end

    def self.write_stack(opration)
      title =  "---------- #{opration} ----------------"
      puts title
      puts @sframes.reverse.join("\n")
      puts "-"*title.size
    end

    def self.trace!(v)
      @trace_on = v
    end

    def self.trace?(*chn)
      @trace_on[:trace] && chn.map{|opt| @trace_on[opt]}.all?
    end

    def self.trace(channel, *msg)
      puts *msg if trace?(channel)
    end
#-----------------------------
    class << self
      attr_accessor :main_goal
      attr_accessor :sframes
    end

  end
end

