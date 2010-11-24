require 'schedulight/models'

# to search solutions we use structs to build "tuples"
# for each (time_mark x classroom), like
#
# [a_time_mark, a_classroom, a_subject, a_teacher]
#
# and check if satisfy some criterias: workload, teachers, etc
# We name one tuple "Slice": it is the atomic entry on a schedule
# A valid schedule is computed as an array of slices

module Schedulight
  class Solver

    def solve?
      solve(init, [])
    end

  protected

    def time_marks
      TimeMark.all
    end

    def classrooms
      Classroom.all
    end

    def workload_for(classroom)
      Grade.find(classroom.grade).workload
    end

    def subjects_for(classroom)
      wkld = workload_for(classroom)
      Subject.findall(wkld.keys)
    end

    def teachers_for(subject)
      Teacher.all.select { |x| x.subjects.include?(subject.id) }
    end

    def init
      slices = []
      time_marks.each do |t|
        classrooms.each do |c|
          s = Slice.new(t, c)
          slices << s
        end
      end
      slices
    end

    def check_workload_for(cr, wk)
      valids = workload_for(cr)
      check = {}
      wk.each_pair {|subj, w| check[subj.id] = w}
      valids == check
    end

    def compute_workloads(solution)
      wkld = {}
      solution.each {|slice|
        cr = slice[:classroom]
        sbj = slice[:subject]
        wkld[cr] ||= {}
        wkld[cr][sbj] ||= 0
        wkld[cr][sbj] += 1
      }
      wkld
    end

    def is_valid?(solution)
      wkld = compute_workloads(solution)
      wkld.each_pair { |cr, wk|
        return false unless check_workload_for(cr, wk)
      }
      true
    end

    def solve(slices, solution)
      if slices.empty?
        ok = is_valid?(solution)
        result = ok ? solution : nil
      else
        # Extract an uncompleted slice
        remain_slices = slices.dup
        slice = remain_slices.shift

        # Try to complete the slice using all posibilities
        subjects_for(slice[:classroom]).each {|sbj|
          teachers_for(sbj).each {|tch|
            slice[:subject] = sbj
            slice[:teacher] = tch

            # Add the proposed slice to current partial solution
            new_solution = solution.dup << slice
            # Try to complete a solution for remaining slices
            result = solve(remain_slices, new_solution)
            # If have a solution we have done
            break if result
          }
          break if result
        }
      end
      result
    end

  end
end

