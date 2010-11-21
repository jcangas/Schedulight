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
          @body = [@native]
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
        @sf = Environment.new_sf(self)

        self.class.vars.each {|n| self.vars << Var.new(n)}
        @args = args.clone
        @can_retry = true
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
        trace :calls, "CALL #{self} ip:#{ip}"
        push_sf
        trace :calls, "pushed_frame #{Environment.top}"
        #backtrack_vars
        ok = @fiber.resume
        @can_retry = @fiber.alive?
        trace :calls, "#{self} --> #{ok} ip:#{ip} r:#{@can_retry} f:#{!@fiber.nil?}"
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
        @args = Environment.solve_syms(@args)
      end

    protected

      def trace(channel, *msg)
        Environment.trace(channel, *msg)
      end

      def push_sf
        Environment.push_sf(@sf)
      end

      def pop_sf
        Environment.pop_sf
      end

      def reset_ip(val = 0)
        @sf[:ip] = val
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
      end

      def at_cut?
        body[ip].is_a?(Cut)
      end

      def callable?
        result = (@fiber ? @can_retry && @fiber.alive? : true)
        trace(:backtrack, "#{name}.callable? --> #{result} ip: #{ip} r:#{@can_retry} f:#{!@fiber.nil?}") unless result
        result
      end

      def backtrack_vars
        trace(:backtrack, "#{name}.backtrack_vars for #{ip}")
        self.vars.each{|v| v.backtrack!(ip)}
      end

      def restart
        #body.each{|r| r.restart}
        done
        @can_retry = true
      end

      def backtrack_one
        trace(:backtrack, "#{body[ip].name} backtrack done")
        body[ip].restart
        dec_ip
      end

      def can_retry?
        backtrack_one while ip >= 0 if at_cut?
        result = (ip >= 0) && body[ip].callable?
        trace(:backtrack, "#{name}.can_retry? #{body[ip].name} --> #{result}") unless result
        result
      end

      def find_backtrack
        trace(:backtrack, "#{name}.find_backtrack")
        backtrack_one until ip < 0 || can_retry?
        ip >= 0
      end

      def backtrack
        trace(:backtrack, "#{name}.backtrack")
        save_ip = ip
        reset_ip(body.size - 1)
        backtrack_one while ip >= save_ip
        if find_backtrack
          true
        else
          reset_ip
          fails
        end
      end

      def chain_forward
        mark_vars
        inc_ip
        if ip == body.size
          dec_ip
          suspend
        end
      end

      def execute
        if native?
          result = self.class.native.call(self)
          mark_vars if result
          result
        else
          ok = true
          while ok do
            if body[ip].callable? && body[ip].call
              chain_forward
            else
              ok = backtrack
            end
          end
          exit if self.class.name == "Goal"
          false
        end
      end

      def mark_vars
        vars.each_index {|i| vars[i].mark_ip!(ip)}
      end

      def start
        #reset_ip
        @can_retry = true
        return if @fiber
        @fiber = Fiber.new do
          execute
        end
      end
    end
  end
end

