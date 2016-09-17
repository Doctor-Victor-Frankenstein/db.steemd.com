STEEMD = YAML.load_file('config/steemd.yml')

require Rails.root.join("lib/graphene.rb").to_s
Graphene::RPC.init(STEEMD['rpc'])
