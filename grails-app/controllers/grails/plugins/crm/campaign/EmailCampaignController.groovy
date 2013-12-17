package grails.plugins.crm.campaign

import grails.converters.JSON
import grails.plugins.crm.content.CrmResourceRef
import grails.plugins.crm.core.SearchUtils
import org.apache.commons.lang.StringUtils

/**
 * Email Campaign Configurator.
 */
class EmailCampaignController {

    def grailsApplication
    def emailCampaign
    def crmEmailCampaignService
    def crmCoreService
    def crmContentService

    private String getNewsletterUrl(CrmCampaign campaign) {
        grailsApplication.config.crm.web.url + '/newsletter/' + campaign.publicId + '.html'
    }

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
                render view: "edit", model: [crmCampaign: crmCampaign, cfg: crmCampaign.configuration, url: getNewsletterUrl(crmCampaign)]
            }
        } else {
            def cfg = crmCampaign.configuration
            if (!cfg.parts) {
                cfg.parts = ['body']
            }
            return [crmCampaign: crmCampaign, cfg: cfg, url: getNewsletterUrl(crmCampaign)]
        }
    }

    def autocompleteTemplate(String name) {
        def result = []
        if (name) {
            String path = StringUtils.substringBeforeLast(name, '/')
            if (name.length() > path.length()) {
                name = name.substring(path.length() + 1)
            } else {
                name = null
            }
            def folder = crmContentService.getFolder(path)
            if (folder) {
                def folderRef = crmCoreService.getReferenceIdentifier(folder)
                result = CrmResourceRef.createCriteria().list([sort: 'name', max: 10]) {
                    eq('ref', folderRef)
                    if (name) {
                        ilike('name', SearchUtils.wildcard(name))
                    }
                    eq('status', CrmResourceRef.STATUS_PUBLISHED)
                }
            }
        }
        if (result) {
            result = result.collect { [it.path.join('/'), it.title, it.description, ['body', 'right']] }
        }
        render result as JSON
    }

    def preview(Long id) {
        def crmCampaign = CrmCampaign.read(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }
        if(request.post) {
            if (params.version) {
                def version = params.version.toLong()
                if (crmCampaign.version > version) {
                    crmCampaign.errors.rejectValue('version', 'crmCampaign.optimistic.locking.failure',
                            [message(code: 'crmCampaign.label', default: 'Email Campaign')] as Object[],
                            "Another user has updated this email campaign while you were editing")
                    render view: "edit", model: [crmCampaign: crmCampaign, cfg: crmCampaign.configuration, url: getNewsletterUrl(crmCampaign)]
                    return
                }
            }
            params.preview = true // This avoids the hyperlink scanning.
            emailCampaign.configure(crmCampaign, params)
            if (!crmCampaign.validate()) {
                render view: "edit", model: [crmCampaign: crmCampaign, cfg: crmCampaign.configuration, url: getNewsletterUrl(crmCampaign)]
                return
            }
        }
        render contentType: "text/html", text: crmEmailCampaignService.render(crmCampaign)
    }
}
