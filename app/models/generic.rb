class Generic < ActiveRecord::Base

  def self.conn
    @conn ||= Block.connection
  end

  def self.query sql
    conn.execute(sql)
  end

  def self.query_all sql
    conn.execute(sql).to_a
  end

  def self.query_one sql
    rows = conn.execute(sql).to_a[0]
    rows[0] if rows
  end

  def self.query_col sql
    conn.execute(sql).to_a.flatten
  end

  def self.quote str
    "'#{conn.quote_string(str.to_s)}'"
  end

  def self.quote_all(atts)
    atts.map{|k,v| [k, v.is_a?(String) ? quote(v) : v]}.to_h
  end

  def self.exists?(table, atts)
    _exists?(table, quote_all(atts))
  end
  def self.update(table, atts, match_on = [])
    _update(table, quote_all(atts), match_on)
  end
  def self.insert(table, atts)
    _insert(table, quote_all(atts))
  end

  def self._exists?(table, atts)
    where = atts.map{|k,v| "#{k} = #{v}"}.join(' AND ')
    sql = "SELECT 1 FROM #{table} WHERE #{where} LIMIT 1"
    query_one(sql) == 1
  end

  def self._update(table, atts, match_on = [])
    match_on = [match_on] unless match_on.is_a?(Array)
    where = match_on.map{|k| "#{k} = #{atts[k]}"}.join(' AND ')
    set   = atts.map{|k,v| "#{k}=#{v}" unless match_on.include?(k)}.compact.join(',')
    sql   = "UPDATE #{table} SET #{set} WHERE #{where}"
    query(sql)
  end

  def self._insert(table, atts)
    cols = atts.keys.join(',')
    vals = atts.values.join(',')
    sql  = "INSERT INTO #{table} (#{cols}) VALUES (#{vals})"
    query(sql)
  end

  def self.get_id(str)
    str.scan(/\d+$/)[0].to_i
  end

  def self.rpc
    @rpc ||= Graphene::API::RPC.instance
  end

  def self.log_pause
    @old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
  end

  def self.log_resume
    @old_logger ||= ActiveRecord::Base.logger
    ActiveRecord::Base.logger = @old_logger
  end

end
