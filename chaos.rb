require 'json'
require 'sinatra'
require "sinatra/json"
require "sinatra/reloader" if development?

require './helpers'

use Rack::Session::Pool, :expire_after => 2592000
use Rack::Protection::RemoteToken
use Rack::Protection::SessionHijacking

# leak_mem will retain the specified amount of memory and sleep.
# On `duration_s`, the memory will be released.
get '/leak_mem' do
  session['leak_mem'] ||= []
  start_time = Time.now

  memory_mb = (params['memory_mb'] || 512).to_i
  duration_s = (params['duration_s'] || 60).to_i

  t = Thread.new do
    # Improve this to allocate memory as the time goes by
    retainer = []
    # Add `n` 1mb chunks of memory to the retainer array
    memory_mb.times { retainer << "x" * 1048576 }

    duration_left = [start_time + duration_s - Time.now, 0].max
    Kernel.sleep(duration_left)
  end

  session['leak_mem'] << t

  json({code: response.status,
        message: "Leaking #{memory_mb}Mb for #{duration_s}s ..."})
end

get '/cpu_spin' do
  session['cpu_spin'] ||= []
  duration_s = (params['duration_s'] || 60).to_i

  t = Thread.new do
    return unless thread_cpu_time_s

    expected_end_time = thread_cpu_time_s + duration_s
    while thread_cpu_time_s < expected_end_time
      # TODO: Add thread information
      logger.info(rand)
    end
  end

  session['cpu_spin'] << t

  json({code: response.status,
        message: "Spinning CPU for #{duration_s}s ..."})
end

get '/sleep' do
  duration_s = (params['duration_s'] || 30).to_i

  Kernel.sleep(duration_s)

  json({code: response.status,
        message: "ZzZZZzzZZzzZ for #{duration_s}s"})
end

get '/kill' do
  logger.error "No Bacon Left!"
  Process.kill("KILL", Process.pid)

  json({code: response.status, message: 'No Bacon Left!'})
end

get '/disk_io' do
  fsize_mb = (params['fsize_mb'] || 100).to_i
  num_threads = (params['num_threads'] || 1).to_i

  num_threads.times do
    t = Thread.new do
      f = File.new("/tmp/foo#{rand}", 'w')
      fsize_mb.times { f << "x" * 1048576 }
      f.close
    end
  end

  json({code: response.status,
        message: "Creating #{num_threads} file(s) of #{fsize_mb}MB ..."})
end

get '/frank-says' do
  json({code: 200, message: 'Put this in your pipe & smoke it!'})
end

get '/' do
  headers({try_here: 'good! \o/'})
  # Add information to the `Response Header`, we can "hide" tips here
  json({code: response.status, message: ''})
  #[200, {try_here: 'good! \o/'}, '']
end

# Uncomment to display nice stack traces and additional debugging information
error 400..510 do |e|
  json({code: response.status, message: 'Boom!'})
end
