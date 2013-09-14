package grails.plugins.crm.campaign

import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.util.GrailsNameUtils
import org.springframework.dao.DataIntegrityViolationException

import javax.servlet.http.HttpServletResponse

class CrmCampaignController {

    static allowedMethods = [create: ["GET", "POST"], edit: ["GET", "POST"], delete: "POST"]

    def crmSecurityService
    def selectionService
    def selectionRepositoryService
    def crmEmailCampaignService

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmCampaignQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmCampaignQuery'))
        [cmd: cmd, campaignTypes: getCampaignTypes(), activeCampaigns: getActiveCampaigns()]
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

    private List getCampaignTypes() {
        grailsApplication.campaignClasses.collect { GrailsNameUtils.getPropertyName(it.clazz) }
    }

    private List getActiveCampaigns(int max = 10) {
        def now = new Date().clearTime()
        CrmCampaign.createCriteria().list([max: max, sort: 'lastUpdated', order: 'desc']) {
            eq('tenantId', TenantUtils.tenant)
            or {
                and {
                    isNull('startTime')
                    isNull('endTime')
                }
                and {
                    isNull('startTime')
                    ge('endTime', now)
                }
                and {
                    le('startTime', now)
                    isNull('endTime')
                }
                and {
                    le('startTime', now)
                    ge('endTime', now)
                }
            }
        }
    }

    def create() {
        def tenant = TenantUtils.tenant
        def campaignTypes = getCampaignTypes()
        def crmCampaign = new CrmCampaign()
        def user = crmSecurityService.getCurrentUser()
        def userList = crmSecurityService.getTenantUsers()
        def timeList = (0..23).inject([]) { list, h -> 4.times { list << String.format("%02d:%02d", h, it * 15) }; list }
        def parentList = CrmCampaign.findAllByTenantId(tenant)
        def statusList = CrmCampaignStatus.findAllByTenantId(tenant)

        bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST])
        crmCampaign.handlerName = params.handlerName

        def startDate = params.startDate
        def endDate = params.endDate
        def startTime = params.startTime ?: '00:00'
        def endTime = params.endTime ?: '23:59'
        bindDate(crmCampaign, 'startTime', startDate ? startDate + ' ' + startTime : null, user?.timezoneInstance)
        bindDate(crmCampaign, 'endTime', endDate ? endDate + ' ' + endTime : null, user?.timezoneInstance)

        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, campaignTypes: campaignTypes, parentList: parentList, timeList: timeList, statusList: statusList, userList: userList]
            case "POST":
                if (crmCampaign.hasErrors() || !crmCampaign.save()) {
                    render(view: "create", model: [crmCampaign: crmCampaign, campaignTypes: campaignTypes, parentList: parentList, timeList: timeList, statusList: statusList, userList: userList])
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
        def userList = crmSecurityService.getTenantUsers()
        def timeList = (0..23).inject([]) { list, h -> 4.times { list << String.format("%02d:%02d", h, it * 15) }; list }
        def parentList = CrmCampaign.findAllByTenantId(tenant)
        def statusList = CrmCampaignStatus.findAllByTenantId(tenant)
        def campaignTypes = getCampaignTypes()
        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, campaignTypes: campaignTypes, statusList: statusList, userList: userList]
            case "POST":
                if (params.int('version') != null) {
                    if (crmCampaign.version > params.int('version')) {
                        crmCampaign.errors.rejectValue("version", "crmCampaign.optimistic.locking.failure",
                                [message(code: 'crmCampaign.label', default: 'Campaign')] as Object[],
                                "Another user has updated this Campaign while you were editing")
                        render(view: "edit", model: [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, campaignTypes: campaignTypes, statusList: statusList, userList: userList])
                        return
                    }
                }

                bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST])
                // Update old campaign that has no handler.
                if (params.handlerName && !crmCampaign.handlerName) {
                    crmCampaign.handlerName = params.handlerName
                }
                def startDate = params.startDate
                def endDate = params.endDate
                def startTime = params.startTime ?: '00:00'
                def endTime = params.endTime ?: '23:59'
                bindDate(crmCampaign, 'startTime', startDate ? startDate + ' ' + startTime : null, user?.timezoneInstance)
                bindDate(crmCampaign, 'endTime', endDate ? endDate + ' ' + endTime : null, user?.timezoneInstance)

                if (!crmCampaign.save(flush: true)) {
                    render(view: "edit", model: [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, campaignTypes: campaignTypes, statusList: statusList, userList: userList])
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
            redirect(action: "index")
            return
        }

        try {
            def tombstone = crmCampaign.toString()
            crmCampaign.delete(flush: true)
            flash.warning = message(code: 'crmCampaign.deleted.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), tombstone])
            redirect(action: "index")
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

        def username = crmSecurityService.currentUser.username
        def count = CrmCampaignRecipient.countByCampaign(crmCampaign)
        def selections = selectionRepositoryService.list('crmContact', username, crmCampaign.tenantId)
        [crmCampaign: crmCampaign, recipientsCount: count, availableSelections: selections]
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

    def recipients(Long id, String email) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }
        if (request.post) {
            if (email) {
                crmEmailCampaignService.createRecipients(crmCampaign, [email])
            } else {
                flash.error = message(code: 'crmCampaignRecipient.email.blank.message', args: [message(code: 'crmCampaignRecipient.email.label', default: 'Campaign'), message(code: 'crmCampaignRecipient.label', default: 'Recipient')])
            }
            redirect action: "recipients", id: id
        } else {
            if (!params.max) {
                params.max = 10
            }
            if (!params.sort) {
                params.sort = 'dateSent'
            }
            def recipients = CrmCampaignRecipient.createCriteria().list(params) {
                eq('campaign', crmCampaign)
            }
            def hitCount = CrmCampaignRecipient.createCriteria().count() {
                eq('campaign', crmCampaign)
                isNotNull('dateOpened')
            }
            [crmCampaign: crmCampaign, recipients: recipients, totalCount: recipients.totalCount, hitCount: hitCount]
        }
    }

    def deleteRecipient(Long id) {
        def tenant = TenantUtils.tenant
        def crmCampaignRecipient = CrmCampaignRecipient.get(id)
        if (!crmCampaignRecipient) {
            flash.error = message(code: 'crmCampaignRecipient.not.found.message', args: [message(code: 'crmCampaignRecipient.label', default: 'Recipient'), id])
            redirect(action: "index")
            return
        }
        def crmCampaign = crmCampaignRecipient.campaign
        if (crmCampaign?.tenantId != tenant) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN)
            return
        }
        def tombstone = crmCampaignRecipient.toString()
        CrmCampaignRecipient.withTransaction {
            crmCampaignRecipient.delete()
        }
        flash.warning = message(code: 'crmCampaignRecipient.deleted.message', args: [message(code: 'crmCampaignRecipient.label', default: 'Recipient'), tombstone])
        redirect action: "recipients", id: crmCampaign.id
    }
}
