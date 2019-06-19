require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'pathname'
require 'open-uri'
require 'redis-store/testing/redis_replication_runner'
require 'date'

class RedisStoreTesting
  include Rake::DSL

  def self.install_tasks(options = {})
    new(options[:dir]).install
  end

  def initialize(dir = nil)
    @dir    = Pathname.new(dir ||= Dir.pwd).realpath
    @runner = RedisReplicationRunner.new(@dir)
  end

  def install
    namespace :redis do
      redis_about
      redis_install
      redis_make
      redis_download

      namespace :test do
        redis_test_suite
        redis_test_run
        redis_test_prepare
      end

      namespace :replication do
        redis_replication_start
        redis_replication_stop
        redis_replication_console
      end
    end

    changelog

    run_tests_locally

    task default: 'redis:test:suite'
  end

  protected

  def changelog
    task :changelog, :from, :to do |_t, args|
      from = args[:from] || `git describe --tags --abbrev=0`.strip
      to = args[:to] || 'HEAD'
      log = `git log #{from}..#{to} --pretty=format:'%an|%B___'`

      puts "#{project_title} (#{Date.today})"
      puts '-' * 80
      puts

      log.split(/___/).each do |commit|
        pieces = commit.split('|').reverse
        author = pieces.pop.strip
        message = pieces.join.strip

        next if message =~ /^\s*Merge pull request/
        next if message =~ /No changelog/

        ticket = message.scan(/SEGMENTS-\d+/)[0]
        next if ticket.nil?
        next if message =~ /^\s*Merge branch/ && ticket.nil?

        first_line = false

        message.each_line do |line|
          if !first_line
            first_line = true
            puts "*   #{line}"
          elsif line.strip.empty?
            puts
          else
            puts "    #{line}"
          end
        end

        puts "    #{author}"
        puts
      end
    end
  end

  def run_tests_locally
    desc 'Run tests for all supported dependency versions'
    task :test do
      Rake::Task['redis:test:suite'].invoke if appraisal_gemfiles.empty?

      appraisal_gemfiles.each do |gemfile|
        sh "BUNDLE_GEMFILE=#{gemfile} bundle exec rake"
      end
    end
  end

  def redis_about
    desc 'About redis'
    task :about do
      puts "\nSee http://redis.io for information about Redis.\n\n"
    end
  end

  def redis_install
    desc 'Install the lastest verison of Redis from Github (requires git, duh)'
    task install: [ :about, :download, :make ] do
      %w(redis-benchmark redis-cli redis-server).each do |bin|
        if File.exist?(path = "#{@runner.redisdir}/src/#{bin}")
          sh "sudo cp #{path} /usr/bin/"
        else
          sh "sudo cp #{@runner.redisdir}/#{bin} /usr/bin/"
        end
      end

      puts "Installed redis-benchmark, redis-cli and redis-server to /usr/bin/"

      sh "sudo cp #{@runner.redisdir}/redis.conf /etc/"
      puts "Installed redis.conf to /etc/ \n You should look at this file!"
    end
  end

  def redis_make
    task :make do
      sh "cd #{@runner.redisdir} && make clean"
      sh "cd #{@runner.redisdir} && make"
    end
  end

  def redis_download
    desc "Download package"
    task :download do
      require 'git'

      sh "rm -rf #{@runner.redisdir} && mkdir -p vendor && rm -rf redis"
      Git.clone("git://github.com/antirez/redis.git", "redis")
      sh "mv redis vendor"

      commit = case ENV['VERSION']
               when "1.3.12"  then "26ef09a83526e5099bce"
               when "2.2.12"  then "5960ac9dec5184bf4184"
               when "2.2.4"   then "2b886275e9756bb8619a"
               when "2.0.5"   then "9b695bb0a00c01ad4d55"
               end

      arguments = commit.nil? ? "pull origin master" : "reset --hard #{commit}"
      sh "cd #{@runner.redisdir} && git #{arguments}"
    end
  end

  def redis_test_suite
    desc 'Run all the examples by starting a background Redis instance'
    task suite: 'redis:test:prepare' do
      invoke_with_redis_replication 'redis:test:run'
    end
  end

  def redis_test_run
    Rake::TestTask.new(:run) do |t|
      t.libs.push 'lib'
      t.test_files = FileList['test/**/*_test.rb']
      t.ruby_opts  = ["-I test"]
      t.verbose    = true
    end
  end

  def redis_test_prepare
    task :prepare do
      FileUtils.mkdir_p @dir.join('tmp/pids')
      FileUtils.rm Dir.glob(@dir.join('tmp/*.rdb'))
    end
  end

  def redis_replication_start
    desc "Starts redis replication servers"
    task :start do
      @runner.start
    end
  end

  def redis_replication_stop
    desc "Stops redis replication servers"
    task :stop do
      @runner.stop
    end
  end

  def redis_replication_console
    desc "Open an IRb session with the master/slave replication"
    task :console do
      @runner.start
      system "bundle exec irb -I lib -I extra -r redis-store.rb"
      @runner.stop
    end
  end

  private

  def invoke_with_redis_replication(task_name)
    begin
      Rake::Task['redis:replication:start'].invoke
      Rake::Task[task_name].invoke
    ensure
      Rake::Task['redis:replication:stop'].invoke
    end
  end

  def appraisal_gemfiles
    Dir["./gemfiles/*.gemfile"].reject { |p| p =~ /\.lock\Z/ }
  end

  def project_title
  end
end

RedisStoreTesting.install_tasks
