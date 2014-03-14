package grails.plugins.crm.campaign

/**
 * Banner campaign configurator.
 */
class BannerCampaignController {

    def bannerCampaign

    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        switch (request.method) {
            case "GET":
                def cfg = crmCampaign.configuration ?: [:]
                if(! cfg.url) cfg.url = "http://"
                return [crmCampaign: crmCampaign, cfg: cfg]
            case "POST":
                bannerCampaign.configure(crmCampaign, params)
                crmCampaign.save()
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
                break
        }
    }
}
