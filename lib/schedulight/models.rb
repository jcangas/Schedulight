#
# Greg?: Ii is better split this in a file for each so easy model
# and strict follow the common convenion for organize files?
#

module Schedulight
  class Model
    attr_reader :id

    def initialize(id,  &block )
      @id = id
      self.instance_eval(&block) if block
      self.class.all << self
    end

    def self.all
      @all ||= []
      @all
    end
  end

  class TimeMark  < Model
  end

  class Subject  < Model
  end

  class Teacher < Model
    attr_reader :subjects
    def gives(*subjects)
      @subjects = subjects
    end
  end

  class Classroom < Model
    def grade(grd)
      return @grade if grd.nil?
      @grade = grd
    end
  end

  class Grade < Model
    def workload(&wl)
      return @workload if wl.nil?
      @workload = Workload.new
      @workload.instance_eval(&wl)
    end

  private # we don't want expose this "trick"
    class Workload < Hash
      def method_missing(name, *args)
        self[name] = args[0]
      end
    end
  end
end

