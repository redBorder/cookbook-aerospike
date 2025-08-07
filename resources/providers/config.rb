# Cookbook:: aerospike
# Provider:: config

action :add do
  begin
    user = new_resource.user
    ipaddress_sync = new_resource.ipaddress_sync
    managers_per_service = new_resource.managers_per_service

    dnf_package 'aerospike-server-community' do
      action :upgrade
    end

    template '/etc/aerospike/aerospike.conf' do
      cookbook 'aerospike'
      source 'aerospike.conf.erb'
      owner user
      group user
      mode '0644'
      retries 2
      notifies :restart, 'service[aerospike]'
      variables(
        ipsync: ipaddress_sync,
        managers: managers_per_service["aerospike"],
      )
    end

    template '/var/www/rb-rails/config/aerospike.yml' do
      cookbook 'aerospike'
      source 'rb-rails_aerospike.yml.erb'
      owner user
      group user
      mode '0644'
      retries 2
      notifies :restart, 'service[webui]'
      notifies :restart, 'service[logstash]'
      variables(
        managers: managers_per_service["aerospike"]
      )
    end

    # template '/var/rb-sequence-oozie/conf/aerospike.yml' do
    #   cookbook 'aerospike'
    #   source 'rb-sequence-oozie_aerospike.yml.erb'
    #   owner user
    #   group user
    #   mode '0644'
    #   retries 2
    #   notifies :restart, 'service[rb-sequence-oozie]'
    #   variables(
    #     managers: managers_per_service["aerospike"]
    #   )
    # end

    service 'aerospike' do
      service_name 'aerospike'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:start, :enable]
    end

    Chef::Log.info('Aerospike cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'aerospike' do
      service_name 'aerospike'
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    dnf_package 'aerospike-server' do
      action :remove
    end

    Chef::Log.info('Aerospike cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    ipaddress = new_resource.ipaddress

    unless node['aerospike']['registered']
      query = {}
      query['ID'] = "aerospike-#{node['hostname']}"
      query['Name'] = 'aerospike'
      query['Address'] = ipaddress
      query['Port'] = 5000
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['aerospike']['registered'] = true
      Chef::Log.info('aerospike service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['aerospike']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/aerospike-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['aerospike']['registered'] = false
      Chef::Log.info('aerospike service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end