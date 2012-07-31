require_dependency 'spree/admin/reports_controller'

Spree::Admin::ReportsController.class_eval do
  (AVAILABLE_REPORTS ||= {}).merge!(
    (ADVANCED_REPORTS ||= {})[:local_tax] = {
      name: 'Local Tax',
      description: 'Local taxation report by city'
    }
  )

  before_filter :basic_report_setup, :actions => :local_tax

  def local_tax
    @report = Spree::AdvancedReport::LocalTaxReport.new(params)
    base_report_top_render("local_tax")    
  end
end