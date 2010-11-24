
require 'schedulight/models'
require 'schedulight/dsl'
require 'schedulight/solver'
require 'schedulight/report'
require 'pathname'


module Schedulight
  class Application
    def run(file_name)
      dsl = DSL.new

      dsl.load(file_name)
      solver = Solver.new

      report = Report.new

      puts "Solving #{file_name}"
      puts "let me think a bit ..."
      solution = solver.solve?
      if solution
        report.publish solution
      else
        puts "no solution found :("
      end
    end
  end
end

