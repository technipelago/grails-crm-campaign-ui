package grails.plugins.crm.campaign

import grails.converters.JSON
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.transaction.Transactional
import org.springframework.dao.DataIntegrityViolationException

import javax.servlet.http.HttpServletResponse

class CrmCampaignController {

    static allowedMethods = [create: ["GET", "POST"], edit: ["GET", "POST"], delete: "POST"]

    def crmCoreService
    def crmSecurityService
    def selectionService
    def selectionRepositoryService
    def crmCampaignService

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmCampaignQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmCampaignQuery'))
        [cmd: cmd, campaignTypes: crmCampaignService.getEnabledCampaignHandlers(), activeCampaigns: getActiveCampaigns()]
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
            if (result.size() == 1) {
                // If we only got one record, show the record immediately.
                redirect action: "show", params: selectionService.createSelectionParameters(uri) + [id: result.head().ident()]
            } else {
                [crmCampaignList: result, crmCampaignTotal: result.totalCount, selection: uri]
            }
        } catch (Exception e) {
            flash.error = e.message
            [crmCampaignList: [], crmCampaignTotal: 0, selection: uri]
        }
    }

    def clearQuery() {
        WebUtils.setTenantData(request, 'crmCampaignQuery', null)
        redirect(action: 'index')
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
        def campaignTypes = crmCampaignService.getEnabledCampaignHandlers()
        def user = crmSecurityService.getCurrentUser()
        def userList = crmSecurityService.getTenantUsers()
        def timeList = (0..23).inject([]) { list, h ->
            4.times {
                list << String.format("%02d:%02d", h, it * 15)
            }; list
        }
        timeList << '23:59' // So a campaign can end at midnight.
        def parentList = CrmCampaign.findAllByTenantId(tenant)

        def crmCampaign = new CrmCampaign(username: user.username)
        bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST, exclude: ['startTime', 'endTime']])
        crmCampaign.handlerName = params.handlerName

        def startDate = params.startDate
        def endDate = params.endDate
        def startTime = params.startTime ?: '00:00'
        def endTime = params.endTime ?: '23:59'
        bindDate(crmCampaign, 'startTime', startDate ? startDate + ' ' + startTime : null, user?.timezoneInstance)
        bindDate(crmCampaign, 'endTime', endDate ? endDate + ' ' + endTime : null, user?.timezoneInstance)

        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, campaignTypes: campaignTypes, parentList: parentList, timeList: timeList, userList: userList]
            case "POST":
                if (crmCampaign.hasErrors() || !crmCampaign.save()) {
                    render(view: "create", model: [crmCampaign: crmCampaign, campaignTypes: campaignTypes, parentList: parentList, timeList: timeList, userList: userList])
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
        def timeList = (0..23).inject([]) { list, h ->
            4.times {
                list << String.format("%02d:%02d", h, it * 15)
            }; list
        }
        timeList << '23:59' // So a campaign can end at midnight.
        if (crmCampaign.startTime) {
            def hm = crmCampaign.startTime.format("HH:mm")
            if (!timeList.contains(hm)) {
                timeList << hm
            }
        }
        if (crmCampaign.endTime) {
            def hm = crmCampaign.endTime.format("HH:mm")
            if (!timeList.contains(hm)) {
                timeList << hm
            }
        }
        timeList = timeList.sort()

        def parentList = CrmCampaign.findAllByTenantId(tenant)
        def campaignTypes = crmCampaignService.getEnabledCampaignHandlers()
        switch (request.method) {
            case "GET":
                return [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, campaignTypes: campaignTypes, userList: userList]
            case "POST":
                if (params.int('version') != null) {
                    if (crmCampaign.version > params.int('version')) {
                        crmCampaign.errors.rejectValue("version", "crmCampaign.optimistic.locking.failure",
                                [message(code: 'crmCampaign.label', default: 'Campaign')] as Object[],
                                "Another user has updated this Campaign while you were editing")
                        render(view: "edit", model: [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, campaignTypes: campaignTypes, userList: userList])
                        return
                    }
                }

                bindData(crmCampaign, params, [include: CrmCampaign.BIND_WHITELIST, exclude: ['startTime', 'endTime']])
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
                    render(view: "edit", model: [crmCampaign: crmCampaign, parentList: parentList, timeList: timeList, campaignTypes: campaignTypes, userList: userList])
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
            def tombstone = crmCampaignService.deleteCampaign(crmCampaign)
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

    def paginate() {
        render template: 'paginate', model: params
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

    def addRecipient(Long id, String ref) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def instance = crmCoreService.getReference(ref)
        if (!instance) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def result = event(for: 'crmCampaign', topic: 'addRecipient',
                data: [tenant: tenant, campaign: id, name: instance.name, email: instance.email, telephone: instance.telephone ?: instance.mobile])
                .waitFor(10000)?.value
        if (!result) {
            result = [name: instance.name, email: instance.email, telephone: instance.telephone ?: instance.mobile]
        }
        int numAdded = crmCampaignService.createRecipients(crmCampaign, [result])

        def rval = crmCampaign.dao
        rval.added = numAdded
        rval.included = crmCampaign.contains(instance.email, instance.telephone ?: instance.mobile)
        render rval as JSON
    }

    def recipients(Long id, String name, String email, String telephone) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }
        if (request.post) {
            if (email) {
                def result = event(for: 'crmCampaign', topic: 'addRecipient',
                        data: [tenant: tenant, campaign: id, name: name, email: email, telephone: telephone])
                        .waitFor(10000)?.value
                if (!result) {
                    result = [name: name, email: email, telephone: telephone]
                }
                crmCampaignService.createRecipients(crmCampaign, [result])
            } else {
                flash.error = message(code: 'crmCampaignRecipient.email.blank.message', args: [message(code: 'crmCampaignRecipient.email.label', default: 'Campaign'), message(code: 'crmCampaignRecipient.label', default: 'Recipient')])
            }
            redirect action: "show", id: id, fragment: 'recipients'
        } else {
            if (!params.max) {
                params.max = 10
            }
            if (!params.sort) {
                params.sort = 'dateSent'
            }
            def recipients = CrmCampaignRecipient.createCriteria().list(params) {
                eq('campaign', crmCampaign)
                if (params.q) {
                    String queryValue = '%' + params.q + '%'
                    or {
                        ilike('name', queryValue)
                        ilike('email', queryValue)
                        ilike('telephone', queryValue)
                    }
                }
            }
            WebUtils.shortCache(response)
            render template: 'recipients_list', model: [bean: crmCampaign, result: recipients, totalCount: recipients.totalCount]
        }
    }

    def showRecipient(Long id) {
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
        def reference = crmCampaignRecipient.ref ? crmCoreService.getReference(crmCampaignRecipient.ref) : null
        def model = [recipient: crmCampaignRecipient, reference: reference]
        def previousCampaigns = [] as Set
        if (crmCampaignRecipient.email) {
            def result = CrmCampaignRecipient.createCriteria().list() {
                ne('id', crmCampaignRecipient.id)
                ilike('email', crmCampaignRecipient.email)
            }
            if (result) {
                previousCampaigns.addAll(result*.campaignId)
            }
        }
        if (crmCampaignRecipient.telephone) {
            def result = CrmCampaignRecipient.createCriteria().list() {
                ne('id', crmCampaignRecipient.id)
                ilike('telephone', crmCampaignRecipient.telephone)
            }
            if (result) {
                previousCampaigns.addAll(result*.campaignId)
            }
        }
        if (previousCampaigns) {
            previousCampaigns.remove(crmCampaign.id) // Don't show the current campaign.
            model.campaigns = CrmCampaign.createCriteria().list([sort: 'startTime', order: 'desc']) {
                inList('id', previousCampaigns)
            }
        }
        WebUtils.shortCache(response)
        render template: "recipient", model: model
    }

    @Transactional
    def deleteRecipient(Long id) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }

        List<Long> recipients = params.list('recipients').collect { Long.valueOf(it) }
        def result = recipients ? CrmCampaignRecipient.createCriteria().list() {
            eq('campaign', crmCampaign)
            inList('id', recipients)
        } : []
        def tombstone = "${result.size()}"

        for (r in result) {
            r.delete()
        }

        flash.warning = message(code: 'crmCampaignRecipient.deleted.message', args: [message(code: 'crmCampaignRecipient.label', default: 'Recipient'), tombstone])
        redirect action: "show", id: id, fragment: 'recipients'
    }

    def copy(Long id) {

        def tenant = TenantUtils.tenant
        def templateCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!templateCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(action: "index")
            return
        }

        def crmCampaign = crmCampaignService.copyCampaign(templateCampaign, true)
        if (crmCampaign.hasErrors()) {
            log.error crmCampaign.errors.allErrors.toString()
            flash.error = message(code: 'crmCampaign.copy.error', args: [message(code: 'crmCampaign.label', default: 'Campaign'), templateCampaign.toString()])
            redirect(action: "show", id: templateCampaign.id)
        } else {
            flash.success = message(code: 'crmCampaign.copied.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), crmCampaign.toString()])
            redirect(action: "show", id: crmCampaign.id)
        }
    }
}
