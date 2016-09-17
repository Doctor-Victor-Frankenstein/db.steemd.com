def amt(str)
  str.split(' ')[0].to_f
end

def rep(raw)
  raw = raw.to_s
  sign = raw[0] == '-' ? -1 : 1
  if sign == -1
    raw = raw[1..-1]
  end

  lead = raw[0..-3].to_i
  frac = (lead == 0 ? 0 : Math.log(lead, 10))
  log  = (raw.length - 1) + (frac - frac.to_i)

  r = sign * [log - 9, 0].max
  r * 9 + 25
end

namespace :sync do

  task :accounts => :environment do
    puts "Syncing accounts"
    @db = Graphene::RPC.instance

    accounts = @db.lookup_accounts("", 1000)
    while true
      buffer = @db.lookup_accounts(accounts[-1], 1000)[1..-1]
      break if buffer.empty?
      accounts += buffer
    end

    bar = ProgressBar.new(accounts.size, :bar, :counter, :percentage, :elapsed, :eta, :rate)

    ttl = 0
    accounts.each_slice(1000) do |names|
      ActiveRecord::Base.transaction do
        @db.get_accounts(names).each do |o|
          #puts obj['name']
          pp = amt(o['vesting_shares']) * 1000000 + o['proxied_vsf_votes'].map{|i| i.to_f}.sum

          atts = {
            id:          o['id'].split('.')[-1],
            name:        o['name'],
            proxy:       o['proxy'],
            proxy_vests: pp,
            created:     o['created'],
            active:      o['last_active'],
            steem:       amt(o['balance']) * 1000,
            sbd:         amt(o['sbd_balance']) * 1000,
            vests:       amt(o['vesting_shares']) * 1000000,
            post_count:  o['post_count'],
            reputation:  rep(o['reputation']),
            votes_for:   o['witness_votes'].join(',')}
          if Generic.exists?('accounts', {id: atts[:id]})
            Generic.update('accounts', atts, :id)
          else
            Generic.insert('accounts', atts)
          end
        end
      end
      bar.increment! 1000
    end

  end

end

