module Aerospike
  module Helper
    def get_manager_ips(aerospike_managers)
      ips = aerospike_managers.map do |n|
        if n == '127.0.0.1'
          n
        else
          begin
            node_obj = Chef::Node.load(n)
            node_obj['ipaddress_sync'] ||
              node_obj['ipaddress'] ||
              node_obj.dig('automatic','ipaddress')
          rescue => e
            Chef::Log.warn("Could not load node #{n}: #{e.class}: #{e.message}")
            nil
          end
        end
      end

      ips = ips.compact.uniq.sort
      if ips.empty?
        Chef::Log.warn("Aerospike IP list is empty. Check node['redborder']['managers_per_services']['aerospike'].")
      end
      ips
    end
  end
end
