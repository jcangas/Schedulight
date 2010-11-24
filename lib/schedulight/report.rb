
# Class for nice reporting of a solutions
# My plan is buiild some simple text report: text or a very basic html file
module Schedulight
  class Report
    def publish(schedule)
      group_by_classroom(schedule).each_pair {|cr, sch|
        puts ""
        puts "----------------------------------"
        puts "| -- Schedule for class #{cr.id} --     |"
        puts "|------|------------|------------|"
        puts "| Time |  Subject   | Teacher    |"
        puts "|------|------------|------------|"
        sch.each {|slice|
          puts "| %4d | %10s | %10s |" % [slice[:time_mark].id, slice[:subject].id, slice[:teacher].id]
          puts "|------|------------|------------|"
        }
      }
      puts ""
    end

    def group_by_classroom(schedule)
      schedule.group_by{|slice| slice[:classroom]}

    end
  end
end

