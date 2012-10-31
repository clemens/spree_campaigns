module Spree
  module Admin
    class CampaignsController < ResourceController
      respond_to :csv, :only => :show

      def show
        campaign = @object

        send_data(
          campaign.to_csv,
          :type        => "text/csv; charset=utf-8; header=present",
          :disposition => "attachment; filename=#{campaign.name}.csv"
        )
      end

    protected

      def build_resource
        @campaign = Campaign.new(params[:campaign])
      end
    end
  end
end
