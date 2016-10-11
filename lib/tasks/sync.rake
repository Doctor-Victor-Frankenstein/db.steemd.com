def amt(str)
  str.split(' ')[0].to_f
end

require 'iconv'
require 'faye/websocket'
require 'eventmachine'

namespace :sync do

  task :accounts => :environment do
    puts "Syncing accounts"
    @db = Graphene::RPC.instance

    # Load all account names
    accounts = @db.lookup_accounts("", 1000)
    while true
      buffer = @db.lookup_accounts(accounts[-1], 1000)[1..-1]
      break if buffer.empty?
      accounts += buffer
    end

    ids = Generic.query_col("SELECT id FROM accounts")

    # Sync all accounts in batches of 1,000
    bar = ProgressBar.new(accounts.size, :bar, :counter, :percentage, :elapsed, :eta, :rate)
    accounts.each_slice(1000) do |names|
      ActiveRecord::Base.transaction do
        @db.get_accounts(names).each do |o|
          atts = Account.to_hash(o)
          if ids.include?(atts[:id]) #Generic.exists?('accounts', {id: atts[:id]})
            Generic.update('accounts', atts, :id)
          else
            Generic.insert('accounts', atts)
          end
        end
      end
      bar.increment! 1000
    end
  end

  task :blocks => :environment do
    puts "Syncing blocks"
    @db = Graphene::RPC.instance

    last_block = (Generic.query_one("SELECT MAX(id) FROM blocks") || 0) + 1
    head_block = @db.get_dynamic_global_properties['last_irreversible_block_num'] # ['head_block_number']
    block_nums = (last_block..head_block).to_a

    bar = ProgressBar.new(block_nums.size, :bar, :counter, :percentage, :elapsed, :eta, :rate)
    block_nums.each_slice(1000) do |nums|
      ActiveRecord::Base.transaction do
        nums.each do |num|
          b = @db.get_block(num)
        end
        bar.increment! 100
      end
    end
  end


  task :blocks2 => :environment do
    @db = Graphene::RPC.instance

    last_block = (Generic.query_one("SELECT MAX(id) FROM blocks") || 0) + 1
    head_block = @db.get_dynamic_global_properties['last_irreversible_block_num'] # ['head_block_number']
    block_nums = (last_block..head_block).to_a

    puts "Syncing blocks #{last_block} to #{head_block}"

    EM.run {
      bar     = ProgressBar.new(block_nums.size, :bar, :counter, :percentage, :elapsed, :eta, :rate)
      ws      = Faye::WebSocket::Client.new(STEEMD['ws'])
      loading = nil
      bout    = []

      EM.add_timer(7200) do
        puts "ABORTING"
        ws.close
      end

      ws.on :open do |event|
        puts "ws connection opened"
        loading = block_nums.shift
        ws.send({"id" => 1, "method" => "call", "params" => [0, "get_block", [loading,false]]}.to_json)
      end

      ws.on :error do |event|
        puts "Error: #{event.inspect}"
      end

      ws.on :message do |event|
        bout << [loading, JSON.parse(event.data)['result'].compact]

        if bout.size == 1000
          _create_blocks!(bout, @db)
          bar.increment! bout.size
          bout = []
        end

        if block_nums.empty?
          ws.close
        else
          loading = block_nums.shift
          ws.send({"id" => 1, "method" => "call", "params" => [0, "get_block", [loading,false]]}.to_json)
        end
      end

      ws.on :close do |event|
        puts "closed"
        ws = nil
        EM.stop_event_loop

        if bout.size > 0
          _create_blocks!(bout, @db)
          bar.increment! bout.size
        end
      end
    }
    puts "fin"
  end

  def _create_blocks!(blocks, db)
    #comments = []
    #votes = []
    #
    votes = {}
    ActiveRecord::Base.transaction do
      blocks.each do |num, block|
        block['transactions'].each do |tx|
          tx['operations'].each do |type, o|
            case type
              when 'account_create'
                if !Account.get_id(o['new_account_name'], false)
                  acct = db.get_accounts([o['new_account_name']])[0]
                  Generic.insert('accounts', Account.to_hash(acct))
                end

              when 'comment'
                if !PostId.get_id(o['author'], o['permlink'], false)
                  Generic.insert('post_ids', {
                    parent_id: PostId.get_id(o['parent_author'], o['parent_permlink']), 
                    block_id:  num, 
                    author:    o['author'],
                    permlink:  o['permlink'],
                    category:  o['parent_permlink']})
                end

              when 'vote'
                key = [num, o['voter'], o['author'], o['permlink']].join('/')
                votes[key] = {
                  voter_id: Account.get_id(o['voter']),
                  post_id:  PostId.get_id(o['author'], o['permlink']),
                  weight:   o['weight'],
                  created:  block['timestamp']}
            end
          end
        end
      end

      votes.values.each do |atts|
        Generic.insert('votes', atts) 
      end

    #end
    #ActiveRecord::Base.transaction do

      blocks.each do |num, o|
        atts = {
          id:      num,
          witness: o['witness'],
          txs:     o['transactions'].size,
          signed:  o['timestamp']}

        Generic.insert('blocks', atts)
      end
    end
  end

  task :posts => :environment do
    puts "Syncing posts"
    @db = Graphene::RPC.instance

    #sql = "SELECT id FROM post_ids WHERE id NOT IN (SELECT id FROM posts)"
    #post_ids = Generic.query_col(sql)

    posts = Generic.query_all("SELECT id, parent_id, block_id, author, permlink FROM post_ids WHERE id NOT IN (SELECT id FROM posts)")
    exit if posts.size == 0

    EM.run {
      bar     = ProgressBar.new(posts.size, :bar, :counter, :percentage, :elapsed, :eta, :rate)
      ws      = Faye::WebSocket::Client.new(STEEMD['ws'])
      loading = nil
      bout    = []

      EM.add_timer(7200) do
        puts "ABORTING"
        ws.close
      end

      ws.on :open do |event|
        puts "ws connection opened"
        loading = posts.shift
        ws.send({"id" => 1, "method" => "call", "params" => [0, "get_content", [loading[3], loading[4], false]]}.to_json)
      end

      ws.on :error do |event|
        puts "Error: #{event.inspect}"
      end

      ws.on :message do |event|
        bout << [loading, JSON.parse(event.data)['result'].compact]

        if bout.size == 1000
          _create_posts!(bout)
          bar.increment! bout.size
          bout = []
        end

        if posts.empty?
          ws.close
        else
          loading = posts.shift
          ws.send({"id" => 1, "method" => "call", "params" => [0, "get_content", [loading[3], loading[4], false]]}.to_json)
        end
      end

      ws.on :close do |event|
        puts "closed"
        ws = nil
        EM.stop_event_loop

        if bout.size > 0
          _create_posts!(bout)
          bar.increment! bout.size
        end
      end
    }
    puts "fin"
  end

  def _create_posts!(data)
    ActiveRecord::Base.transaction do
      data.each do |meta, o|
        id, parent_id, block_id, author, permlink = meta
        #puts "#{id} #{o['title']}"

        atts = {
          id:        id,
          parent_id: parent_id,
          children:  o['children'],
          block:     block_id,
          author:    o['author'],
          permlink:  o['permlink'],
          category:  o['parent_permlink'],

          title: o['title'],
          body:  _clean(o['body']),
          json:  o['json_metadata'],

          created: o['created'],
          updated: o['last_update'],
          active:  o['active'],
          paid:    o['last_payout'],
          cashout: o['cashout_time'],

          net_rshares:          o['net_rshares'].to_i / 1000000,
          vote_rshares:         o['vote_rshares'].to_i / 1000000,
          children_abs_rshares: o['children_abs_rshares'].to_i / 1000000,
          total_vote_weight:    o['total_vote_weight'].to_i / 1000000,

          total_payout_value:         amt(o['total_payout_value']) * 1000,
          curator_payout_value:       amt(o['curator_payout_value']) * 1000,
          pending_payout_value:       amt(o['pending_payout_value']) * 1000,
          total_pending_payout_value: amt(o['total_pending_payout_value']) * 1000}
        Generic.insert('posts', atts)
      end
    end
  end

  def _clean(str)
    str2 = nil
    ic   = Iconv.new('UTF-8', 'UTF-8//IGNORE')
    begin
      str2 = ic.iconv(str)
    rescue Iconv::IllegalSequence
      raise "Invalid UTF-8 detected.. skipping! #{str}"
      return
    end
    if str != str2
      puts "WARNING: FIX #{str[0..30]}.. to #{str2[0..30]}"
      str = "#{str2} (UTF-8 warning)"
    end

    str
  end

end

