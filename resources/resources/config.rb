unified_mode true

# Cookbook:: aerospike
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'root'
attribute :ipaddress_sync, kind_of: String, default: '127.0.0.1'
attribute :aerospike_managers, kind_of: Array, default: ['127.0.0.1']
attribute :ipaddress, kind_of: String, default: '127.0.0.1'
