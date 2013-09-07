package grails.plugins.crm.campaign

import grails.plugins.crm.content.CrmResourceRef

/**
 * Email Campaign Configurator.
 */
class EmailCampaignController {

    def emailCampaign
    def crmContentService

    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        def cfg = crmCampaign.configuration
        def bodyHtml = crmContentService.getAttachedResource(crmCampaign, 'body.html')
        def bodyText = crmContentService.getAttachedResource(crmCampaign, 'body.txt')

        if (request.post) {
            emailCampaign.configure(crmCampaign, params)
            if (crmCampaign.save()) {
                if (params.html?.trim()) {
                    bodyHtml = saveAttachment(bodyHtml, params.html, 'text/html', "E-postmeddelande i HTML-format")
                } else if (bodyHtml) {
                    crmContentService.deleteReference(bodyHtml)
                }
                if (params.text?.trim()) {
                    bodyText = saveAttachment(bodyText, params.text, 'text/plain', "E-postmeddelande i textformat")
                } else if (bodyText) {
                    crmContentService.deleteReference(bodyText)
                }
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
            } else {
                render view: "edit", model: [crmCampaign: crmCampaign, cfg: cfg, bodyHtml: bodyHtml, bodyText: bodyText]
            }
        } else {
            return [crmCampaign: crmCampaign, cfg: cfg, bodyHtml: bodyHtml, bodyText: bodyText]
        }
    }

    private CrmResourceRef saveAttachment(CrmResourceRef replace, String text, String contentType, String title) {
        if (replace) {
            def inputStream = new ByteArrayInputStream(text.getBytes("UTF-8"))
            try {
                crmContentService.updateResource(replace, inputStream, contentType)
            } finally {
                inputStream.close()
            }
        } else {
            replace = crmContentService.createResource(text, contentType.contains('html') ? "body.html" : "body.txt", replace, contentType, [status: 'shared', title: title])
        }
        return replace
    }
}
