module Aerospike
  module Helper
    def get_manager_ips(managers_per_service)
      ips = Array(managers_per_service).map do |n|
        node_obj =
          if n.is_a?(Hash)
            n
          else
            begin
              Chef::Node.load(n)
            rescue => e
              Chef::Log.warn("Could not load node #{n}: #{e.class}: #{e.message}")
              nil
            end
          end

        next unless node_obj

        if node_obj.is_a?(Hash)
          node_obj['ipaddress_sync'] ||
            node_obj['ipaddress'] ||
            (node_obj['automatic'] && node_obj['automatic']['ipaddress'])
        else
          node_obj['ipaddress_sync'] || node_obj['ipaddress']
        end
      end

      ips = ips.compact.uniq.sort
      if ips.empty?
        Chef::Log.warn("Aerospike IP list is empty. Check managers_per_service['aerospike'] and node attributes.")
      end
      ips
    end
  end
end
