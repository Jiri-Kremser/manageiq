class MiddlewareFuseServer < MiddlewareServer
  belongs_to :ext_management_system, :foreign_key => 'ems_id'
  has_many :middleware_camel_contexts, :foreign_key => 'server_id', :dependent => :destroy
  serialize :properties
  acts_as_miq_taggable
end
