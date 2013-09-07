package grails.plugins.crm.campaign

/**
 * Email Campaign Configurator.
 */
class EmailCampaignController {

    def emailCampaign

    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        def cfg = crmCampaign.configuration

        if (request.post) {
            emailCampaign.configure(crmCampaign, params)
            if (crmCampaign.save()) {
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
            } else {
                render view: "edit", model: [crmCampaign: crmCampaign, cfg: cfg]
            }
        } else {
            return [crmCampaign: crmCampaign, cfg: cfg]
        }
    }
}
