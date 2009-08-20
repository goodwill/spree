module ProductScopeExtension


  
  def self.included(base)
    base.class_eval do
      named_scope :master_price_range_any,
        lambda {|opts| 
          conds = opts.map {|o| ProductFilters.price_filter[:conds][o]}.reject {|c| c.nil?}
          Product.conditions_any(conds).scope :find
        }
        
      
    end
  end
end