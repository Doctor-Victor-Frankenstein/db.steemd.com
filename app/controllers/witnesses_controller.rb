class WitnessesController < ApplicationController
  def index
    @rpc = Graphene::RPC.instance

    @seeds = {}
    if false
    require "open-uri"
    seeds = URI.parse('https://status.steemnodes.com/').read
    rows = seeds.scan(/<tr>\s*<td>.*?<\/tr>/m)
    rows.each do |row|
      cells = row.scan(/<td>(.*?)<\/td>/).flatten
      url, status, witness = cells.map{|v| v.gsub(/<[^>]+>/, '').strip}
      @seeds[witness] = [url, status] unless witness.blank?
    end
end
  end

  def updates
    @rpc = Graphene::RPC.instance
    @witnesses = @rpc.get_witnesses_by_vote("", 100).sort_by{|w| w['votes'].to_i}.reverse.map{|w| w['owner']}


    @posts = Post.find_all_witness_updates.select{|post| @witnesses.include?(post.author)}
  end

  def votes
    @rpc = Graphene::RPC.instance
    @wits = @rpc.get_witnesses_by_vote("", 100).sort_by{|w| w['votes'].to_i}.reverse.map{|w| [w['owner'], w['votes'].to_f / 1000000.0]}
  end

end
