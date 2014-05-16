package grails.plugins.crm.campaign

import grails.converters.JSON
import grails.plugins.crm.content.CrmResourceRef
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.SearchUtils
import org.apache.commons.lang.StringUtils

import javax.servlet.http.HttpServletResponse

/**
 * Email Campaign Configurator.
 */
class EmailCampaignController {

    def grailsApplication
    def emailCampaign
    def crmEmailCampaignService
    def crmCoreService
    def crmContentService
    def crmSecurityService

    private String getNewsletterUrl(CrmCampaign campaign) {
        def serverURL = grailsApplication.config.crm.web.url ?: grailsApplication.config.grails.serverURL
        if (!serverURL) {
            serverURL = 'http://localhost:8080/' + grailsApplication.metadata['app.name']
        }
        def newsletterURL = grailsApplication.config.crm.campaign.email.url ?: 'newsletter'
        return "${serverURL}/${newsletterURL}/${campaign.publicId}.html"
    }

    def summary(Long id) {
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def count = CrmCampaignRecipient.countByCampaign(crmCampaign)
        def cfg = crmCampaign.configuration
        render template: "summary", model: [bean: crmCampaign, recipients: count, cfg: cfg]
    }

    def statistics(Long id) {
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def count = CrmCampaignRecipient.countByCampaign(crmCampaign)
        def cfg = crmCampaign.configuration
        def stats = crmEmailCampaignService.getStatistics(crmCampaign)
        if (stats.dateOpened) {
            stats.opened = Math.round(stats.dateOpened / stats.dateSent * 100)
        } else {
            stats.opened = 0
        }
        if(stats.dateSent) {
            render template: "statistics", model: [bean: crmCampaign, recipients: count, cfg: cfg, stats: stats]
        } else {
            response.sendError(HttpServletResponse.SC_NO_CONTENT)
        }
    }

    def edit(Long id) {

        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        def metadata = [:]
        metadata.templates = getTemplates(crmCampaign)

        if (request.post) {
            params.parts = params.list('parts')
            emailCampaign.configure(crmCampaign, params)
            if (crmCampaign.save()) {
                flash.success = message(code: 'crmEmailCampaign.updated.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
                redirect action: "edit", id: id
            } else {
                render view: "edit", model: [crmCampaign: crmCampaign, cfg: crmCampaign.configuration, url: getNewsletterUrl(crmCampaign), metadata: metadata]
            }
        } else {
            def user = crmSecurityService.currentUser
            def cfg = crmCampaign.configuration
            if (!cfg.parts) {
                cfg.parts = ['body']
            }
            if(!cfg.subject) {
                cfg.subject = crmCampaign.toString()
            }
            if(!cfg.sender) {
                cfg.sender = user.email
            }
            if(!cfg.senderName) {
                cfg.senderName = user.name
            }
            return [crmCampaign: crmCampaign, cfg: cfg, url: getNewsletterUrl(crmCampaign), metadata: metadata]
        }
    }

    private List<Map<String, String>> getTemplates(final CrmCampaign crmCampaign) {
        def path = grailsApplication.config.crm.campaign.email.template.path ?: "/epost"
        def folder = crmContentService.getFolder(path)
        folder ? folder.files.collect{[name:it.title, path: it.path.join('/')]} : []
    }

    def template(String path) {
        if(! path) {
            response.sendError(HttpServletResponse.SC_NO_CONTENT)
            return
        }
        def tmpl = crmContentService.getContentByPath(path)
        if(! tmpl) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def result = tmpl.dao
        result.body = tmpl.text
        render result as JSON
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
        if (request.post) {
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
            params.parts = params.list('parts')
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
