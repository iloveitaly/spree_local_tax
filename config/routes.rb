Spree::Core::Engine.routes.draw do
  match '/admin/reports/local_tax' => 'admin/reports#local_tax', :via => [:get, :post],
                                                                       :as => 'local_tax_admin_reports'
end