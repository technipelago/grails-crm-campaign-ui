package grails.plugins.crm.campaign

import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.util.GrailsNameUtils
import org.springframework.dao.DataIntegrityViolationException

class CrmCampaignController {

    static allowedMethods = [create: ["GET", "POST"], edit: ["GET", "POST"], delete: "POST"]

    def crmSecurityService
    def selectionService

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
        def tenant = TenantUtils.tenant
        def campaignTypes = grailsApplication.campaignClasses.collect { GrailsNameUtils.getPropertyName(it.clazz) }
        def crmCampaign = new CrmCampaign()
        def user = crmSecurityService.getCurrentUser()
        def timeList = (0..23).inject([]) { list, h -> 4.times { list << String.format("%02d:%02d", h, it * 15) }; list }
        def parentList = CrmCampaign.findAllByTenantId(tenant)
        def statusList = CrmCampaignStatus.findAllByTenantId(tenant)

        bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST])
        crmCampaign.handlerName = params.handlerName

        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, campaignTypes: campaignTypes, parentList: parentList, timeList: timeList, statusList: statusList]
            case "POST":
                def startDate = params.startDate ?: (new Date() + 1).format("yyyy-MM-dd")
                def endDate = params.endDate ?: startDate
                def startTime = params.startTime ?: '00:00'
                def endTime = params.endTime ?: '23:59'
                bindDate(crmCampaign, 'startTime', startDate + ' ' + startTime, user?.timezoneInstance)
                bindDate(crmCampaign, 'endTime', endDate + ' ' + endTime, user?.timezoneInstance)

                if (crmCampaign.hasErrors() || !crmCampaign.save()) {
                    render(view: "create", model: [crmCampaign: crmCampaign, campaignTypes: campaignTypes, parentList: parentList, timeList: timeList, statusList: statusList])
                    return
                }

                flash.success = message(code: 'crmCampaign.created.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
                redirect(action: "show", id: crmCampaign.id)
                break
        }
    }

    def edit(Long id) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }
        def user = crmSecurityService.getCurrentUser()
        def timeList = (0..23).inject([]) { list, h -> 4.times { list << String.format("%02d:%02d", h, it * 15) }; list }
        def parentList = CrmCampaign.findAllByTenantId(tenant)
        def statusList = CrmCampaignStatus.findAllByTenantId(tenant)
        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, statusList: statusList]
            case "POST":
                if (params.int('version') != null) {
                    if (crmCampaign.version > params.int('version')) {
                        crmCampaign.errors.rejectValue("version", "crmCampaign.optimistic.locking.failure",
                                [message(code: 'crmCampaign.label', default: 'Campaign')] as Object[],
                                "Another user has updated this Campaign while you were editing")
                        render(view: "edit", model: [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, statusList: statusList])
                        return
                    }
                }

                bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST])

                def startDate = params.startDate ?: (new Date() + 1).format("yyyy-MM-dd")
                def endDate = params.endDate ?: startDate
                def startTime = params.startTime ?: '00:00'
                def endTime = params.endTime ?: '23:59'
                bindDate(crmCampaign, 'startTime', startDate + ' ' + startTime, user?.timezoneInstance)
                bindDate(crmCampaign, 'endTime', endDate + ' ' + endTime, user?.timezoneInstance)

                if (!crmCampaign.save(flush: true)) {
                    render(view: "edit", model: [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, statusList: statusList])
                    return
                }

                flash.success = message(code: 'crmCampaign.updated.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
                redirect(action: "show", id: crmCampaign.id)
                break
        }
    }

    def delete(Long id) {

        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
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

        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }

        [crmCampaign: crmCampaign]
    }

    private void bindDate(CrmCampaign target, String property, String value, TimeZone timezone = null) {
        if (value) {
            try {
                target[property] = DateUtils.parseDateTime(value, timezone ?: TimeZone.default)
            } catch (Exception e) {
                def entityName = message(code: 'crmCampaign.label', default: 'Campaign')
                def propertyName = message(code: 'crmCampaign.' + property + '.label', default: property)
                target.errors.rejectValue(property, 'default.invalid.date.message', [propertyName, entityName, value.toString(), e.message].toArray(), "Invalid date: {2}")
            }
        } else {
            target[property] = null
        }
    }

}
