package grails.plugins.crm.campaign

import grails.plugins.crm.core.TenantUtils
import org.springframework.dao.DataIntegrityViolationException

/**
 * Campaign Target Group actions.
 */
class CrmCampaignTargetController {

    static allowedMethods = [add: 'POST', delete: 'POST']

    def crmCampaignTargetService
    def crmEmailCampaignService
    def selectionRepositoryService
    def crmSecurityService

    def add(Long id, Long selection, Integer orderIndex, int operation) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }
        def username = crmSecurityService.currentUser.username
        def selectionData = selectionRepositoryService.list('crmContact', username, crmCampaign.tenantId).find { it.id == selection }
        if (selectionData) {
            if (!orderIndex) {
                orderIndex = (crmCampaign.target?.max { it.orderIndex }?.orderIndex ?: 0) + 1
            }
            def s = new CrmCampaignTarget(campaign: crmCampaign, orderIndex: orderIndex, operation: operation,
                    name: selectionData.name, uriString: selectionData.uri.toASCIIString())
            if (s.validate()) {
                crmCampaign.addToTarget(s)
                crmCampaign.save(flush: true)
            } else {
                flash.error = s.errors.allErrors.toString()
            }
        } else {
            flash.error = "Selection [$selection] not found"
        }
        redirect controller: "crmCampaign", action: "show", id: id, fragment: "target"
    }

    def delete(Long id) {
        def target = CrmCampaignTarget.createCriteria().get() {
            campaign {
                eq('tenantId', TenantUtils.tenant)
            }
            eq('id', id)
        }
        def crmCampaign = target?.campaign
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }
        try {
            def tombstone = target.toString()
            target.delete(flush: true)
            flash.warning = message(code: 'crmCampaignTarget.deleted.message', args: [message(code: 'crmCampaignTarget.label', default: 'Target Group'), tombstone])
            redirect(controller: "crmCampaign", action: "show", id: crmCampaign.id, fragment: "target")
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmCampaign.not.deleted.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "show", id: crmCampaign.id, fragment: "target")
        }
    }

    def deleteRecipients(Long id) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        def result = CrmCampaignRecipient.executeUpdate("delete from CrmCampaignRecipient where campaign = :c and dateSent is null", [c: crmCampaign])
        flash.warning = message(code: 'crmCampaign.recipients.deleted.message', args: [message(code: 'crmCampaignRecipient.label', default: 'Recipient'), result])
        redirect(controller: "crmCampaign", action: "show", id: crmCampaign.id, fragment: "target")
    }

    def execute(Long id) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }
        try {
            def startTime = System.currentTimeMillis()
            def result = crmCampaignTargetService.select(crmCampaign, [:])
            def count = crmEmailCampaignService.createRecipients(crmCampaign, result*.email)
            if (log.isDebugEnabled()) {
                log.debug("Generating [${count}/${result.size()}] targets for campaign [${crmCampaign.ident()}] \"${crmCampaign}\" took ${System.currentTimeMillis() - startTime} ms")
            }
            flash.success = message(code: 'crmCampaign.target.created.message', default: "{0} records added to target group", args: [count])
        } catch (Exception e) {
            log.error "Failed to create recipients for campaign [${id}]", e
            flash.error = message(code: 'crmCampaign.target.create.error', default: "Could not create target group", args: [e.message])
        }
        redirect controller: "crmCampaign", action: "show", id: id, fragment: "target"
    }

    def count(Long id) {
        def tenant = TenantUtils.tenant
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, tenant)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }
        def result = crmCampaignTargetService.select(crmCampaign, [:])
        render template: "count", model: [bean: crmCampaign, totalCount: result.size()]
    }
}
