package grails.plugins.crm.campaign

import grails.plugins.crm.core.WebUtils
import grails.util.GrailsNameUtils
import org.springframework.dao.DataIntegrityViolationException

class CrmCampaignController {

    static allowedMethods = [create: ["GET", "POST"], edit: ["GET", "POST"], delete: "POST"]

    def crmSecurityService
    def selectionService
    def crmCampaignService

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmCampaignQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmCampaignQuery'))
        [cmd: cmd]
    }

    def list() {
        def baseURI = new URI('bean://crmCampaignService/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                WebUtils.setTenantData(request, 'crmCampaignQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 10, 100)

        def result
        try {
            result = selectionService.select(uri, params)
            [crmCampaignList: result, crmCampaignTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmCampaignList: [], crmCampaignTotal: 0, selection: uri]
        }
    }

    def clearQuery() {
        WebUtils.setTenantData(request, 'crmCampaignQuery', null)
        redirect(action: 'index')
    }

    def create() {
        def campaignTypes = grailsApplication.campaignClasses.collect{GrailsNameUtils.getPropertyName(it.clazz)}
        def crmCampaign = new CrmCampaign()
        bindData(crmCampaign, params, [include:CrmCampaign.BIND_WHITELIST])
        crmCampaign.handlerName = params.handlerName

        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, campaignTypes: campaignTypes]
            case "POST":
                if (crmCampaign.hasErrors() || !crmCampaign.save()) {
                    render(view: "create", model: [crmCampaign: crmCampaign, campaignTypes: campaignTypes])
                    return
                }

                flash.success = message(code: 'crmCampaign.created.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
                redirect(action: "show", id: crmCampaign.id)
                break
        }
    }

    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }
        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign]
            case "POST":
                if (params.int('version') != null) {
                    if (crmCampaign.version > params.int('version')) {
                        crmCampaign.errors.rejectValue("version", "crmCampaign.optimistic.locking.failure",
                                [message(code: 'crmCampaign.label', default: 'Campaign')] as Object[],
                                "Another user has updated this Campaign while you were editing")
                        render(view: "edit", model: [crmCampaign: crmCampaign])
                        return
                    }
                }

                bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST])

                if (!crmCampaign.save(flush: true)) {
                    render(view: "edit", model: [crmCampaign: crmCampaign])
                    return
                }

                flash.success = message(code: 'crmCampaign.updated.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
                redirect(action: "show", id: crmCampaign.id)
                break
        }
    }

    def delete(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "list")
            return
        }

        try {
            def tombstone = crmCampaign.toString()
            crmCampaign.delete(flush: true)
            flash.warning = message(code: 'crmCampaign.deleted.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), tombstone])
            redirect(action: "list")
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmCampaign.not.deleted.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "show", id: id)
        }
    }

    def show(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }

        [crmCampaign: crmCampaign]
    }

}
