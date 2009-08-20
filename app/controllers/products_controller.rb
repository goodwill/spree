
class ProductsController < Spree::BaseController
  prepend_before_filter :reject_unknown_object
  before_filter(:setup_admin_user) unless RAILS_ENV == "test"

  resource_controller
  helper :taxons,:search_form
  before_filter :load_data, :only => :show
  actions :show, :index

  index do
    before do
      @product_cols = 3
    end
  end

  def change_image
    @product = Product.available.find_by_param(params[:id])
    img = Image.find(params[:image_id])
    render :partial => 'image', :locals => {:image => img}
  end

  private
  def setup_admin_user
    return if admin_created?
    flash[:notice] = I18n.t(:please_create_user)
    redirect_to signup_url
  end
  
  def load_data  
    load_object  
    @selected_variant = @product.variants.detect { |v| v.in_stock || Spree::Config[:allow_backorders] }
		
    return unless permalink = params[:taxon_path]
    @taxon = Taxon.find_by_permalink(params[:taxon_path].join("/") + "/")	 
  end
  
  def collection
    base_scope = Product.active

    if !params[:taxon].blank? && (@taxon = Taxon.find_by_id(params[:taxon]))
      base_scope = base_scope.taxons_id_in_tree(@taxon)
    end
    
    @search = base_scope.search(nurse_search_set(params[:search]))
    
    # set on model basis (default 30)
    # might want to add .scoped(:select => "distinct on (products.id) products.*") here
    # in case some filter goes astray with its joins

    # this can now be set on a model basis 
    # Product.per_page ||= Spree::Config[:products_per_page]

    ## defunct?
    @product_cols = 3 
    
    products_per_page=params[:per_page].to_i
    products_per_page=Spree::Config[:products_per_page] if products_per_page==0
    
    @products ||= @search.paginate(:include  => [:images, {:variants => :images}],
                                   :per_page => products_per_page,
                                   :page     => params[:page])
  end
  
  def nurse_search_set(search_params)
    unless search_params.nil?
      result=search_params.clone
      search_params.each do |k,v|
        result[k]=v.split(" ") if k =~ /_any$/
      end
    
      result
    end
  end
end
