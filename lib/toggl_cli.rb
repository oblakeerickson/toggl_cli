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

  def start(client, project, description)
    cid = client(client)['id']
    pid = project(cid, project)['id']

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

  def today(client = nil, project = nil)
    pids = []
    if client
      cid = client(client)['id']
      presult = projects
      presult.each do |r|
        if r['cid'] == cid
          pids << r['id']
        end
      end
    end
    entries = []
    dates = {
      start_date: Time.parse(Date.today.to_s).to_s,
      end_date: Time.now.to_s
    }
    total = 0
    result = @toggl_api.get_time_entries(dates)
    result.each do |r|
      if (client && (pids.include? r['pid']))
        entries << "#{r['duration']} - #{r['description']}"
        total = total + r['duration']
      end
    end
    {entries: entries, total: (total / 60.0).round(2)}
  end

  def clients
    clients = []
    result = @toggl_api.my_clients
    result.each do |r|
      clients << "#{r['id']} #{r['name']}"
    end
    clients
  end
 
  def client(name)
    client = ""
    result = @toggl_api.my_clients
    result.each do |r|
      if r['name'].downcase == name
        client = r
      end
    end
    client
  end

  def projects(client_id = nil)
    projects = []
    result = @toggl_api.my_projects
    result.each do |r|
      if r['cid']
        projects << r
      end
    end
    projects
  end

  def project(client_id, name)
    project = ""
    result = @toggl_api.my_projects
    result.each do |r|
      if r['cid'] == client_id && r['name'].downcase == name
        project = r
      end
    end
    project
  end
end
