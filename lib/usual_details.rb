class UsualDetails
  
  DEFAULT_TIMINGS = [
    ["11:00", "12:00"], 
    ["11:15", "12:15"], 
    ["12:30", "13:30"], 
    ["12:45", "14:00"], 
    ["13:00", "14:00"], 
    ["14:00", "15:00"], 
    ["15:00", "16:00"],
    ["16:30", "17:30"], 
    ["17:00", "18:00"], 
  ]
  
  attr_reader :list, :venues, :timings
  
  def initialize( list, sample_size = 10 )
    @venues, @timings, @list = [], [], list
    Talk.find(:all, :conditions => ['series_id = ?',@list.id], :limit => sample_size, :order => "updated_at DESC").each do |talk|
      @venues << talk.venue
      @timings << talk.time_slot
    end
    @venues.uniq!
    @timings.uniq!
    @timings = DEFAULT_TIMINGS if @timings.empty?
  end
  
  def default_talk
    Talk.new do |t|
      if timings.first
       t.set_time_slot( [ Time.now.year, Time.now.month, Time.now.day ].join('/'), timings.first[0], timings.first[1] )
      else
        t.start_time = Time.now
        t.end_time = Time.now
      end
      t.venue = @venues.first
      t.series = @list
      t.organiser = User.current
    end
  end
end