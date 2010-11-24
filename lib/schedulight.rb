
require 'schedulight/models'
require 'schedulight/dsl'
require 'schedulight/solver'
require 'schedulight/report'
require 'pathname'


module Schedulight
  class Main
    def run
      dsl = DSL.new

      dsl.load(Pathname(__FILE__).dirname.parent + 'examples' + 'sample_schedule.schlg' )

      solver = Solver.new

      report = Report.new

      puts "---Solving----"
      solution = solver.solve?
      if solution
        report.publish solution
      else
        puts "no solution found :("
      end
    end
  end
end

