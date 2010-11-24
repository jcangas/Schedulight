require 'schedulight/models'

module Schedulight
  class DSL
    def load(file_name)
      source = File.read(file_name)
      instance_eval(source)
    end

    def hours_per_day(hrs)
      (1..hrs).each{ |h| TimeMark.new(h)}
    end

    def subjects(*subjs)
      subjs.each{ |s| Subject.new(s)}
    end

    def teacher(id, &block)
      Teacher.new(id, &block)
    end

    def classroom(id, &block)
      Classroom.new(id, &block)
    end

    def grade(id, &block)
      Grade.new(id, &block)
    end
  end
end

