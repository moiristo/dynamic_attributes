
# Adds the has_dynamic_attributes method in ActiveRecord::Base, which can be used to configure the module.
class << ActiveRecord::Base  
  
  # Method to call in AR classes in order to be able to define dynamic attributes. The following options can be defined:
  #
  # * :dynamic_attribute_field - Defines the attribute to which all dynamic attributes will be serialized. Default: :dynamic_attributes.
  # * :dynamic_attribute_prefix - Defines the prefix that a dynamic attribute should have. All assignments that start with this prefix will become
  # dynamic attributes. Note that it's not recommended to set this prefix to the empty string; as every method call that falls through to method_missing 
  # will become a dynamic attribute. Default: 'field_'
  # * :destroy_dynamic_attribute_for_nil - When set to true, the module will remove a dynamic attribute when its value is set to nil. Defaults to false, causing
  # the module to store a dynamic attribute even if its value is nil.
  #
  def has_dynamic_attributes(options = { :dynamic_attribute_field => :dynamic_attributes, :dynamic_attribute_prefix => 'field_', :destroy_dynamic_attribute_for_nil => false})
    cattr_accessor :dynamic_attribute_field  
    self.dynamic_attribute_field = options[:dynamic_attribute_field] || :dynamic_attributes
    cattr_accessor :dynamic_attribute_prefix
    self.dynamic_attribute_prefix = options[:dynamic_attribute_prefix] || 'field_'
    cattr_accessor :destroy_dynamic_attribute_for_nil
    self.destroy_dynamic_attribute_for_nil = options[:destroy_dynamic_attribute_for_nil] || false    

    include DynamicAttributes 
  end
end

# The DynamicAttributes module handles all dynamic attributes.
module DynamicAttributes

    # Overrides the initializer to take dynamic attributes into account
    def initialize(attributes = nil)
      dynamic_attributes = {}
      (attributes ||= {}).each{|att,value| dynamic_attributes[att] = value if att.to_s.starts_with?(self.dynamic_attribute_prefix) }
      super(attributes.except(*dynamic_attributes.keys))   
      set_dynamic_attributes(dynamic_attributes)    
    end
    
    def has_dynamic_attribute?(dynamic_attribute)
      return persisting_dynamic_attributes.include?(dynamic_attribute.to_s)
    end
      
    # On saving an AR record, the attributes to be persisted are re-evaluated and written to the serialization field. 
    def evaluate_dynamic_attributes
      new_dynamic_attributes = {}
      self.persisting_dynamic_attributes.uniq.each do |dynamic_attribute| 
        value = send(dynamic_attribute)
        if value.nil? and destroy_dynamic_attribute_for_nil
          self.persisting_dynamic_attributes.delete(dynamic_attribute)
          singleton_class.send(:remove_method, dynamic_attribute + '=')
        else
          new_dynamic_attributes[dynamic_attribute] = value
        end
      end
      write_attribute(self.dynamic_attribute_field, new_dynamic_attributes)
    end
    
    # After find, populate the dynamic attributes and create accessors
    def populate_dynamic_attributes
      (read_attribute(self.dynamic_attribute_field) || {}).each {|att, value| set_dynamic_attribute(att, value); self.destroy_dynamic_attribute_for_nil = false if value.nil? }
    end
    
    # Explicitly define after_find for Rails 2.x
    def after_find; populate_dynamic_attributes end    

    # Overrides update_attributes to take dynamic attributes into account
    def update_attributes(attributes)  
      set_dynamic_attributes(attributes)  
      super(attributes)
    end
    
    # Creates an accessor when a non-existing setter with the configured dynamic attribute prefix is detected. Calls super otherwise.
    def method_missing(method, *arguments, &block) 
      (method.to_s =~ /#{self.dynamic_attribute_prefix}(.+)=/) ? set_dynamic_attribute(self.dynamic_attribute_prefix + $1, *arguments.first) : super
    end     
    
    # Returns the dynamic attributes that will be persisted to the serialization column. This array can
    # be altered to force dynamic attributes to not be saved in the database or to persist other attributes, but
    # it is recommended to not change it at all.
    def persisting_dynamic_attributes
      @persisting_dynamic_attributes ||= []
    end
    
    # Ensures the configured dynamic attribute field is serialized by AR.
    def self.included object
      super
      object.after_find  :populate_dynamic_attributes         
      object.before_save :evaluate_dynamic_attributes    
      object.serialize object.dynamic_attribute_field
    end

  private

    # Method that is called when a dynamic attribute is added to this model. It adds this attribute to the list
    # of attributes that will be persisited, creates an accessor and sets the attribute value. To reflect that the
    # attribute has been added, the serialization attribute will also be updated. 
    def set_dynamic_attribute(att, value)
      att = att.to_s
      persisting_dynamic_attributes << att
      singleton_class.send(:attr_accessor, att)
      send(att + '=', value)
      update_dynamic_attribute(att, value)
    end
    
    # Called on object initialization or when calling update_attributes to convert passed dynamic attributes
    # into attributes that will be persisted by calling set_dynamic_attribute if it does not exist already. 
    # The serialization column will also be updated and the detected dynamic attributes are removed from the passed
    # attributes hash.
    def set_dynamic_attributes(attributes)
      return if attributes.nil?
      
      attributes.each do |att, value| 
        if att.to_s.starts_with?(self.dynamic_attribute_prefix)
          attributes.delete(att)          
          unless respond_to?(att.to_s + '=')
            set_dynamic_attribute(att, value)           
          else
            send(att.to_s + '=', value); 
            update_dynamic_attribute(att, value)
          end
        end    
      end      
    end
    
    # Updates the serialization column with a new attribute and value.
    def update_dynamic_attribute(attribute, value)
      write_attribute(self.dynamic_attribute_field.to_s, (read_attribute(self.dynamic_attribute_field.to_s) || {}).merge(attribute.to_s => value))                
    end 
    
    # Gets the object's singleton class. Backported from Rails 2.3.8 to support older versions of Rails.
    def singleton_class
      class << self
        self
      end
    end
    
end
