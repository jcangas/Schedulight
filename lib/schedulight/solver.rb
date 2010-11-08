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
  class Solver
    def solve
      # don't work this way: at this moment is only a "mind mark"
      # I think somethng like Fibers is needed here:
      # We need generate all tm and cr, but only retry sbj and tch if no solution found
      # do you agree on that plan?
      TimeMark.all.each do |tm|
        Classroom.all.each do |cr|

          subjects_for(cr).each do |sbj|
            teachers_for(sbj).each do |tch|
              Tuple.new(tm, cr, sbj, tch)
            end
          end
        end
      end
    end

    def satisfy?
    end
  end
end

