package grails.plugins.crm.campaign

import grails.converters.JSON
import grails.plugins.crm.content.CrmResourceRef
import grails.plugins.crm.core.SearchUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.transaction.Transactional
import org.apache.commons.io.FilenameUtils
import org.apache.commons.lang.StringUtils

import javax.servlet.http.HttpServletResponse

/**
 * Email Campaign Configurator.
 */
class EmailCampaignController {

    private static final String DEFAULT_PART = 'body'

    static allowedMethods = [addPart: 'POST', delete: 'POST']

    def grailsApplication
    def emailCampaign
    def crmEmailCampaignService
    def crmCoreService
    def crmContentService
    def crmFreeMarkerService
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
        if (stats.dateSent) {
            render template: "statistics", model: [bean: crmCampaign, recipients: count, cfg: cfg, stats: stats]
        } else {
            response.sendError(HttpServletResponse.SC_NO_CONTENT)
        }
    }

    @Transactional
    def edit(Long id, Long part, Long next) {

        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        def crmResourceRef
        if (part) {
            crmResourceRef = crmContentService.getResourceRef(part)
            if (!crmResourceRef) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            if (crmResourceRef.reference.id != crmCampaign.id) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST)
                return
            }
        } else {
            crmResourceRef = crmEmailCampaignService.getPart(crmCampaign, DEFAULT_PART)
            if (!crmResourceRef) {
                crmResourceRef = crmEmailCampaignService.setPart(crmCampaign, DEFAULT_PART, '<p>&nbsp;</p>')
            }
        }

        params._part = FilenameUtils.getBaseName(crmResourceRef.name)

        if (request.post) {
            emailCampaign.configure(crmCampaign, params)
            if (crmCampaign.save()) {
                // Remove updated template from cache.
                crmFreeMarkerService.removeFromCache("crmCampaign/${crmCampaign.id}/${crmResourceRef.name}")
                //crmFreeMarkerService.clearCache()
                if (params.boolean('preview')) {
                    def result
                    try {
                        result = crmEmailCampaignService.render(crmCampaign, null, getPreviewModel(crmCampaign))
                    } catch (Exception e) {
                        result = "<pre>${e.message}</pre>"
                    }
                    render contentType: "text/html", text: result
                } else if (next) {
                    redirect action: 'edit', params: [id: crmCampaign.id, part: next]
                } else {
                    flash.success = message(code: 'emailCampaign.updated.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
                    redirect controller: 'crmCampaign', action: "show", id: id
                }
            } else {
                def metadata = [:]
                metadata.parts = getParts(crmCampaign)
                metadata.templates = getTemplates(crmCampaign)

                render view: "edit", model: [crmCampaign: crmCampaign, cfg: crmCampaign.configuration,
                                             url        : getNewsletterUrl(crmCampaign), metadata: metadata,
                                             part       : crmResourceRef]
            }
        } else {
            def user = crmSecurityService.currentUser
            def cfg = crmCampaign.configuration
            if(cfg.parts) {
                cfg = emailCampaign.migrate(crmCampaign)
                crmCampaign.save()
            }
            if (!cfg.subject) {
                cfg.subject = crmCampaign.toString()
            }
            if (!cfg.sender) {
                cfg.sender = user.email
            }
            if (!cfg.senderName) {
                cfg.senderName = user.name
            }
            def metadata = [:]
            metadata.parts = getParts(crmCampaign)
            metadata.templates = getTemplates(crmCampaign)

            return [crmCampaign: crmCampaign, cfg: cfg,
                    url        : getNewsletterUrl(crmCampaign), metadata: metadata,
                    part       : crmResourceRef, content: crmResourceRef.text]
        }
    }

    private Map getPreviewModel(CrmCampaign campaign) {
        def username = crmSecurityService.currentUser?.username
        event(for: 'crmEmailCampaign', topic: 'previewModel', fork: false,
                data: [tenant: campaign.tenantId, campaign: campaign.id, user: username]).waitFor(10000)?.value
    }

    @Transactional
    def delete(Long id, Long part) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }

        def crmResourceRef = crmContentService.getResourceRef(part)
        if (!crmResourceRef) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        if (crmResourceRef.reference.id != crmCampaign.id) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST)
            return
        }

        crmContentService.deleteReference(crmResourceRef)

        redirect action: 'edit', id: id
    }

    // Parts attached to the campaign.
    //
    private List<CrmResourceRef> getParts(final CrmCampaign crmCampaign) {
        crmContentService.findResourcesByReference(crmCampaign, [name: '*.html', sort: 'name', order: 'asc'])
    }

    // Global templates.
    //
    private List<CrmResourceRef> getTemplates(final CrmCampaign crmCampaign) {
        def path = grailsApplication.config.crm.campaign.email.template.path ?: "/templates/email"
        crmContentService.getFolder(path)?.files ?: []
    }

    @Transactional
    def addPart(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }

        def content = params.content ?: '<p>&nbsp;</p>'
        def crmResourceRef = crmEmailCampaignService.setPart(crmCampaign, params.name ?: DEFAULT_PART, content)
        def payload = [id: crmResourceRef.id, name: FilenameUtils.getBaseName(crmResourceRef.name), content: content]

        render payload as JSON
    }

    def template(String path) {
        if (!path) {
            response.sendError(HttpServletResponse.SC_NO_CONTENT)
            return
        }
        def tmpl = crmContentService.getContentByPath(path)
        if (!tmpl) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def result = tmpl.dao
        result.body = tmpl.text
        WebUtils.shortCache(response)
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

}
