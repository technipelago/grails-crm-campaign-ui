<dl>
    <g:if test="${reference}">
        <dt><g:message code="crmCampaignRecipient.ref.label" default="Name"/></dt>
        <dd><crm:referenceLink reference="${reference}"/></dd>
    </g:if>

    <dt><g:message code="crmCampaignRecipient.email.label" default="Email"/></dt>
    <dd><g:fieldValue bean="${recipient}" field="email"/></dd>

    <g:if test="${recipient.dateSent}">
        <dt><g:message code="crmCampaignRecipient.dateSent.label" default="Sent"/></dt>
        <dd><g:formatDate type="datetime" style="short" date="${recipient.dateSent}"/></dd>
    </g:if>

    <g:if test="${recipient.dateOpened}">
        <dt style="color: green;"><g:message code="crmCampaignRecipient.dateOpened.label" default="Opened"/></dt>
        <dd style="color: green;"><g:formatDate type="datetime" style="short" date="${recipient.dateOpened}"/></dd>
    </g:if>

    <g:if test="${recipient.dateOptOut}">
        <dt style="color: orange;"><g:message code="crmCampaignRecipient.dateOptOut.label" default="Opt-out"/></dt>
        <dd style="color: orange;"><g:formatDate type="datetime" style="short" date="${recipient.dateOptOut}"/></dd>
    </g:if>

    <g:if test="${recipient.dateBounced}">
        <dt style="color: red;"><g:message code="crmCampaignRecipient.dateBounced.label" default="Bounced"/></dt>
        <dd style="color: red;"><g:formatDate type="datetime" style="short" date="${recipient.dateBounced}"/></dd>
    </g:if>

    <g:if test="${recipient.reason}">
        <dt style="color: red;"><g:message code="crmCampaignRecipient.reason.label" default="Reason"/></dt>
        <dd style="color: red;"><g:fieldValue bean="${recipient}" field="reason"/></dd>
    </g:if>
</dl>
