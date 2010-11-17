require 'fiber'
require 'fiber_prolog/engine'
require 'fiber_prolog/lang'

module FiberProlog
  def self.run(&block)
    Lang.instance_eval &block
    Engine.main_goal.new.call
  end
end

