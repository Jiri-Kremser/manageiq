class CreateMiddlewareFuseTables < ActiveRecord::Migration[5.0]
  def change

    create_table :middleware_camel_contexts do |t|
      t.string :name
      t.string :ems_ref
      t.string :nativeid
      t.string :feed
      t.bigint :server_id
      t.bigint :ems_id
      t.timestamps :null => false
    end

    create_table :middleware_camel_entities do |t|
      t.string :name
      t.string :ems_ref
      t.string :nativeid
      t.string :feed
      t.string :entity_type
      t.bigint :camel_context_id
      t.text   :properties
      t.bigint :ems_id
      t.timestamps :null => false
    end
  end
end
