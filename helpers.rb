helpers do

  def thread_cpu_time_s
    # THREAD_CPUTIME is not supported on OS X
    if Process.const_defined?(:CLOCK_THREAD_CPUTIME_ID)
      cpu_time = Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID, :millisecond)
    else
      cpu_time = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID, :millisecond)
    end

    cpu_time / 1000
  end

end
