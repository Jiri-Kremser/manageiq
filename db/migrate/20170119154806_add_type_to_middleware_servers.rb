class AddTypeToMiddlewareServers < ActiveRecord::Migration[5.0]
  def change
    add_column :middleware_servers, :type, :string
  end
end
