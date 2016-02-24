<%@ page defaultCodec="html" %>

<p>
    <g:message code="crmCampaign.target.size.title" default="The target group is based on the specification above"
               args="${[bean, totalCount]}"/>
</p>

<dl>
    <g:each in="${bean.target}" var="t">
        <dt>${t.orderIndex}. ${message(code: 'crmCampaignTarget.operation.' + t.operation, default: t.operation.toString())}: ${t.name}</dt>
        <dd>${t.description}</dd>
    </g:each>
</dl>


<h4>
    <g:message code="crmCampaign.target.size.label" default="This target group reaches {1} recipients"
               args="${[bean, totalCount]}"/>
</h4>