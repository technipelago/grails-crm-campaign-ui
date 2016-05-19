<div class="row-fluid">
    <div class="span6">
        <dl>
            <g:if test="${reference}">
                <dt><g:message code="crmCampaignRecipient.ref.label" default="Name"/></dt>
                <dd><crm:referenceLink reference="${reference}"/></dd>
            </g:if>
            <g:elseif test="${recipient.name}">
                <dt><g:message code="crmCampaignRecipient.name.label" default="Name"/></dt>
                <dd><g:fieldValue bean="${recipient}" field="name"/></dd>
            </g:elseif>

            <g:if test="${recipient.email}">
                <dt><g:message code="crmCampaignRecipient.email.label" default="Email"/></dt>
                <dd><g:fieldValue bean="${recipient}" field="email"/></dd>
            </g:if>

            <g:if test="${recipient.telephone}">
                <dt><g:message code="crmCampaignRecipient.telephone.label" default="Phone"/></dt>
                <dd><g:fieldValue bean="${recipient}" field="telephone"/></dd>
            </g:if>

            <g:if test="${recipient.dateSent}">
                <dt><g:message code="crmCampaignRecipient.dateSent.label" default="Sent"/></dt>
                <dd><g:formatDate type="datetime" style="short" date="${recipient.dateSent}"/></dd>
            </g:if>

            <g:if test="${recipient.dateOpened}">
                <dt style="color: green;"><g:message code="crmCampaignRecipient.dateOpened.label"
                                                     default="Opened"/></dt>
                <dd style="color: green;"><g:formatDate type="datetime" style="short"
                                                        date="${recipient.dateOpened}"/></dd>
            </g:if>

            <g:if test="${recipient.dateOptOut}">
                <dt style="color: orange;"><g:message code="crmCampaignRecipient.dateOptOut.label"
                                                      default="Opt-out"/></dt>
                <dd style="color: orange;"><g:formatDate type="datetime" style="short"
                                                         date="${recipient.dateOptOut}"/></dd>
            </g:if>

            <g:if test="${recipient.dateBounced}">
                <dt style="color: red;"><g:message code="crmCampaignRecipient.dateBounced.label"
                                                   default="Bounced"/></dt>
                <dd style="color: red;"><g:formatDate type="datetime" style="short"
                                                      date="${recipient.dateBounced}"/></dd>
            </g:if>

            <g:if test="${recipient.reason}">
                <dt style="color: red;"><g:message code="crmCampaignRecipient.reason.label" default="Reason"/></dt>
                <dd style="color: red;"><g:fieldValue bean="${recipient}" field="reason"/></dd>
            </g:if>
        </dl>
    </div>

    <g:if test="${campaigns}">
        <div class="span6">
            <label>Tidigare kampanjer</label>
            <g:each in="${campaigns}" var="campaign">
                <div><g:link action="show" id="${campaign.id}">${campaign}</g:link></div>
            </g:each>
        </div>
    </g:if>
</div>