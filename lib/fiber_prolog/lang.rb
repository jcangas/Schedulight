require 'fiber_prolog/lang/var'
require 'fiber_prolog/lang/rule'
require 'fiber_prolog/lang/lang'

# Basic Library
FiberProlog::Lang.instance_eval do

    cut.native! { |r| true }

    fails.native! { |r|  r.fails }

    write(:S).native! { |r| STDOUT.print "#{r[:S].value}"; true }

    newln.native! { |r| STDOUT.puts ""; true }

    writeln(:X).if write(:X), newln, cut

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

