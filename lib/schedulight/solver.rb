# to found solutions we use hashes or structs to build tuples
# for each (time_slice x classroom), like
#
# [a_time_slice, a_classroom, a_subject, a_teacher]
#
#
# and check if satisfy criterias: workload, teachers, etc
#
# A solution is found if we get a tuple valid for each time_slice in each classrom
#

module Schedulight

  Tuple = Struct.new(:time_mark, :classrom, :subject, :teacher)

  class Solver_
    class Value
      def intialize(values)
        @values = [values].flatten
        @current = 0
      end

      def current
        @values[@current]
      end

      def next
        @current += 1
        @current < @values.size
      end
    end

    class SolutionSpace
      def add_tuple(tm, cr)
        tm_val = Value.new(tm)
        cr_val = Value.new(cr)
        sbj_val = Value.new(subjects_for(cr_val.current))
        tch_val = Value.new(teachers_for(sbj_val.current)
        @tuples ||= []
        @tuples << Tuple.new(tm_val, cr_val, sbj_val, tch_val)
      end

      def subjects_for(classrom)
        Subject.find(classrom.grade).workload.keys
      end

      def teachers_for(sbj)
        Teacher.all.select { |x| x.subjects.include?(sbj) }
      end

      def first
      end

      def next
        @tuples[@current]
      end
    end

    def solve
      # don't work this way: at this moment is only a "mind mark"
      # I think somethng like Fibers is needed here:
      # We need generate all tm and cr, but only retry sbj and tch if no solution found
      # do you agree on that plan?
      solution_space = SolutionSpace.new

      TimeMark.all.each do |tm|
        Classroom.all.each do |cr|
          solution_space.add_tuple(tm, cr)
        end
      end

      solution_space.first
      while not solution_space.is_valid? do
        solution_space.next
      end

    end

    def satisfy?
    end

  end
end

