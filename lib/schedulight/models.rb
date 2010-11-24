#
# Greg?: Ii is better split this in a file for each so easy model
# and strict follow the common convenion for organize files?
#

module Schedulight

    Model = Struct.new('Model', :id) do

    def self.all
      @all ||= []
      @all
    end

    def to_s
       n = self.class.name.split('::').last
      "{#{n} id= #{id}}"
    end

    def inspect
      to_s
    end

    def initialize(id,  &block )
      self.id = id.to_s
      self.instance_eval(&block) if block
      self.class.all << self
    end

    def self.find(ids)
      result = findall(ids)
      result.size == 1 ? result.first : result
    end

    def self.findall(ids)
      keys = [ids].flatten
      all.select { |x| keys.include?(x.id) }
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
    def grade(grd=nil)
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
        self[name.to_s] = args[0]
      end
    end
  end
end

