require 'redis-store/testing/runners'

class RedisReplicationRunner
  def self.runners
    [ RedisRunner, NodeOneRedisRunner, NodeTwoRedisRunner ]
  end

  def initialize(dir)
    @dir = dir
  end

  def start
    runners.each do |runner|
      runner.start
    end
  end

  def stop
    runners.each do |runner|
      runner.stop
    end
  end

  protected
  def runners
    @runners ||= begin
      self.class.runners.map do |runner|
        runner.new(@dir)
      end
    end
  end
end
