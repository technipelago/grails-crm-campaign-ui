package grails.plugins.crm.campaign

/**
 * Email Campaign Configurator.
 */
class EmailCampaignController {

    def grailsApplication
    def emailCampaign

    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        if (request.post) {
            emailCampaign.configure(crmCampaign, params)
            if (crmCampaign.save()) {
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
            } else {
                def url = grailsApplication.config.crm.web.url + '/newsletter/' + crmCampaign.publicId + '.htm'
                render view: "edit", model: [crmCampaign: crmCampaign, cfg: crmCampaign.configuration, url: url]
            }
        } else {
            def url = grailsApplication.config.crm.web.url + '/newsletter/' + crmCampaign.publicId + '.htm'
            return [crmCampaign: crmCampaign, cfg: crmCampaign.configuration, url: url]
        }
    }
}
