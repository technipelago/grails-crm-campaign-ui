package grails.plugins.crm.campaign

import groovy.json.JsonSlurper

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
                def cfg = crmCampaign.handlerConfig ? new JsonSlurper().parseText(crmCampaign.handlerConfig) : [:]
                return [crmCampaign: crmCampaign, cfg: cfg]
            case "POST":
                productDiscountCampaign.configure(crmCampaign) {
                    productGroups = params.productGroups.split(',').toList()
                    products = params.products.split(',').toList()
                    discountProduct = params.discountProduct
                    discount = params.double('discount')
                    condition = params.condition
                    threshold = params.double('threshold')
                }
                crmCampaign.save()
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
                break
        }
    }
}
