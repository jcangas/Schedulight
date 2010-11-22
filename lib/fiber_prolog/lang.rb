require 'fiber_prolog/lang/var'
require 'fiber_prolog/lang/rule'
require 'fiber_prolog/lang/lang'

# Basic Library
FiberProlog::Lang.instance_eval do

    cut.native! { |r| true }

    fails.native! { |r|  r.fails }

    equ(:X, :Y).native! {|r| r[:X].unify r[:Y] }

    write(:T).native! do |r|
      case r[:T].value
        when Array
          ruby_val = r[:T].value.map {|x| x.value}
        else
          ruby_val = r[:T].value
      end
      STDOUT.print "#{ruby_val}"
      true
    end

    newln.native! { |r| STDOUT.puts ""; true }

    writeln(:S).if write(:S), newln
    write_stack(:S).native! { |r| FiberProlog::Environment.write_stack(r[:S].value); true}

    genN(:N, :K).native! { |r| (1..r[:N].value).each {|n|
          r[:K].unify(n)
          r.suspend
        }
        r.fails
    }

    collect(:V, :P, :R).native! { |r|
      b = r[:V].bindings
      results = []
      while r[:P].value.call do
        results << r[:V].value
        r[:V].value = nil
      end
      r[:R].unify results
      r[:P].value.restart
      true
    }
end

