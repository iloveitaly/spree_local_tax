if defined?(Spree::AdvancedReport)
  require_dependency 'spree/admin/reports_controller'

  Spree::Admin::ReportsController.class_eval do
    # this is an ugly hack until reports get cleaned up
    # https://github.com/spree/spree/issues/1863

    (AVAILABLE_REPORTS ||= {}).merge!(
      (ADVANCED_REPORTS ||= {}).merge!({
        :local_tax => {
          name: 'Local Tax',
          description: 'Local taxation report by city'
        },
        :orders_local_tax => {
          name: 'Local Tax by Order',
          description: 'Local taxation report by order'
        }
      })
    )


    before_filter :basic_report_setup, :actions => :local_tax

    def local_tax
      @report = Spree::AdvancedReport::LocalTaxReport.new(params)
      base_report_top_render("local_tax")    
    end

    def orders_local_tax
      @report = Spree::AdvancedReport::LocalTaxOrderReport.new(params)
      base_report_top_render("orders_local_tax")
    end
  end
end
