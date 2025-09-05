# Cookbook:: aerospike
# Provider:: config

include Aerospike::Helper

action :add do
  begin
    user = new_resource.user
    ipaddress_sync = new_resource.ipaddress_sync
    aerospike_managers = new_resource.aerospike_managers

    dnf_package 'aerospike-server-community' do
      action :upgrade
    end

    service 'aerospike' do
      service_name 'aerospike'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action :nothing
    end

    directory '/var/log/aerospike' do
      owner user
      group user
      mode '0755'
    end

    file '/var/log/aerospike/aerospike.log' do
      owner user
      group user
      mode '0644'
      action :create_if_missing
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
        managers_ips: get_manager_ips(aerospike_managers)
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
    #     managers: aerospike_managers['aerospike']
    #   )
    # end

    service 'aerospike' do
      action [:enable, :start]
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

    directory '/etc/aerospike' do
      recursive true
      action :delete
    end

    directory '/var/log/aerospike' do
      recursive true
      action :delete
    end

    dnf_package 'aerospike-server-community' do
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
      query['Port'] = 3000
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.override['aerospike']['registered'] = true
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

      node.override['aerospike']['registered'] = false
      Chef::Log.info('aerospike service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
