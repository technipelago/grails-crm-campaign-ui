<%@ page defaultCodec="html" %>
<dl>
    <g:each in="${bean.target}" var="t">
        <dt>${message(code: 'crmCampaignTarget.operation.' + t.operation, default: t.operation.toString())}: ${t.name}</dt>
        <dd>${t.description}</dd>
    </g:each>
</dl>

<p class="lead">Resultatet blir <strong>${totalCount}</strong> poster.</p>