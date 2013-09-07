package grails.plugins.crm.campaign

class ProductDiscountCampaignController {

    def productDiscountCampaign

    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        switch (request.method) {
            case "GET":
                def cfg = crmCampaign.configuration
                return [crmCampaign: crmCampaign, cfg: cfg]
            case "POST":
                productDiscountCampaign.configure(crmCampaign, params)
                crmCampaign.save()
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
                break
        }
    }
}
