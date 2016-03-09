/*
 * Copyright 2013 Goran Ehrsson.
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

import grails.transaction.Transactional

import javax.servlet.http.HttpServletResponse
import grails.plugins.crm.core.TenantUtils

class InformationCampaignController {

    def informationCampaign

    def summary(Long id) {
        def crmCampaign = CrmCampaign.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmCampaign) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        render template: "summary", model: [bean: crmCampaign]
    }

    def statistics(Long id) {
        render ''
    }

    @Transactional
    def edit(Long id) {
        def crmCampaign = CrmCampaign.get(id)
        if (!crmCampaign) {
            flash.error = message(code: 'crmCampaign.not.found.message', args: [message(code: 'crmCampaign.label', default: 'Campaign'), id])
            redirect(controller: "crmCampaign", action: "index")
            return
        }

        switch (request.method) {
            case "GET":
                def cfg = crmCampaign.configuration
                return [crmCampaign: crmCampaign, cfg: cfg]
            case "POST":
                informationCampaign.configure(crmCampaign, params)
                crmCampaign.save()
                flash.success = "Inställningarna uppdaterade"
                redirect controller: "crmCampaign", action: "show", id: id
                break
        }
    }
}
