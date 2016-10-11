class Account < ActiveRecord::Base

  @@map = {}

  def self.get_id(name, strict = true)
    return @@map[name] if @@map[name]

    id = Generic.query_one("SELECT id FROM accounts WHERE name = '%s' LIMIT 1" % name)
    raise "ACCOUNT NOT FOUND: #{name}" if strict && !id

    @@map[name] = id if id
    id
  end

  def self.to_hash(o)
    atts = {
      id:          o['id'].split('.')[-1].to_i,
      name:        o['name'],
      proxy:       o['proxy'],
      proxy_vests: proxy_vests(o),
      created:     o['created'],
      active:      o['created'], #o['last_active'],
      steem:       amt(o['balance']) * 1000,
      sbd:         amt(o['sbd_balance']) * 1000,
      vests:       amt(o['vesting_shares']) * 1000000,
      post_count:  o['post_count'],
      reputation:  rep(o['reputation']),
      votes_for:   o['witness_votes'].join(',')
    }
  end

  def self.amt(str)
    str.split(' ')[0].to_f
  end

  def self.rep(raw)
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

  def self.proxy_vests(o)
    amt(o['vesting_shares']) * 1000000 + o['proxied_vsf_votes'].map{|i| i.to_f}.sum
  end

end
