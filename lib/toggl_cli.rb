require 'togglv8'
require 'json'
require 'yaml'
require 'date'

class TogglCLI
  def initialize
    @config       = YAML.load_file(File.join(Dir.home, '.toggl_cli.yml'))
    @toggl_api    = TogglV8::API.new(@config['api_key'])
    @user         = @toggl_api.me(all=true)
    @workspaces   = @toggl_api.my_workspaces(@user)
    @workspace_id = @workspaces.first['id']
  end

  def start(project, description)
    pid = ""
    if @config['projects'][project]
      pid = @config['projects'][project]
    end
    time_entry  = @toggl_api.start_time_entry({
      'pid' => pid,
      'description' => "#{description}",
      'wid' => @workspace_id,
      'start' => @toggl_api.iso8601((Time.now).to_datetime),
      'created_with' => "toggl_cli"
    })
  end

  def stop
    current = @toggl_api.get_current_time_entry
    if current
      result = @toggl_api.stop_time_entry(current['id'])
    end
  end

  def today
    dates = {
      start_date: Time.parse(Date.today.to_s).to_s,
      end_date: Time.now.to_s
    }
    total = 0
    result = @toggl_api.get_time_entries(dates)
    result.each do |r|
      total = total + r['duration']
    end
    (total / 60.0).round(2)
  end
end
