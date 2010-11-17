module FiberProlog

  module  Lang

    class Rule
      class << self
        attr_accessor :native
        attr_accessor :vars
        def vars
          @vars ||= []
        end

        def body
          @body ||= []
        end

        def native!(&impl)
          @native = (lambda &impl)
          self
        end

        def if(*rules)
          @body = rules
          self
        end
      end

      attr_reader :ip
      attr_reader :body
      attr_reader :args
      attr_reader :sf

      def initialize(*args)
        @body = self.class.body.clone
        #@body = self.class.body.map {|r| r.clone}
        @sf = Engine.new_sf(self)

        self.class.vars.each {|n| self.vars << Var.new(n)}
        @args = args.clone
      end

      def vars
        @sf[:vars]
      end

      def [](vname)
        find_var(vname)
      end

      def native?
        self.class.native
      end

      def name
        return @name if @name
        @name = self.class.name.split('::').last
        @name[0] = @name[0].downcase
        @name
      end

      def native
        self.class.native
      end

      def native?
        self.class.native
      end

      def ip
        @sf[:ip]
      end

      def to_s
        "#{name}(#{vars})"
      end

      def call
        start
        trace :calls, "CALL #{self}"
        push_sf
        ok = @fiber.resume
        trace :calls, "#{self} --> #{ok}"
        pop_sf
        ok
      end

      def suspend
        Fiber.yield true
      end

      def fails
        false
      end

      def init_args
        args.each_index do |k|
          @args[k] = (args[k].is_a?(Symbol) ? Engine.find_var(args[k], false) : args[k])
        end
      end

    protected

      def trace(channel, *msg)
        Engine.trace(channel, *msg)
      end

      def push_sf
        Engine.push_sf(@sf)
      end

      def pop_sf
        Engine.pop_sf
      end

      def reset_ip
        @sf[:ip] = 0
      end

      def inc_ip
        @sf[:ip] += 1
      end

      def dec_ip
        @sf[:ip] -= 1
      end

      def find_var(vname)
        var = vars.select{|v| v.name == vname}.first
        raise "var #{vname} not found for #{self}" unless var
        var
      end

      def done
        @fiber = nil
        true
      end

      def can_retry?
        #result = @fiber ? @fiber.alive? : false
        result = @fiber.nil? || @fiber.alive?
        done unless result
        trace(:backtrack, "#{self}.can_retry? --> #{result}")
        result
      end

      def at_cut?
        body[ip].is_a?(Cut)
      end

      def backtrack_fails?
        result = ip < 0 || at_cut?
        if at_cut?
          while ip >= 0 do
            backtrack_one
          end
        end
        result
      end

      def backtrack_vars
        self.vars.each{|v| v.backtrack!(ip)}
      end

      def backtrack_one
        trace(:backtrack, "backtrack #{ip}")
        body[ip].done
        backtrack_vars
        dec_ip
      end

      def backtrack
        backtrack_one until backtrack_fails? || body[ip].can_retry?
        if backtrack_fails?
          reset_ip
          fails
        else
          backtrack_vars
          true
        end
      end

      def chain_forward
        inc_ip
        if ip == body.size
          dec_ip
          suspend
        end
      end

      def callable?
        while !body[ip].can_retry? && ip >= 0 do
          backtrack_one
        end
        ip >= 0
      end

      def execute
        if native?
          self.class.native.call(self)
        else
          ok = true
          while ok do
            if body[ip].call
              chain_forward
            else
              ok = backtrack
            end
          end
          exit if self.is_a? Goal
        end
      end

      def start
        return if @fiber
        @fiber = Fiber.new do
          execute
        end
      end
    end
  end
end

