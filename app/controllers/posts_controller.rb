class PostsController < ApplicationController
  def index
    @rpc = Graphene::RPC.instance
  end
end
