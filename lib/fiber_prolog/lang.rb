require 'fiber_prolog/lang/var'
require 'fiber_prolog/lang/rule'
require 'fiber_prolog/lang/lang'

# Basic Library
FiberProlog::Lang.instance_eval do

    cut.native! { |r| true }

    fails.native! { |r|  r.fails }

    equ(:X, :Y).native! {|r| r[:X] == r[:Y] }

    write(:S).native! do |r|
      case r[:S].value
        when Array
          ruby_val = r[:S].value.map {|x| x.value}
        else
          ruby_val = r[:S].value
      end
      STDOUT.print "#{ruby_val}"
      true
    end

    newln.native! { |r| STDOUT.puts ""; true }

    writeln(:S).if write(:S), newln
    write_stack(:S).native! { |r| FiberProlog::Environment.write_stack(r[:S].value); true}

    genN(:N, :K).native! { |r| (1..r[:N].value).each {|n|
          r[:K] == n
          r.suspend
        }
        r.fails
    }

    collect(:V, :P, :R).native! { |r|
      b = r[:V].bindings
      results = []
      while r[:P].value.call do
        results << r[:V].value
        r[:V].unbind!
        b.each{|v| v.unbind!; r[:V].bind_to(v)}
      end
      r[:R] == results
      true
    }
end

