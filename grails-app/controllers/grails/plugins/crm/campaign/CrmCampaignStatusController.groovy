/*
 * Copyright (c) 2012 Goran Ehrsson.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package grails.plugins.crm.campaign

import org.springframework.dao.DataIntegrityViolationException
import javax.servlet.http.HttpServletResponse

class CrmCampaignStatusController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    static navigation = [
            [group: 'admin',
                    order: 710,
                    title: 'crmCampaignStatus.label',
                    action: 'index'
            ]
    ]

    def selectionService
    def crmCampaignService

    def domainClass = CrmCampaignStatus

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmCampaignStatus/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmCampaignStatusQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmCampaignStatusList: result, crmCampaignStatusTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmCampaignStatusList: [], crmCampaignStatusTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmCampaignStatus = crmCampaignService.createCampaignStatus(params)
        switch (request.method) {
            case 'GET':
                return [crmCampaignStatus: crmCampaignStatus]
            case 'POST':
                if (!crmCampaignStatus.save(flush: true)) {
                    render view: 'create', model: [crmCampaignStatus: crmCampaignStatus]
                    return
                }

                flash.success = message(code: 'crmCampaignStatus.created.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), crmCampaignStatus.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmCampaignStatus = domainClass.get(params.id)
                if (!crmCampaignStatus) {
                    flash.error = message(code: 'crmCampaignStatus.not.found.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmCampaignStatus: crmCampaignStatus]
            case 'POST':
                def crmCampaignStatus = domainClass.get(params.id)
                if (!crmCampaignStatus) {
                    flash.error = message(code: 'crmCampaignStatus.not.found.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmCampaignStatus.version > version) {
                        crmCampaignStatus.errors.rejectValue('version', 'crmCampaignStatus.optimistic.locking.failure',
                                [message(code: 'crmCampaignStatus.label', default: 'Campaign Status')] as Object[],
                                "Another user has updated this Type while you were editing")
                        render view: 'edit', model: [crmCampaignStatus: crmCampaignStatus]
                        return
                    }
                }

                crmCampaignStatus.properties = params

                if (!crmCampaignStatus.save(flush: true)) {
                    render view: 'edit', model: [crmCampaignStatus: crmCampaignStatus]
                    return
                }

                flash.success = message(code: 'crmCampaignStatus.updated.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), crmCampaignStatus.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmCampaignStatus = domainClass.get(params.id)
        if (!crmCampaignStatus) {
            flash.error = message(code: 'crmCampaignStatus.not.found.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmCampaignStatus)) {
            render view: 'edit', model: [crmCampaignStatus: crmCampaignStatus]
            return
        }

        try {
            def tombstone = crmCampaignStatus.toString()
            crmCampaignStatus.delete(flush: true)
            flash.warning = message(code: 'crmCampaignStatus.deleted.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmCampaignStatus.not.deleted.message', args: [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmCampaignStatus status) {
        def count = CrmCampaign.countByStatus(status)
        def rval = false
        if (count) {
            flash.error = message(code: "crmCampaignStatus.delete.error.reference", args:
                    [message(code: 'crmCampaignStatus.label', default: 'Campaign Status'),
                            message(code: 'crmCampaign.label', default: 'Campaign'), count],
                    default: "This {0} is used by {1} {2}")
            rval = true
        }

        return rval
    }

    def moveUp(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def prev = domainClass.createCriteria().list([sort: 'orderIndex', order: 'desc']) {
                lt('orderIndex', sort)
                maxResults 1
            }?.find {it}
            if (prev) {
                domainClass.withTransaction {tx ->
                    target.orderIndex = prev.orderIndex
                    prev.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }

    def moveDown(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def next = domainClass.createCriteria().list([sort: 'orderIndex', order: 'asc']) {
                gt('orderIndex', sort)
                maxResults 1
            }?.find {it}
            if (next) {
                domainClass.withTransaction {tx ->
                    target.orderIndex = next.orderIndex
                    next.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }
}
