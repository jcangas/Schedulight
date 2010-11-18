require 'fiber'
require 'fiber_prolog/environment'
require 'fiber_prolog/lang'

# At this moment FiberProlos is a very limited Prolog
# Anyway we only need the chain-forward / bactrack mechanics
# and this seems working very well in general.
# I have and issue for reeval passed variables binded inter-clauses
# I know the cause and I'm working in a solution

# The Rule class is a bit messy: is very tricky the fine control
# needed to be aware if a Fiber is alive, or need be killed etc.
# So at this moment I need firs all works ok and then clean the code a bit

# The general design is
# Var: capture the idea of a Prolog var.
# + Have a value (for us a ruby value)
# + Can be "unified" with other Vars
# + Hold the state of data when a Rule is waiting for be called

# Rule: capture a simple Prolog rule
# + Has subrules or a native implementation
# + Provides a simple API for develop native rules: suspend, access to Rule Vars, etc
# + Manage their execution state: fiber, backtrack, etc

# Environment: mantain the current path of execution
# Bsically a stack of stack-frames for the current chained rules.
# Also knows the main goal, and the manages global trace stuff

# Lang: A module that provides a simple Prolog like DSL



module FiberProlog
  def self.run(&block)
    Lang.instance_eval &block
    Environment.main_goal.new.call
  end
end

