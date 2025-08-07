unified_mode true

# Cookbook:: aerospike
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'root'
attribute :ipaddress_sync, kind_of: String, default: '127.0.0.1'
attribute :managers_per_service, kind_of: Hash, default: {}
attribute :ipaddress, kind_of: String, default: '127.0.0.1'
