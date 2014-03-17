package grails.plugins.crm.campaign

import javax.servlet.http.HttpServletResponse
import grails.plugins.crm.core.TenantUtils

class ProductDiscountCampaignController {

    def productDiscountCampaign

    def summary(Long id) {
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        render template: "summary", model: [bean: crmCampaign]
    }

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
