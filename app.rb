require 'togglv8'
require 'json'
require 'yaml'

@config      = YAML.load_file('config.yml')
toggl_api    = TogglV8::API.new(@config['api_key'])
user         = toggl_api.me(all=true)
workspaces   = toggl_api.my_workspaces(user)
workspace_id = workspaces.first['id']

if ARGV[0] == "start"
  project = ARGV[1]
  pid = ""
  if @config['projects'][project]
    pid = @config['projects'][project]
  end
  description = ARGV[2]
  time_entry  = toggl_api.start_time_entry({
    'pid' => pid,
    'description' => "#{description}",
    'wid' => workspace_id,
    'start' => toggl_api.iso8601((Time.now).to_datetime),
    'created_with' => "toggl_cli"
  })
  puts time_entry
end

if ARGV[0] == "stop"
  current = toggl_api.get_current_time_entry
  if current
    puts toggl_api.stop_time_entry(current['id'])
  end
end
