<table class="table table-striped">
    <thead>
    <tr>
        <crm:sortableColumn property="number"
                            title="${message(code: 'crmCampaign.number.label', default: 'Number')}"/>

        <crm:sortableColumn property="name"
                            title="${message(code: 'crmCampaign.name.label', default: 'Name')}"/>

        <th><g:message code="crmCampaign.startTime.label" default="Starts"/></th>
        <th><g:message code="crmCampaign.endTime.label" default="Ends"/></th>
        <th><g:message code="crmCampaign.status.label" default="Status"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="crmCampaign">
        <tr class="${crmCampaign.active ? '' : 'disabled'}">

            <td>
                <g:link controller="crmCampaign" action="show" id="${crmCampaign.id}">
                    ${fieldValue(bean: crmCampaign, field: "number")}
                </g:link>
            </td>

            <td>
                <g:link controller="crmCampaign" action="show" id="${crmCampaign.id}">
                    ${fieldValue(bean: crmCampaign, field: "name")}
                </g:link>
            </td>

            <td>
                <g:formatDate type="date" date="${crmCampaign.startTime}"/>
            </td>

            <td>
                <g:formatDate type="date" date="${crmCampaign.endTime}"/>
            </td>
            <td>
                ${crmCampaign.active ? 'Aktiv' : 'Inaktiv'}
            </td>
        </tr>
    </g:each>
    </tbody>
</table>